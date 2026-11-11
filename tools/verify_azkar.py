#!/usr/bin/env python3
"""Cross-check content/azkar/hisn_elmoslem.db against two independent copies of
Hisn al-Muslim, and write a report of every difference for a human reviewer.

Nothing here changes the database. The other copies are used only for
checking and are never shipped in the app.

Sources compared:
  A. Shamela (shamela.ws/book/31307): digitization of the author's own edition
     (Safir Press, Riyadh), page numbers matching the print, with the author's
     reference footnotes.
  B. hisnmuslim.com Arabic API (/api/ar/{chapter}.json): text + repeat counts,
     numbered like the book.

Usage (from the repo root):
  python3 tools/verify_azkar.py --fetch CACHE_DIR      # download A and B once
  python3 tools/verify_azkar.py CACHE_DIR              # compare, write report

Report: docs/azkar-verification.md

Levels for each database entry (its text must appear inside the matching
chapter of the other copy; entries may be split, so containment is used):
  exact    same letters AND same diacritics (spaces/punctuation ignored)
  marks    same letters, some diacritics differ  -> list shown
  letters  letters differ (spelling or words)    -> must be checked by a person
"""

import html
import json
import os
import re
import sqlite3
import subprocess
import sys
import time
import unicodedata
from difflib import SequenceMatcher

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB = os.path.join(ROOT, "content", "azkar", "hisn_elmoslem.db")
REPORT = os.path.join(ROOT, "docs", "azkar-verification.md")
SHAMELA_BOOK = 31307
SHAMELA_PAGES = 151
HM_INDEX = "https://www.hisnmuslim.com/api/ar/husn_ar.json"

def book_chapter(db_order):
    """Database title "order" -> book chapter (0 = introduction/virtue of dhikr).
    The database has the introduction and "virtue of dhikr" as orders 1-2, and
    splits book chapter 27 (morning and evening azkar) into orders 29 and 30."""
    if db_order <= 2:
        return 0
    if db_order <= 28:
        return db_order - 2
    if db_order in (29, 30):
        return 27
    return db_order - 3

ARABIC_LETTERS = set(range(0x0621, 0x063B)) | set(range(0x0641, 0x064B)) | {0x0671}
MARKS = set(range(0x064B, 0x0653)) | {0x0670}  # tanween, harakat, shadda, sukun, dagger alef


# ---------------------------------------------------------------- fetching
def curl(url, out):
    r = subprocess.run(
        ["curl", "-sS", "--max-time", "40", "-o", out, "-w", "%{http_code}", url],
        capture_output=True, text=True,
    )
    return r.stdout == "200"


def fetch(cache):
    os.makedirs(os.path.join(cache, "shamela"), exist_ok=True)
    os.makedirs(os.path.join(cache, "hm"), exist_ok=True)
    for pid in range(1, SHAMELA_PAGES + 1):
        out = os.path.join(cache, "shamela", f"{pid:03d}.html")
        if not os.path.exists(out):
            if not curl(f"https://shamela.ws/book/{SHAMELA_BOOK}/{pid}", out):
                sys.exit(f"failed: shamela page {pid}")
            time.sleep(0.4)
    idx = os.path.join(cache, "hm", "index.json")
    if not os.path.exists(idx) and not curl(HM_INDEX, idx):
        sys.exit("failed: hisnmuslim index")
    for ch in list(json.load(open(idx, encoding="utf-8-sig")).values())[0]:
        out = os.path.join(cache, "hm", f"{ch['ID']:03d}.json")
        if not os.path.exists(out):
            if not curl(f"https://www.hisnmuslim.com/api/ar/{ch['ID']}.json", out):
                sys.exit(f"failed: hisnmuslim chapter {ch['ID']}")
            time.sleep(0.3)


# ----------------------------------------------------------- normalizing
QURAN_PLACEHOLDER = re.compile(r"QuranText\[[^\]]*\]")


def expand(s):
    """Honorific ligatures (e.g. U+FDFA ﷺ) -> their letters, so both spellings compare equal."""
    return "".join(
        unicodedata.normalize("NFKC", ch) if 0xFDF0 <= ord(ch) <= 0xFDFF else ch for ch in s
    )


def full_key(s):
    """Arabic letters with their diacritics, in a canonical order; nothing else."""
    s = expand(s)
    out, marks = [], []
    def flush():
        out.extend(sorted(marks))
        marks.clear()
    for ch in unicodedata.normalize("NFC", s):
        c = ord(ch)
        if c in ARABIC_LETTERS:
            flush()
            out.append(ch)
        elif c in MARKS:
            marks.append(ch)
    flush()
    return "".join(out)


