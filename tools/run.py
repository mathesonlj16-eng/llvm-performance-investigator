#!/usr/bin/env python3
"""Compare two optimization levels on x86-64 Linux with one Clang executable."""
import argparse
from datetime import datetime, timezone
from decimal import Decimal
import json
import math
import os
from pathlib import Path
import platform
import shutil
import statistics
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
WORKLOADS = ("array_transform", "dot_product", "branch_hash")
LEVELS = ("O2", "O3")


def command(args):
    proc = subprocess.run(args, cwd=ROOT, text=True, capture_output=True)
    if proc.returncode:
        raise RuntimeError(f"{args} exited {proc.returncode}\n{proc.stderr}")
    return proc


def parse_run(output):
    fields = {}
    for line in output.splitlines():
        key, value = line.split("=", 1)
        if key in fields:
            raise ValueError(f"Duplicate field {key}")
        fields[key] = value
    if fields.keys() != {"elapsed_ms", "checksum", "max_error"}:
        raise ValueError("Unexpected benchmark fields")
    timing, error = float(fields["elapsed_ms"]), float(fields["max_error"])
    checksum = Decimal(fields["checksum"])
    if not (0 < timing < 1e12 and math.isfinite(error) and error >= 0 and checksum.is_finite()):
        raise ValueError("Invalid benchmark measurement")
    return timing, checksum, error


def summary(values):
    median = statistics.median(values)
    return {"median_ms": median, "mad_ms": statistics.median(abs(x - median) for x in values)}


def compile_kernel(compiler, workload, level, build, evidence):
    source = f"src/{workload}.cpp"
    flags = [compiler, "-std=c++20", "-" + level, "-march=native", "-DNDEBUG"]
    stem = evidence / level
    binary = build / f"{workload}_{level}"
    sources = [source] if workload == "array_transform" else [source, "src/integer_driver.cpp"]
    command([*flags, *sources, "-o", binary])
    asm = command([*flags, "-S", "-masm=intel", "-Rpass=loop-vectorize",
                   "-Rpass-missed=loop-vectorize", "-Rpass-analysis=loop-vectorize",
                   source, "-o", stem.with_suffix(".s")])
    stem.with_suffix(".remarks.txt").write_text(asm.stderr)
    command([*flags, "-S", "-emit-llvm", source, "-o", stem.with_suffix(".ll")])
    return binary


def measure(args, binaries):
    observations = {level: [] for level in LEVELS}
    expected = None
    order_log = []
    for index in range(-args.warmups, args.samples):
        order = LEVELS if index % 2 == 0 else LEVELS[::-1]
        order_log.append(list(order))
        for level in order:
            proc = command([binaries[level], str(args.size), str(args.rounds)])
            timing, checksum, error = parse_run(proc.stdout)
            if expected is None:
                expected = checksum
            if checksum != expected:
                raise ValueError("Checksums disagree across runs")
            if index >= 0:
                observations[level].append({"elapsed_ms": timing, "max_error": error})
    stats = {k: summary([x["elapsed_ms"] for x in rows]) for k, rows in observations.items()}
    delta = 100 * (stats["O3"]["median_ms"] / stats["O2"]["median_ms"] - 1)
    return dict(checksum=str(expected), order_including_warmups=order_log, trials=observations,
                statistics=stats, percent_change_O3_vs_O2=delta)


def markdown(report):
    lines = ["# Optimization-level comparison", "", report["compiler"], report["cpu"],
             report["platform"], "", f"Flags: {report['flags']}", "",
             f"Parameters: {report['parameters']}", "",
             "| Workload | O2 median ± MAD (ms) | O3 median ± MAD (ms) | Time change |",
             "|---|---:|---:|---:|"]
    for name, data in report["workloads"].items():
        cells = [f"{s['median_ms']:.3f} ± {s['mad_ms']:.3f}" for s in data["statistics"].values()]
        lines.append(f"| {name} | {' | '.join(cells)} | {data['percent_change_O3_vs_O2']:+.2f}% |")
    lines.extend(["", "MAD is median absolute deviation across process trials. "
                  "Negative change means a shorter O3 median. WSL scheduling and CPU frequency can affect timings."])
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--compiler", default="clang++")
    parser.add_argument("--size", type=int, default=1_000_000)
    parser.add_argument("--rounds", type=int, default=100)
    parser.add_argument("--samples", type=int, default=7)
    parser.add_argument("--warmups", type=int, default=2)
    parser.add_argument("--workload", choices=WORKLOADS)
    parser.add_argument("--output", type=Path, help="New directory for this run")
    args = parser.parse_args()
    if not (0 < args.size <= 100_000_000 and 0 < args.rounds <= 1_000_000
            and args.samples >= 3 and args.warmups >= 0):
        parser.error("Invalid size, rounds, samples or warmups")
    compiler = shutil.which(args.compiler)
    if not compiler:
        parser.error("Compiler missing")
    version = command([compiler, "--version"]).stdout.splitlines()[0]
    if "clang" not in version.lower():
        parser.error("A Clang C++ driver is required")
    now = datetime.now(timezone.utc)
    dest = args.output or ROOT / "results" / now.strftime("%Y%m%dT%H%M%S%fZ")
    dest.mkdir(parents=True, exist_ok=False)
    cpu = next(line.split(":", 1)[1].strip() for line in Path("/proc/cpuinfo").read_text().splitlines()
               if line.startswith("model name"))
    report = dict(timestamp_utc=now.isoformat(), compiler=version, compiler_path=compiler,
                  target=command([compiler, "-dumpmachine"]).stdout.strip(), cpu=cpu,
                  logical_cpus_available=len(os.sched_getaffinity(0)), python=platform.python_version(),
                  platform=platform.platform(), flags="-std=c++20 -O2/-O3 -march=native -DNDEBUG",
                  parameters={key: getattr(args, key) for key in ("size", "rounds", "samples", "warmups")},
                  workloads={})
    build = ROOT / ".build"
    build.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(dir=build) as tmp:
        for workload in ([args.workload] if args.workload else WORKLOADS):
            evidence = dest / workload
            evidence.mkdir()
            binaries = {k: compile_kernel(compiler, workload, k, Path(tmp), evidence) for k in LEVELS}
            report["workloads"][workload] = measure(args, binaries)
    (dest / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    (dest / "report.md").write_text(markdown(report))
    print(markdown(report), dest)


if __name__ == "__main__":
    main()

