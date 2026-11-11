# Next steps — handover (updated 2026-11-11, after steps 1, 2 and saved settings)

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
- **Step 1 — Quran reader (done, first pass):**
  - `content/quran/`: Tanzil Uthmani 1.1 text + `quran-data.xml`, verbatim, with `SOURCE.md` (sizes, SHA-256).
    `app/assets/quran/` holds exact copies; a test fails if they differ. `.gitattributes` stops git
    changing line endings in these files on Windows.
  - `app/lib/quran/`: `quran.dart` (loader + checks), `reader_screen.dart` (604 mushaf pages, swipe
    like a printed mushaf, surah headers, basmala header, verse markers, tap verse to bookmark),
    `quran_index_screen.dart` (Surahs / Juz / Bookmarks tabs), `reading_state.dart` (last page +
    bookmarks — **in memory only until step 4**), `quran_scope.dart`.
  - Basmala: shown as a header by splitting the first four words of verse 1 in display code; the file
    is unchanged. Test proves header + " " + rest == stored line for all 112 surahs. Note: 95:1 and
    97:1 store the basmala as `بِّسْمِ` (with shaddah) — shown exactly as stored.
  - Home card switches to "Continue reading" (surah, page, juz) once the reader is opened.
  - Settings → "About & sources" credits Tanzil (required by its license).
  - Tests: 114 surahs, 6,236 verses, every verse byte-for-byte against the raw file, spot checks,
    page/juz metadata, widget tests for reader, index, bookmarks, Arabic UI (20 tests).

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

- **Saved on device (part of step 4, owner approved `shared_preferences` 2026-11-11):** settings
  (language, theme, Quran text size), last-read page and bookmarks. All storage goes through
  `lib/storage/local_store.dart`; every stored key is listed in `StoreKeys`.
- **Step 2 — Search (done):** Tanzil Simple Clean 1.1 added verbatim (owner approved) and used only
  for matching; results show Uthmani text. Surah names (Arabic/English/transliterated/number),
  references like 2:255, Arabic words without diacritics. Search icon on the Quran tab.

## Owner decisions (2026-11-11)
- `shared_preferences`: approved. Tanzil simple-clean for search: approved.
- `flutter_local_notifications` (azkar reminders): **not yet** — build azkar without reminders.
- Azkar source: no emails. Shamela import declined; GPL Hisn Elmoslem database chosen with full verification.
- Quran passages inside azkar: owner chose the book's own text exactly (changed from Tanzil).
- Next step after azkar import: recitation audio (step 5).

## Azkar — chosen source (2026-11-11)
- Owner: no permission emails; use the GPL-3.0 database from the open-source Hisn Elmoslem app
  (muslimpack/HisnElmoslem_App), **but verify it 100% against other sources first**.
- Imported verbatim: `content/azkar/hisn_elmoslem.db` (+ `SOURCE.md`). Not shown in the app yet.
- `tools/verify_azkar.py` compares all 335 entries with Shamela (author's Safir edition + his
  footnotes) and hisnmuslim.com → `docs/azkar-verification.md`. First run: 243 identical incl.
  diacritics, 42 diacritics differ, 34 letters differ, 16 Quran placeholders; 24 references with
  extra text; 20 count differences; 26 special-font codes in references.
