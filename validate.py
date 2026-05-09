#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent
RULE = ROOT / "rule.md"

SECRET_PATTERNS = [
    re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----"),
    re.compile(r"\bAKIA[0-9A-Z]{16}\b"),
    re.compile(r"\bgh[pousr]_[A-Za-z0-9_]{30,}\b"),
    re.compile(r"\bxox[baprs]-[A-Za-z0-9-]{20,}\b"),
]

PRIVATE_PATH_PATTERNS = [
    # Keep these split so validate.py does not match its own pattern literals.
    re.compile(r"/" + r"Users/[A-Za-z0-9._-]+(?:/|\b)"),
    re.compile(r"/" + r"home/[A-Za-z0-9._-]+(?:/|\b)"),
    re.compile(r"C:" + r"\\Users\\[^\\\s]+"),
    re.compile(r"/" + r"private/var/folders/[^\s)]+"),
    re.compile(r"\biCloud" + r"~[A-Za-z0-9~._-]+"),
    re.compile(r"\bo" + r"p://[^\s)]+"),
]


def main() -> int:
    errors: list[str] = []

    if not RULE.exists():
        errors.append("missing rule.md")
    else:
        text = RULE.read_text(encoding="utf-8")
        if not text.strip():
            errors.append("rule.md is empty")
        if not text.startswith("# "):
            errors.append("rule.md must start with a top-level Markdown heading")

        for pattern in SECRET_PATTERNS:
            if pattern.search(text):
                errors.append("rule.md contains a suspicious secret pattern")
        for pattern in PRIVATE_PATH_PATTERNS:
            if pattern.search(text):
                errors.append("rule.md contains a suspicious private path")

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    print("validation ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
