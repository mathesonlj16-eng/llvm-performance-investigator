import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

from tools.run import ROOT, WORKLOADS, parse_run, summary


class RunnerTests(unittest.TestCase):
    def test_exact_checksum(self):
        _, checksum, _ = parse_run("checksum=18446744073709551615\nelapsed_ms=1\nmax_error=0")
        self.assertEqual(checksum, 2**64 - 1)

    def test_invalid_fields(self):
        for text in ["elapsed_ms=0", "checksum=NaN", "max_error=inf", "max_error=-1"]:
            fields = dict(elapsed_ms="1", checksum="0", max_error="0")
            key, value = text.split("=")
            fields[key] = value
            with self.subTest(text=text), self.assertRaises(ValueError):
                parse_run("\n".join(f"{k}={v}" for k, v in fields.items()))
        with self.assertRaises(ValueError):
            parse_run("elapsed_ms=1")
        with self.assertRaises(ValueError):
            parse_run("checksum=1\nchecksum=2\nelapsed_ms=1\nmax_error=0")

    def test_outlier(self):
        self.assertEqual(summary([9, 10, 11, 12, 1000]), {"median_ms": 11, "mad_ms": 1})

    def test_reject_same_release(self):
        result = subprocess.run([sys.executable, "tools/run.py", "--compiler", "clang++",
                                 "--candidate", "clang++", "--march", "x86-64"],
                                cwd=ROOT, text=True, capture_output=True)
        self.assertEqual(result.returncode, 2)
        self.assertIn("different Clang releases", result.stderr)

    @unittest.skipUnless(shutil.which("clang++-20") and shutil.which("clang++-21"),
                         "requires packaged Clang 20 and 21")
    def test_version_report(self):
        with tempfile.TemporaryDirectory() as tmp:
            dest = Path(tmp) / "versions"
            subprocess.run([sys.executable, "tools/run.py", "--compiler", "clang++-20",
                            "--candidate", "clang++-21", "--march", "x86-64", "--level", "O2",
                            "--size", "37", "--rounds", "3", "--samples", "4", "--warmups", "0",
                            "--workload", "dot_product", "--output", dest], cwd=ROOT,
                           check=True, stdout=subprocess.DEVNULL)
            report = json.loads((dest / "report.json").read_text())
            config = report["configurations"]
            self.assertEqual([c["level"] for c in config.values()], ["O2", "O2"])
            self.assertNotEqual(config["baseline"]["version"], config["candidate"]["version"])
            result = report["workloads"]["dot_product"]
            self.assertEqual(result["order_including_warmups"],
                             [["baseline", "candidate"], ["candidate", "baseline"]] * 2)
            for label in config:
                self.assertTrue((dest / "dot_product" / f"{label}.ll").is_file())
            self.assertIn("percent_change_candidate_vs_baseline", result)

    def test_end_to_end(self):
        with tempfile.TemporaryDirectory() as tmp:
            dest = Path(tmp) / "run"
            subprocess.run([sys.executable, "tools/run.py", "--size", "37", "--rounds", "3",
                            "--samples", "3", "--warmups", "1", "--output", dest], cwd=ROOT,
                           check=True, stdout=subprocess.DEVNULL)
            report = json.loads((dest / "report.json").read_text())
            state = 12345
            a = []
            for _ in range(38):
                state = (1664525 * state + 1013904223) % 2**32
                a.append(state >> 16)
            dot = hashed = 0
            for offset in [0, 1, 0]:
                h = 0
                for i in range(37):
                    dot += a[i + offset] * i
                    if a[i + offset] >= 32768:
                        h = (33 * h + i) % 2**64
                hashed += h
            data = report["workloads"]
            self.assertEqual(int(data["branch_hash"]["checksum"]), hashed % 2**64)
            self.assertEqual(int(data["dot_product"]["checksum"]), dot)
            expected = sum(i * .001 * 1.25 + i * .002 for i in range(37)) + 3 * .0001 * 1.25
            self.assertAlmostEqual(float(data["array_transform"]["checksum"]), expected, places=5)
            for name in WORKLOADS:
                self.assertIn(name, (dest / "report.md").read_text())
                self.assertEqual(data[name]["order_including_warmups"], [["O3", "O2"], ["O2", "O3"]] * 2)
                for level in ("O2", "O3"):
                    self.assertEqual(len(data[name]["trials"][level]), 3)
                    for suffix in ("s", "ll", "remarks.txt"):
                        self.assertGreater((dest / name / f"{level}.{suffix}").stat().st_size, 0)