- Next: a reviewer checks every flagged item in the printed book and fills `content/azkar/REVIEW.md`.
- Owner decisions (2026-11-11, later): (1) Quran passages inside azkar (`QuranText[...]`
  placeholders) are shown from the verified **Tanzil Uthmani text** (replaces "book's text
  exactly", which this database cannot provide); (2) special-font codes are displayed as the **full
  words** (‘ رحمه الله, ’ رضي الله عنها, ^ رضي الله عنهما, × صلى الله عليه وسلم) by display code with
  a test — the stored file is never changed; (3) the review against the printed book is
  **postponed** — azkar stays hidden until `content/azkar/REVIEW.md` covers every flagged item.
- Still open: reading SQLite in the app needs a package (`sqflite`/`sqlite3`) or a tested lossless
  export to JSON — ask the owner when building the azkar screens; the developer's grading field is
  not shown.

## Azkar source candidates considered (2026-11-11)
Book: Hisn al-Muslim, Sa'id ibn Ali ibn Wahf al-Qahtani; 132 chapters, dhikr numbered 1–267.
1. **Author's printed edition (Safir Press, Riyadh) as digitized on Shamela/Turath, shown on usul.ai**
   (https://usul.ai/t/fortress-of-the-muslim-1). Numbering matches the print; every dhikr has the
   author's reference footnote. Arabic only; repeat counts are inside the text (e.g. "ثلاثًا").
   No license stated on usul.ai (site footer: Seemore Foundation). Needs: confirm the book's own
   distribution statement + ask usul.ai/Turath for a structured copy or permission.
2. **hisnmuslim.com JSON API** (`/api/ar/husn_ar.json`, `/api/ar/{chapter}.json`, also `/api/en/…`).
   Arabic + English (+ other languages on the site), REPEAT field, per-dhikr audio (Hamad Al-Duraihim).
   IDs follow the book's numbering (checked: 1–4 waking, 99+ sleep). **No references**, no operator
   or terms on the site → needs a permission email; references would have to come from the book.
3. **IslamHouse "حصن المسلم - إصدار 2"** (https://enc.islamhouse.com/en/books/819/1). Same group as
   QuranEnc/HadeethEnc; versioned; author's takhrij; many reviewed translations on islamhouse.com.
   No structured download found → email IslamHouse (already on the owner to-do list).
4. sunnah.com Hisn al-Muslim (Arabic + English + references): copies on GitHub/Hugging Face are
   scrapes with unclear licenses — not recommended.
Note: some azkar are whole Quran passages (Ayat al-Kursi, the three Quls). Proposal: show those from
the Tanzil Uthmani text by verse reference, not from the azkar file (CLAUDE.md §1).

## Step 5 — Recitation audio: research (2026-11-11)
- **King Fahd Complex (main source):** usage license (old site, qurancomplex.gov.sa/en/?p=3979) offered
  the recordings for free general use in apps, websites and broadcasting. The old site offered per
  reciter "whole mushaf as ayat" and "as surahs" zips (≈0.7–1.2 GB each) — so per-verse files exist —
  for Hafs murattal: Ali Al-Huthaify, Mohammed Ayyoub, Maher Al-Muaiqly, Khalid Al-Muhanna (+ other
  riwayat). **As of 2026-11-11 the site is rebuilt ("trial launch"); recitations, fonts and the
  developer platform are all "coming soon". No official download is reachable now.** The old pages
  (e.g. /sounds-hafs-huthify/) return 404, also in a real browser.
- **Islamic Network / alquran.cloud (backup 1):** per-verse CDN
  `https://cdn.islamic.network/quran/audio/{bitrate}/{edition}/{1..6236}.mp3` (global verse number),
  ETag = MD5 (usable as checksum). Has the same Hafs reciters as the Complex: `ar.hudhaify`,
  `ar.mahermuaiqly`, `ar.muhammadayyoub` (+ Husary, Minshawi-style others). Files come from
  EveryAyah; terms: free, key-less, cache aggressively; recordings keep their own copyrights.
- mp3quran.net (backup 2): still needs written permission — owner chose no emails for now.

## Step 5 — Recitation audio: built (2026-11-11)
- Owner decisions: Islamic Network now, King Fahd Complex as source #1 again when its files return;
  packages `just_audio`, `path_provider`, `http` approved (`crypto`, Dart team, used for MD5 — it was
  already pulled in by these); default reciter **Mahmoud Khalil Al-Husary** (best for children).
- Reciters: Al-Husary, Ali Al-Huthaify, Maher Al-Muaiqly, Muhammad Ayyoub (Hafs, murattal, 128 kbps).
  To add the Complex later: give its `ReciterSource` URLs in `app/lib/audio/reciters.dart` and put it
  first in each reciter's `sources` list — nothing else changes.
- `lib/audio/`: `reciters.dart` (catalogue + source order), `audio_files.dart` (one file per verse in
  the app's private folder, MD5 check against the ETag, same-reciter failover, "connect to download"),
  `recitation_controller.dart` (play from verse / page, repeat verse or page 3/5/10×, saved file →
  download-once or stream → message; asks before switching reciter, never automatic),
  `just_audio_backend.dart`, `player_bar.dart` (verse, reciter · source credit, pause/stop),
  `downloads_screen.dart` (size per reciter, delete).
- Reader follows the recited verse across pages and highlights it. Settings: reciter, "Save
  recitations on this phone" (default on = stream and save; off = stream only), Saved recitations.
- Monthly GitHub Action `audio-sources.yml` runs `tools/check_audio_sources.py` (sample verses of
  every reciter/source, MD5) and opens an issue on failure.
- Android release manifest now has INTERNET (only for recitation the user taps).
- "Save only on Wi-Fi" (default on): `connectivity_plus` approved 2026-11-11
  (`lib/audio/network_check.dart`). On mobile data recitation streams without saving.
  **Note for CLAUDE.md §2:** this package adds Android's ACCESS_NETWORK_STATE permission (automatic,
  no prompt, tells the app only Wi-Fi vs mobile data; no user data). Owner to confirm/add to the list.
  Background playback / lock-screen controls would need `just_audio_background` (not added).

## Still open from step 1
- Quran font is Amiri for now. Switch to KFGQPC Uthmanic font once its license page is saved to Drive.
- Exact 15-line Madinah page layout (needs QUL line-layout data + KFGQPC fonts; check licenses first).
  Today each page shows the right verses for that mushaf page, flowing as text.
- Reader text size setting (with step 4, so it is saved).
- New Arabic UI strings (reader, index, sources) need native-speaker review.

## Notes for step 1 (Quran text) — kept for reference
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
