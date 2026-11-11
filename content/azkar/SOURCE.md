# content/azkar — source record

**Never edit `hisn_elmoslem.db`** (CLAUDE.md §1). It is a verbatim copy.
**Not shown in the app yet:** every difference in `docs/azkar-verification.md` must be resolved
first (owner decision 2026-11-11: "use it, but check it against other sources 100%").

## hisn_elmoslem.db
- Book: *Hisn al-Muslim min Adhkar al-Kitab wa al-Sunnah* — Sa'id ibn Ali ibn Wahf al-Qahtani.
  The author's printed edition (42nd ed., Riyadh 1436 AH) allows anyone to print and distribute it
  free of charge without deletion, addition or change, if "وقف لله تعالى" is shown on the cover.
- Data file from: **Hisn Elmoslem App** by Hassan Eltantawy / muslimpack —
  https://github.com/muslimpack/HisnElmoslem_App, file `hisnelmoslem/assets/db/hisn_elmoslem.db`,
  commit `1d52411b6d8457630693a9394190ef30265e68f5` (2026-03-31).
- License of that project: **GPL-3.0-only** (Qandeel is GPL-3.0, compatible). Credit the project in
  the app's "About & sources" screen.
- Downloaded: 2026-11-11
- Size: 344,064 bytes
- SHA-256: `85deef61b180dccfdfb710eece471122c85a5380268abb5d52539d587b523d9f`
- Format: SQLite. Tables `titles` (135: introduction, virtue of dhikr, then the book's 132 chapters
  with chapter 27 split into morning and evening) and `contents` (335 entries: text, count, virtue,
  reference, grading, audio URL from hisnmuslim.com).

## Known differences from the printed book (found by `tools/verify_azkar.py`)
- The developer split some book entries into separate rows, wrote out the evening wording of the
  morning/evening azkar, and moved count words ("ثلاث مرات") into the count field.
- `hokm` (grading such as صحيح/حسن) was **added by the developer**; it is not in the book.
  Not shown in the app unless the owner decides otherwise.
- Quran passages are **not stored**: they appear as placeholders `QuranText[(surah:first:last)]`.
- Some references use special-font codes: `‘` = رحمه الله, `’` = رضي الله عنها, `^` = رضي الله عنهما,
  `×` = ﷺ. They must not be shown as punctuation.
- Full list: `docs/azkar-verification.md`. Review decisions: `content/azkar/REVIEW.md`.

## How to re-check
```
python3 tools/verify_azkar.py --fetch /tmp/azkar-cache   # downloads Shamela + hisnmuslim.com copies once
python3 tools/verify_azkar.py /tmp/azkar-cache           # rewrites docs/azkar-verification.md
```

## Owner to-do
- Save the GPL-3.0 license page and the author's permission page (copyright page of the printed
  book / PDF) to Google Drive → "01 Licenses & permissions".
