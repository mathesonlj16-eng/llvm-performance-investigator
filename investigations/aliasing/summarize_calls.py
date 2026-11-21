"""Summarize paired elapsed times in ns/call. Positive deltas favor restricted."""
import csv
from pathlib import Path
from statistics import median
import sys


def center_spread(values):
    center = median(values)
    return center, median(abs(v - center) for v in values)


def main(directory):
    out = csv.writer(sys.stdout, lineterminator="\n")
    out.writerow(["session", "n", "ordinary_median", "ordinary_mad", "restricted_median",
                  "restricted_mad", "paired_delta_median", "paired_delta_mad"])
    for session in ("a16", "b64", "c64", "d16"):
        pairs = {}
        with (directory / f"{session}.csv").open() as stream:
            for row in csv.DictReader(stream):
                key = int(row["n"]), int(row["pair"])
                pairs.setdefault(key, {})[row["kernel"]] = int(row["elapsed_ns"]) / int(row["calls"])
        for n in sorted({key[0] for key in pairs}):
            rows = [pairs[n, i] for i in range(12)]
            stats = (*center_spread([r["ordinary"] for r in rows]),
                     *center_spread([r["restricted"] for r in rows]),
                     *center_spread([r["ordinary"] - r["restricted"] for r in rows]))
            out.writerow([session, n, *(f"{v:.4f}" for v in stats)])


if __name__ == "__main__":
    main(Path(sys.argv[1]))