def letters_key(s):
    return "".join(ch for ch in expand(s) if ord(ch) in ARABIC_LETTERS)


def ref_key(s):
    """Letters + digits (any digit system -> 0-9) for comparing references.
    Special-font codes count as the phrase they stand for (comparison only)."""
    s = expand("".join(SPECIAL_CODES.get(ch, ch) for ch in s))
    out = []
    for ch in s:
        c = ord(ch)
        if 0x0660 <= c <= 0x0669:
            out.append(chr(c - 0x0660 + 0x30))
        elif 0x06F0 <= c <= 0x06F9:
            out.append(chr(c - 0x06F0 + 0x30))
        elif ch.isdigit() or c in ARABIC_LETTERS:
            out.append(ch)
    return "".join(out)


def strip_tags(s):
    return html.unescape(re.sub(r"<[^>]+>", " ", s))


# ----------------------------------------------------------- loading sources
def load_shamela(cache):
    """Returns (chapters, footnotes): chapters[k] = main text of book chapter k
    (0 = introduction + virtue of dhikr), footnotes = list of all footnotes."""
    pages = []
    for pid in range(1, SHAMELA_PAGES + 1):
        t = open(os.path.join(cache, "shamela", f"{pid:03d}.html"), encoding="utf-8").read()
        start = t.index('<div class="nass')
        end = t.index('<div id="appended_pages"', start)
        block = t[start:end]
        main, _, notes = block.partition('<p class="hamesh">')
        main = main.split("<hr>")[0]
        paras = [strip_tags(p) for p in re.findall(r"<p[^>]*>(.*?)</p>", main, re.S)]
        pages.append((paras, [strip_tags(n) for n in re.split(r"<br\s*/?>", notes)]))
    chapters = {0: []}
    current = 0
    heading = re.compile(r"^\s*([٠-٩]+)\s*-\s*[^\s\d٠-٩(]")
    footnotes = []
    for paras, notes in pages:
        footnotes.extend(n.strip() for n in notes if n.strip())
        for p in paras:
            m = heading.match(p)
            # Chapter headings are short "N - title" lines; numbered azkar
            # look like "N - (M) ..." and are excluded by the regex.
            if m and len(p) < 120:
                n = int(m.group(1).translate(str.maketrans("٠١٢٣٤٥٦٧٨٩", "0123456789")))
                if n == current + 1:
                    current = n
                    chapters[current] = []
                    continue
            chapters[current].append(p)
    return {k: " ".join(v) for k, v in chapters.items()}, footnotes


def load_hm(cache):
    chapters, repeats = {}, {}
    for name in os.listdir(os.path.join(cache, "hm")):
        if name == "index.json":
            continue
        d = json.load(open(os.path.join(cache, "hm", name), encoding="utf-8-sig"))
        items = list(d.values())[0]
        cid = int(name.split(".")[0])
        chapters[cid] = " ".join(i["ARABIC_TEXT"] for i in items)
        repeats[cid] = [(letters_key(i["ARABIC_TEXT"]), i["REPEAT"], i["ID"]) for i in items]
    return chapters, repeats


# -------------------------------------------------------------- comparing
def level(text, other):
    """How well `text` is found inside `other`. Quran placeholders are left
    out; each remaining piece must be found on its own."""
    if not other:
        return "missing", ""
    pieces = [p for p in QURAN_PLACEHOLDER.split(text) if letters_key(p)]
    if len(pieces) != 1:
        if not pieces:
            return "quran", ""
        results = [level(p, other) for p in pieces]
        order = ["exact", "marks", "letters"]
        worst = max(results, key=lambda r: order.index(r[0]))
        return worst[0], " | ".join(r[1] for r in results if r[1])
    text = pieces[0]
    fk, ok = full_key(text), full_key(other)
    if fk and fk in ok:
        return "exact", ""
    lk, lo = letters_key(text), letters_key(other)
    if lk and lk in lo:
        return "marks", mark_diff(text, other)
    return "letters", letter_diff(lk, lo)


def mark_diff(text, other):
    """Words whose diacritics differ (letters equal)."""
    other_words = {}
    for w in other.split():
        other_words.setdefault(letters_key(w), set()).add(full_key(w))
    diffs = []
    for w in text.split():
        lk = letters_key(w)
        if lk in other_words and full_key(w) not in other_words[lk]:
            diffs.append(f"{w.strip('(),.؛،{}[]«»')} ≠ {' / '.join(sorted(other_words[lk]))}")
    return "; ".join(diffs[:6]) + (" …" if len(diffs) > 6 else "")


