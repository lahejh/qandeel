# content/quran — source record

**Never edit these files** (CLAUDE.md §1). They are verbatim downloads.
To update: download again with the same options, replace the files, copy them to
`app/assets/quran/`, update this page, and run `flutter test` (the tests check
that both copies are identical and that the counts are right).

## quran-uthmani.txt
- Source: Tanzil Project — https://tanzil.net
- Text: Tanzil Quran Text (Uthmani, Version 1.1) — see the copyright block at the end of the file.
- License: Creative Commons Attribution 3.0 — verbatim copies only, changing it is not allowed;
  credit Tanzil and link to tanzil.net.
- Download URL: `https://tanzil.net/pub/download/index.php?quranType=uthmani&outType=txt-2&agree=true`
  (default options; format `sura|aya|text`, one verse per line, LF line endings).
- Downloaded: 2026-11-11
- Size: 1,370,878 bytes
- SHA-256: `bf4f57b968d03f4131c070b1e285da9be0e0a108a21c910e872801ca273312c8`
- Contents: 114 surahs, 6,236 verses.

### Basmala note
In this file, verse 1 of every surah except 1 (Al-Fatiha, where it *is* verse 1) and
9 (At-Tawbah, which has none) **starts with the basmala** followed by a space.
Tanzil offers no download without it. The file is left unchanged; the app splits
the first four words off for display as a header (`lib/quran/quran.dart`,
`Verse.basmalaHeader`), and a test proves header + " " + rest equals the stored line.
In 95:1 and 97:1 the stored basmala begins `بِّسْمِ` (with shaddah); the header shows it
exactly as stored.

## quran-simple-clean.txt (search only — never displayed)
- Source: Tanzil Project — https://tanzil.net
- Text: Tanzil Quran Text (Simple Clean, Version 1.1) — the same verses without diacritics.
  Copyright block at the end of the file.
- License: Creative Commons Attribution 3.0 (same terms as above).
- Download URL: `https://tanzil.net/pub/download/index.php?quranType=simple-clean&outType=txt-2&agree=true`
- Downloaded: 2026-11-11 (owner approved using it for search, 2026-11-11)
- Size: 781,176 bytes
- SHA-256: `228df2a717671aeb9d2ff573002bd28d6b3f973f4bc7153554e3a81663d67610`
- Use: only to *find* verses when the user types Arabic without diacritics. Results always show the
  Uthmani text from quran-uthmani.txt. A test checks both files list the same 6,236 verses in the
  same order. Like the Uthmani file, verse 1 of each surah (except 1 and 9) starts with the basmala;
  search skips those four words so searching "بسم الله" finds 1:1 and 27:30, not every surah.

## quran-data.xml
- Source: Tanzil Project — https://tanzil.net/res/text/metadata/quran-data.xml
- Metadata version 1.0, "(C) 2008-2009 Tanzil.info", license cc-by.
- Contains: surah names (Arabic, transliterated, English), verse counts, revelation type,
  juz, hizb quarters, manzils, rukus, the 604 page starts of the Madinah mushaf, sajdas.
- Downloaded: 2026-11-11
- Size: 77,234 bytes (CRLF line endings — keep them)
- SHA-256: `8867c1d88191472adec9db694b3cd9f135b1a2ef580574d32cf888dcb22c5c7a`

## Owner to-do
- Save the Tanzil license/terms page to Google Drive → "01 Licenses & permissions".
