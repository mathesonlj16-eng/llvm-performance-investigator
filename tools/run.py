#!/usr/bin/env python3
"""Minimal, reproducible Clang -O2 vs -O3 performance experiment.

No third-party Python packages required. Run from the repository root.
"""
from __future__ import annotations

import argparse
import json
import platform
import random
import shutil
import statistics
import subprocess
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "src" / "array_transform.cpp"
BUILD = ROOT / ".build"
RESULTS = ROOT / "results"


def command(args: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(args, cwd=ROOT, text=True, capture_output=True, check=True)


def parse_run(output: str) -> dict[str, float]:
    parsed = {}
    for line in output.splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            parsed[key] = float(value)
    if not {"elapsed_ms", "checksum", "max_error"}.issubset(parsed):
        raise ValueError(f"Unexpected benchmark output: {output!r}")
    if not 0 < parsed["elapsed_ms"] < 1e12:
        raise ValueError(f"Invalid benchmark timing: {parsed!r}")
    return parsed


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--compiler", default="clang++")
    parser.add_argument("--size", type=int, default=1_000_000)
    parser.add_argument("--rounds", type=int, default=100)
    parser.add_argument("--samples", type=int, default=7)
    parser.add_argument("--warmups", type=int, default=2)
    args = parser.parse_args()
    if args.size <= 0 or args.rounds <= 0 or args.samples < 3 or args.warmups < 0:
        parser.error("Size and rounds must be positive; samples >= 3; warmups >= 0")
    if not shutil.which(args.compiler):
        parser.error(f"Compiler not found: {args.compiler}")

    BUILD.mkdir(exist_ok=True)
    RESULTS.mkdir(exist_ok=True)
    configs = {"O2": ["-O2"], "O3": ["-O3"]}
    binaries = {}
    for label, flags in configs.items():
        binary = BUILD / f"benchmark_{label}"
        common = [args.compiler, "-std=c++20", *flags, "-march=native", "-DNDEBUG"]
        print(f"Compiling {label}...")
        command([*common, str(SOURCE), "-o", str(binary)])
        binaries[label] = binary
        asm = command([*common, "-S", "-masm=intel", str(SOURCE), "-o", str(RESULTS / f"{label}.s")])
        ir = command([*common, "-S", "-emit-llvm", str(SOURCE), "-o", str(RESULTS / f"{label}.ll")])
        remarks = command([*common, "-S", "-Rpass=loop-vectorize", "-Rpass-missed=loop-vectorize",
                           str(SOURCE), "-o", "/dev/null"])
        (RESULTS / f"{label}_vectorization.txt").write_text(remarks.stderr or "No vectorization remarks emitted.\n")

    measurements: dict[str, list[float]] = {name: [] for name in configs}
    checksums: dict[str, list[float]] = {name: [] for name in configs}
    rng = random.Random(42)
    for index in range(args.warmups + args.samples):
        order = list(configs)
        rng.shuffle(order)
        for label in order:
            run = command([str(binaries[label]), str(args.size), str(args.rounds)])
            parsed = parse_run(run.stdout)
            if index >= args.warmups:
                measurements[label].append(parsed["elapsed_ms"])
                checksums[label].append(parsed["checksum"])
        print(f"Trial {index + 1}/{args.warmups + args.samples}: OK")

    all_checksums = [checksum for values in checksums.values() for checksum in values]
    if max(all_checksums) - min(all_checksums) > 1e-5 * max(1.0, abs(statistics.mean(all_checksums))):
        raise RuntimeError("Compiler configurations disagree on output checksums")

    medians = {name: statistics.median(values) for name, values in measurements.items()}
    percent = (medians["O3"] / medians["O2"] - 1.0) * 100.0
    details = {
        "timestamp_utc": datetime.now(timezone.utc).isoformat(),
        "platform": platform.platform(),
        "cpu": command(["uname", "-m"]).stdout.strip(),
        "compiler": command([args.compiler, "--version"]).stdout.splitlines()[0],
        "workload": "array_transform",
        "size": args.size,
        "rounds": args.rounds,
        "samples": args.samples,
        "warmups": args.warmups,
        "compile_options": "-std=c++20 -march=native -DNDEBUG plus -O2/-O3",
        "measurements_ms": measurements,
        "medians_ms": medians,
        "percent_change_O3_vs_O2": percent,
        "checksums": checksums,
    }
    (RESULTS / "report.json").write_text(json.dumps(details, indent=2) + "\n")
    report = f"""# Clang optimization comparison (exploratory)

- Compiler: `{details['compiler']}`
- System: `{details['platform']}` ({details['cpu']})
- Workload: `{details['workload']}`, size={args.size:,}, rounds={args.rounds}
- Benchmark repetitions: {args.samples} measured; {args.warmups} warm-up trials
- Compile options: `{details['compile_options']}`

| Configuration | Median elapsed time | Raw timings (ms) |
|---|---:|---|
| `-O2` | {medians['O2']:.3f} ms | {', '.join(f'{t:.3f}' for t in measurements['O2'])} |
| `-O3` | {medians['O3']:.3f} ms | {', '.join(f'{t:.3f}' for t in measurements['O3'])} |

**Difference:** `-O3` is {abs(percent):.2f}% {'slower' if percent > 0 else 'faster' if percent < 0 else 'different by zero'} than `-O2` by median time.

**Interpretation:** This is an exploratory comparison of optimization settings, not evidence of a compiler regression. Timing differences can be noise. Verify any interesting result with larger workloads, more repeated trials, fixed system settings, and assembly/IR inspection.

Generated evidence: `O2.s`, `O3.s`, `O2.ll`, `O3.ll`, vectorization remark files, and `report.json`.

**Benchmark caveats:** Input initialization and correctness validation are outside the timed region. The loop includes one changing input per round to avoid trivially identical passes. Runs are interleaved in a reproducibly shuffled order. The code runs on the local CPU and may be affected by power management, thermal throttling, or WSL2 scheduling. `-march=native` means machine code is CPU-specific. Do not compare results obtained on different machines as if they are directly interchangeable.
"""
    (RESULTS / "report.md").write_text(report)
    print("\n" + report)
    print(f"Results written to {RESULTS}")


if __name__ == "__main__":
    main()
