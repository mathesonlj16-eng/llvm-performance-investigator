#!/usr/bin/env python3
"""Compare optimization levels or Clang releases on x86-64 Linux."""
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


def compile_kernel(compiler, workload, level, build, evidence, label, march):
    source = f"src/{workload}.cpp"
    flags = [compiler, "-std=c++20", "-" + level, f"-march={march}", "-DNDEBUG"]
    stem = evidence / label
    binary = build / f"{workload}_{label}"
    sources = [source] if workload == "array_transform" else [source, "src/integer_driver.cpp"]
    command([*flags, *sources, "-o", binary])
    asm = command([*flags, "-S", "-masm=intel", "-Rpass=loop-vectorize",
                   "-Rpass-missed=loop-vectorize", "-Rpass-analysis=loop-vectorize",
                   source, "-o", stem.with_suffix(".s")])
    stem.with_suffix(".remarks.txt").write_text(asm.stderr)
    command([*flags, "-S", "-emit-llvm", source, "-o", stem.with_suffix(".ll")])
    return binary


def measure(args, binaries):
    labels = tuple(binaries)
    observations = {level: [] for level in labels}
    expected = None
    order_log = []
    for index in range(-args.warmups, args.samples):
        order = labels if index % 2 == 0 else labels[::-1]
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
    delta = 100 * (stats[labels[1]]["median_ms"] / stats[labels[0]]["median_ms"] - 1)
    return dict(checksum=str(expected), order_including_warmups=order_log, trials=observations,
                statistics=stats, **{f"percent_change_{labels[1]}_vs_{labels[0]}": delta})


def markdown(report):
    first, second = report["configurations"]
    lines = [report["title"], "", report["compiler"], report["cpu"],
             report["platform"], "", f"Flags: {report['flags']}", "",
             f"Parameters: {report['parameters']}", "",
             f"| Workload | {first} median ± MAD (ms) | {second} median ± MAD (ms) | Time change |",
             "|---|---:|---:|---:|"]
    for name, data in report["workloads"].items():
        cells = [f"{s['median_ms']:.3f} ± {s['mad_ms']:.3f}" for s in data["statistics"].values()]
        delta = data[f"percent_change_{second}_vs_{first}"]
        lines.append(f"| {name} | {' | '.join(cells)} | {delta:+.2f}% |")
    lines.extend(["", "MAD is median absolute deviation across process trials. "
                  f"Negative change means a shorter {second} median. WSL scheduling and CPU frequency can affect timings."])
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--compiler", default="clang++")
    parser.add_argument("--candidate", help="Compare this Clang release against --compiler")
    parser.add_argument("--level", choices=LEVELS, help="Fixed optimization level in version mode (default O3)")
    parser.add_argument("--march", help="Explicit CPU target (required in version mode)")
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
    if args.level and not args.candidate:
        parser.error("--level requires --candidate")
    if args.candidate and args.march in (None, "", "native"):
        parser.error("Version comparisons require an explicit --march")
    march = args.march or "native"
    level = args.level or "O3"
    selections = ({"baseline": (args.compiler, level), "candidate": (args.candidate, level)}
                  if args.candidate else {k: (args.compiler, k) for k in LEVELS})
    configs = {}
    for label, (driver, opt) in selections.items():
        path = shutil.which(driver)
        if not path:
            parser.error(f"Compiler missing: {driver}")
        version = command([path, "--version"]).stdout.splitlines()[0]
        if "clang version " not in version.lower():
            parser.error(f"Expected Clang, got {version}")
        configs[label] = dict(path=path, version=version, level=opt,
                              triple=command([path, "-dumpmachine"]).stdout.strip(),
                              runtime=str(Path(command([path, "-print-file-name=libstdc++.so"]).stdout.strip()).resolve()))
    first, second = configs.values()
    if args.candidate:
        releases = [c["version"].split("clang version ")[1].split()[0] for c in configs.values()]
        if releases[0] == releases[1]:
            parser.error("Select different Clang releases")
        if any(first[k] != second[k] for k in ("runtime", "triple")):
            parser.error("Compilers must share the target triple and C++ runtime")
    now = datetime.now(timezone.utc)
    dest = args.output or ROOT / "results" / now.strftime("%Y%m%dT%H%M%S%fZ")
    dest.mkdir(parents=True, exist_ok=False)
    cpu = next(line.split(":", 1)[1].strip() for line in Path("/proc/cpuinfo").read_text().splitlines()
               if line.startswith("model name"))
    report = dict(timestamp_utc=now.isoformat(), compiler=" / ".join(dict.fromkeys(c["version"] for c in configs.values())),
                  compiler_path=first["path"], configurations=configs, affinity=sorted(os.sched_getaffinity(0)),
                  title="# Compiler-version comparison" if args.candidate else "# Optimization-level comparison",
                  target=first["triple"], cpu=cpu,
                  logical_cpus_available=len(os.sched_getaffinity(0)), python=platform.python_version(),
                  platform=platform.platform(), flags=f"-std=c++20 -{level if args.candidate else 'O2/-O3'} -march={march} -DNDEBUG",
                  parameters={key: getattr(args, key) for key in ("size", "rounds", "samples", "warmups")},
                  workloads={})
    build = ROOT / ".build"
    build.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(dir=build) as tmp:
        for workload in ([args.workload] if args.workload else WORKLOADS):
            evidence = dest / workload
            evidence.mkdir()
            binaries = {k: compile_kernel(c["path"], workload, c["level"], Path(tmp), evidence, k, march)
                        for k, c in configs.items()}
            report["workloads"][workload] = measure(args, binaries)
    (dest / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    (dest / "report.md").write_text(markdown(report))
    print(markdown(report), dest)


if __name__ == "__main__":
    main()

