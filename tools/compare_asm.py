"""Compare emitted instructions for each measured kernel in a version-mode run."""
import argparse
import difflib
from pathlib import Path
import re


def instructions(path):
    lines = path.read_text().splitlines()
    begin = next(i for i, s in enumerate(lines) if re.match(r"^_Z(?:6kernel|9transform)\w*:", s))
    end = next(i for i in range(begin + 1, len(lines)) if lines[i].startswith(".Lfunc_end"))
    body = []
    for line in lines[begin + 1:end]:
        code = line.partition("#")[0].strip()
        if code and (code[0].isalpha() or code.endswith(":")):
            body.append(code)
    return body


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("session", type=Path)
    args = parser.parse_args()
    for file in sorted(args.session.glob("*/baseline.s")):
        older = instructions(file)
        newer = instructions(file.with_name("candidate.s"))
        print(f"{file.parent.name}: {len(older)} vs {len(newer)} instructions and labels")
        print("\n".join(difflib.unified_diff(older, newer, "baseline", "candidate", lineterm=""))
              or "Identical instruction and label text")
