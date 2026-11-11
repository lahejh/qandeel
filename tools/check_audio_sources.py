#!/usr/bin/env python3
"""Monthly check that every recitation source still works (docs/PLAN.md).

Reads the reciters and their sources from app/lib/audio/reciters.dart, so the
list cannot drift from the app. For each source it downloads a few sample
verses (first, Ayat al-Kursi, last, and a few spread through the Quran) and
checks: HTTP 200, non-empty, and that the ETag MD5 matches the bytes.

Exit code 0 = all fine; 1 = something failed (the GitHub Action then opens an
issue with this script's output).

Usage:  python3 tools/check_audio_sources.py
"""

import hashlib
import os
import re
import sys
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RECITERS = os.path.join(ROOT, "app", "lib", "audio", "reciters.dart")

# Global verse numbers (1..6236): 1:1, 2:255, 18:1, 36:1, 67:1, 114:6
SAMPLES = [1, 262, 2141, 3706, 5242, 6236]

TEMPLATES = {
    "islamicNetwork": "https://cdn.islamic.network/quran/audio/{bitrate}/{edition}/{n}.mp3",
}


def sources():
    text = open(RECITERS, encoding="utf-8").read()
    pattern = re.compile(
        r"ReciterSource\(\s*AudioSourceKind\.(\w+)\s*,\s*'([^']+)'(?:\s*,\s*bitrate:\s*(\d+))?"
    )
    for kind, edition, bitrate in pattern.findall(text):
        yield kind, edition, int(bitrate or 128)


def check(url):
    req = urllib.request.Request(url, headers={"User-Agent": "Qandeel-source-check"})
    with urllib.request.urlopen(req, timeout=60) as r:
        body = r.read()
        etag = (r.headers.get("ETag") or "").strip('"').lower()
        if r.status != 200 or not body:
            return f"HTTP {r.status}, {len(body)} bytes"
        if re.fullmatch(r"[0-9a-f]{32}", etag) and hashlib.md5(body).hexdigest() != etag:
            return "checksum mismatch"
    return None


def main():
    failures, checked = [], 0
    for kind, edition, bitrate in sources():
        template = TEMPLATES.get(kind)
        if template is None:
            print(f"skip  {kind}/{edition}: no URLs configured yet")
            continue
        for n in SAMPLES:
            url = template.format(bitrate=bitrate, edition=edition, n=n)
            try:
                problem = check(url)
            except Exception as e:  # network errors, 404, timeouts
                problem = str(e)
            checked += 1
            status = "FAIL" if problem else "ok  "
            print(f"{status}  {kind}/{edition} verse {n}: {problem or url}")
            if problem:
                failures.append(f"{kind}/{edition} verse {n}: {problem} ({url})")
    print(f"\nchecked {checked} files, {len(failures)} failed")
    if checked == 0:
        print("No sources found in reciters.dart — check the parser.")
        return 1
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