def letter_diff(lk, lo):
    """Closest region of `lo` to `lk`, and the differing letters."""
    if not lk:
        return "(empty entry)"
    sm = SequenceMatcher(None, lo, lk, autojunk=False)
    m = sm.find_longest_match(0, len(lo), 0, len(lk))
    if not m.size:
        return "no overlap"
    start = max(0, m.a - m.b)
    window = lo[start:start + len(lk) + 10]
    sm2 = SequenceMatcher(None, window, lk, autojunk=False)
    ops = [
        f"{tag}: «{window[i1:i2]}» → «{lk[j1:j2]}»"
        for tag, i1, i2, j1, j2 in sm2.get_opcodes()
        if tag != "equal"
    ]
    tags = {tag for tag, *_ in sm2.get_opcodes() if tag != "equal"}
    # The window may run past the entry's end; trailing book text is not a difference.
    kind = "omits book words" if tags == {"delete"} else "adds words" if tags == {"insert"} else "changes words"
    ratio = sm2.ratio()
    return f"{kind}, similarity {ratio:.0%}; " + "; ".join(ops[:5]) + (" …" if len(ops) > 5 else "")


def main():
    if len(sys.argv) == 3 and sys.argv[1] == "--fetch":
        fetch(sys.argv[2])
        return
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    cache = sys.argv[1]
    sh_chapters, sh_notes = load_shamela(cache)
    hm_chapters, hm_repeats = load_hm(cache)
    # Footnote keys without their "(n)" number; longest first for matching.
    sh_note_keys = sorted(
        {ref_key(re.sub(r"^\s*\([٠-٩0-9]+\)", "", n)) for n in sh_notes}, key=len, reverse=True
    )

    db = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    titles = {r[0]: (r[1], r[2]) for r in db.execute('select id, "order", name from titles')}
    rows = db.execute(
        'select c.id, t."order", c."order", c.content, c.count, c.source '
        'from contents c join titles t on t.id = c.titleId order by t."order", c."order"'
    ).fetchall()

    summary = {"A": {}, "B": {}}
    issues, ref_issues, count_issues, quran_refs = [], [], [], []
    for cid, t_order, c_order, content, count, source in rows:
        book_ch = book_chapter(t_order)
        for m in QURAN_PLACEHOLDER.finditer(content):
            quran_refs.append((cid, book_ch, m.group(0)))
        a_text = sh_chapters.get(book_ch if book_ch >= 1 else 0, "")
        la, da = level(content, a_text)
        summary["A"][la] = summary["A"].get(la, 0) + 1
        if book_ch >= 1:
            lb, db_ = level(content, hm_chapters.get(book_ch, ""))
        else:
            lb, db_ = "n/a", ""
        summary["B"][lb] = summary["B"].get(lb, 0) + 1
        if la not in ("exact", "quran") or lb not in ("exact", "n/a", "quran"):
            issues.append((cid, book_ch, content, la, da, lb, db_))

        # The reference must be made of the author's footnotes (Shamela). The
        # database often joins several footnotes into one field, so remove
        # every footnote found in it and see what is left over.
        if book_ch >= 1 and source:
            rk = ref_key(source)
            rest = rk
            for nk in sh_note_keys:
                if len(nk) >= 8 and nk in rest:
                    rest = rest.replace(nk, "")
            if rk and not any(rk in nk for nk in sh_note_keys) and len(rest) > max(8, len(rk) // 10):
                ref_issues.append((cid, book_ch, source, rest))

        # Repeat count vs hisnmuslim.com (when the entry maps to one item).
        if book_ch >= 1:
            lk = letters_key(content)
            hits = [(rep, hid) for key, rep, hid in hm_repeats.get(book_ch, []) if lk and lk in key]
            if len(hits) == 1 and hits[0][0] != count:
                count_issues.append((cid, book_ch, count, hits[0][0], hits[0][1], content))

    specials = {}
    for cid, _, _, content, _, source in rows:
        for col, text in (("text", content), ("reference", source or "")):
            for ch in text:
                if ch in SPECIAL_CODES:
                    specials.setdefault((col, ch), []).append(cid)
    write_report(rows, summary, issues, ref_issues, count_issues, quran_refs, specials)
    print(json.dumps(summary, ensure_ascii=False))
    print(f"issues: text {len(issues)}, references {len(ref_issues)}, counts {len(count_issues)}")


def short(s, n=90):
    s = " ".join(s.split())
    return s if len(s) <= n else s[:n] + " …"


# Characters that stand for honorific phrases in a special symbol font
# (they look like punctuation in normal fonts), and the phrase in the book.
SPECIAL_CODES = {
    "‘": "رحمه الله",
    "’": "رضي الله عنها",
    "^": "رضي الله عنهما",
    "×": "صلى الله عليه وسلم",
}


def write_report(rows, summary, issues, ref_issues, count_issues, quran_refs, specials):
    L = []
    L.append("# Azkar verification report")
    L.append("")
    L.append("Generated by `tools/verify_azkar.py`. Do not edit by hand; run the tool again.")
    L.append("")
    L.append("Database: `content/azkar/hisn_elmoslem.db` (see `content/azkar/SOURCE.md`).")
    L.append("Compared with **A** = Shamela book 31307 (author's Safir edition, with his footnotes) and")
    L.append("**B** = hisnmuslim.com Arabic API. Both are used only for checking.")
    L.append("")
    L.append(f"Entries checked: **{len(rows)}**")
    L.append("")
    L.append("| Result | vs A (Shamela) | vs B (hisnmuslim.com) |")
    L.append("|---|---|---|")
    for lv, label in [("exact", "identical incl. diacritics"), ("marks", "same letters, diacritics differ"),
                      ("letters", "letters differ — check by hand"), ("quran", "only a Quran placeholder"),
                      ("missing", "chapter not found"),
                      ("n/a", "not in source (intro)")]:
        L.append(f"| {label} | {summary['A'].get(lv, 0)} | {summary['B'].get(lv, 0)} |")
    L.append("")
    L.append(f"References not found among the author's footnotes (A): **{len(ref_issues)}**  ")
    L.append(f"Repeat counts different from B: **{len(count_issues)}**")
    L.append("")
    L.append("## How to review")
    L.append("For each item below, open the printed book (or the author's PDF) at that chapter and")
    L.append("decide which wording is correct. Record the decision in `content/azkar/REVIEW.md`.")
    L.append("Nothing is shown in the app until every item is resolved.")
    L.append("")
    L.append("## Text differences")
    L.append("")
    L.append("| DB id | Book ch. | Entry (start) | vs A | vs B |")
    L.append("|---|---|---|---|---|")
    for cid, ch, content, la, da, lb, db_ in issues:
        a = la if la == "exact" else f"**{la}** {da}"
        b = lb if lb in ("exact", "n/a") else f"**{lb}** {db_}"
        L.append(f"| {cid} | {ch if ch >= 1 else 'intro'} | {short(content)} | {a} | {b} |".replace("\n", " "))
    L.append("")
    L.append("## References not found in the author's footnotes")
    L.append("")
    L.append("After removing every footnote of the book found in the reference, these have text left over.")
    L.append("")
    L.append("| DB id | Book ch. | Reference in DB | Left over (letters/digits) |")
    L.append("|---|---|---|---|")
    for cid, ch, src, rest in ref_issues:
        L.append(f"| {cid} | {ch} | {short(src, 120)} | {short(rest, 60)} |")
    L.append("")
    L.append("## Special-font codes")
    L.append("")
    L.append("These characters show as punctuation in normal fonts but mean an honorific phrase in the")
    L.append("book. The app must not show them as they are (owner to decide how to display them).")
    L.append("")
    L.append("| Character | Means | Where | DB ids |")
    L.append("|---|---|---|---|")
    for (col, ch), ids in sorted(specials.items()):
        L.append(f"| `{ch}` (U+{ord(ch):04X}) | {SPECIAL_CODES[ch]} | {col} | {', '.join(map(str, sorted(set(ids))))} |")
    L.append("")
    L.append("## Quran placeholders")
    L.append("")
    L.append("The database does not store these verses; it refers to them as")
    L.append("`QuranText[(surah:first:last),...]`. Qandeel must show them from a verified Quran text.")
    L.append("")
    L.append("| DB id | Book ch. | Placeholder |")
    L.append("|---|---|---|")
    for cid, ch, ph in quran_refs:
        L.append(f"| {cid} | {ch if ch >= 1 else 'intro'} | `{ph}` |")
    L.append("")
    L.append("## Repeat counts that differ from hisnmuslim.com")
    L.append("")
    L.append("Note: hisnmuslim.com often keeps the count inside the text (e.g. \"ثلاث مرات\") with REPEAT = 1,")
    L.append("while the database moves the book's stated count into its count field. Check against the book.")
    L.append("")
    L.append("| DB id | Book ch. | DB count | B count (B id) | Entry (start) |")
    L.append("|---|---|---|---|---|")
    for cid, ch, c, rb, hid, content in count_issues:
        L.append(f"| {cid} | {ch} | {c} | {rb} ({hid}) | {short(content, 60)} |")
    L.append("")
    with open(REPORT, "w", encoding="utf-8") as f:
        f.write("\n".join(L))


if __name__ == "__main__":
    main()
