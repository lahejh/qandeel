# Next steps — handover (2026-11-11)

Read `CLAUDE.md` (rules) and `docs/PLAN.md` (full plan) first.

## Decision: one complete release
Build everything planned (reader, azkar, audio, memorization, kids + games, library) and release once,
not version by version. Build in dependency order, test each part, commit after each working step.

## Done so far
- Repo, docs, CLAUDE.md, GPL-3.0, CI (analyze + test + debug APK on every push).
- Flutter app in `app/`: package `io.github.lahejh.qandeel` (owner to confirm before first release).
- English + Arabic, full RTL, light/dark, settings (in memory only).
- Home dashboard with OpenArt artwork (day courtyard / night lantern), time-aware greeting and azkar card,
  five tabs (Home, Quran, Azkar, Memorize, Kids), bundled fonts (IBM Plex Sans/Arabic, Amiri), lantern app icon.
- Design canvas (reference): https://claude.ai/artifact/Kj5z8UbAqfRNkKQ9GXBAvg

## Build order
1. **Quran reader** — verified text, mushaf pages, surah/juz index, bookmark, last-read position
   (home card switches from "Start reading" to "Continue reading").
2. Search (surah names, Arabic words).
3. Azkar — verified Hisn al-Muslim file, one dhikr per screen, tap counter, references; local reminders.
4. Settings saved on device (small storage package — ask owner first, per CLAUDE.md).
5. Recitation audio — King Fahd Complex + backups, stream/download once, highlight, repeat; monthly source check.
6. Memorization tools, then the Listen engine (on-device; ship only if accuracy test passes).
7. Kids section + games (spot-the-difference engine with random layered scenes, word order, build-a-masjid, jigsaw).
8. Library (HadeethEnc etc.), then release prep (final icon files, store listings, privacy page, test builds).

## Notes for step 1 (Quran text)
- Tanzil download URL used: `https://tanzil.net/pub/download/index.php?quranType=uthmani&outType=txt-2&agree=true`
  (format `sura|aya|text`, copyright block at the end — keep it verbatim in the asset file).
- In that file, verse 1 of each surah (except 1 and 9) **starts with the basmala** prepended.
  Decide how to show the basmala as a separate header WITHOUT editing the file — e.g. download the variant
  without it if Tanzil offers one, or handle it in display code with a test proving the stored text is unchanged.
  Ask the owner if unsure.
- Tanzil form options seen: marks, sajdah, rub, alef, tatweel, stanween, laa. Also get `quran-data.xml`
  (sura names, juz, hizb, page starts for the Madinah 604-page mushaf).
- Exact 15-line Madinah layout needs a page/line layout dataset (e.g. Tarteel's open QUL mushaf layout) and
  the KFGQPC fonts — check both licenses and save copies to Google Drive before using.
- Required tests: 114 surahs, 6,236 verses, spot-check verses byte-for-byte against the source file.

## Owner to-do (outside the code)
- Google Drive folder "Qandeel": save license pages (Tanzil, QuranEnc, King Fahd Complex audio, OpenArt terms, fonts).
- Permission emails: HadeethEnc, mp3quran.net, IslamHouse (azkar translations).
- Google Play developer account (~$25) for test releases.
- Masjid/charity conversation (see docs/CARETAKERS.md).
