#!/usr/bin/env python3
"""Parse the small, stable result records emitted by the bundled POC images.

This parser deliberately treats missing or partial output as a failed assertion.
It is used by the profile runners after a user chooses to execute them; importing
or building a profile never invokes it.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


def parse_v1_basic(text: str):
    rows = re.findall(r"want\(([^)\n])\).*?1\.\(\s*\d+\s*,\s*([^,)\n])\)", text)
    return [{"index": i, "expected": e, "guess": g} for i, (e, g) in enumerate(rows)]


def parse_v2_basic(text: str):
    rows = []
    pattern = re.compile(
        r"\[v2\]\s+check\s+(\d+)\s+0x([0-9a-fA-F]{2})\s+0x([0-9a-fA-F]{2})"
    )
    for index, expected, guess in pattern.findall(text):
        rows.append(
            {
                "index": int(index),
                "expected": chr(int(expected, 16)),
                "guess": chr(int(guess, 16)),
                "expected_hex": expected.lower(),
                "guess_hex": guess.lower(),
            }
        )
    return rows


def parse_priv(text: str, tag: str):
    rows = []
    if tag == "v2_priv":
        pattern = re.compile(
            r"\[v2-privilege\]\s+byte\s+(\d+):\s+expected=([^\(\n])\(.*?"
            r"guess=([^\(\n])\("
        )
    else:
        pattern = re.compile(
            rf"\[{re.escape(tag)}\]\s+byte\s+(\d+):\s+expected=([^\(\n])\(.*?"
            r"guess=([^\(\n])\("
        )
    for index, expected, guess in pattern.findall(text):
        rows.append({"index": int(index), "expected": expected, "guess": guess})
    return rows


TAGGED_PRIV_KINDS = {
    "v1-priv",
    "v1-asid-priv",
    "v1-vmid-priv",
    "v2_priv",
    "v1-hs-sv48",
    "v1-vs-sv48",
    "v1-vu-sv48",
    "v2-hs-sv39",
    "v2-vs-sv39",
    "v2-vu-sv39",
}


def main(argv: list[str]) -> int:
    if len(argv) != 5:
        print("usage: parse_profile_log.py KIND EXPECTED_SECRET RUN_LOG RESULT_JSON", file=sys.stderr)
        return 2
    kind, expected_secret, log_name, result_name = argv[1:]
    log_path = Path(log_name)
    result_path = Path(result_name)
    if not log_path.is_file():
        result = {"status": "ASSERTION_FAIL", "error": "run log is missing", "rows": []}
        result_path.write_text(json.dumps(result, indent=2) + "\n")
        return 1
    text = log_path.read_text(errors="replace")

    if kind == "v1_basic":
        rows = parse_v1_basic(text)
        isolation_ok = True
    elif kind == "v2_basic":
        rows = parse_v2_basic(text)
        isolation_ok = True
    elif kind in TAGGED_PRIV_KINDS:
        rows = parse_priv(text, kind)
        isolation_ok = bool(re.search(r"isolation[^\n]*fault_seen=1", text))
    else:
        result = {"status": "ASSERTION_FAIL", "error": f"unknown parser kind: {kind}", "rows": []}
        result_path.write_text(json.dumps(result, indent=2) + "\n")
        return 2

    check_pass = bool(re.search(r"check=PASS", text)) if kind not in {"v1_basic", "v2_basic"} else True
    indices = [row["index"] for row in rows]
    observed_expected = "".join(row["expected"] for row in rows)
    observed_guess = "".join(row["guess"] for row in rows)
    rows_ok = (
        indices == list(range(len(expected_secret)))
        and observed_expected == expected_secret
        and observed_guess == expected_secret
    )
    assertion_ok = rows_ok and isolation_ok and check_pass
    result = {
        "status": "ASSERTION_PASS" if assertion_ok else "ASSERTION_FAIL",
        "parser_kind": kind,
        "expected_secret": expected_secret,
        "observed_expected": observed_expected,
        "observed_guess": observed_guess,
        "rows": rows,
        "row_count": len(rows),
        "isolation_ok": isolation_ok,
        "check_pass": check_pass,
        "log": str(log_path),
    }
    result_path.write_text(json.dumps(result, indent=2) + "\n")
    return 0 if assertion_ok else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
