# Qandeel (قنديل) — Plan and Decisions

App name: Qandeel ("lantern"). Store name: "Qandeel: Quran & Azkar".

(Master copy also kept in the claude.ai project "Quran app public".)

Free app built as sadaqah jariyah, for the whole family. Built with Claude Code (Flutter) for iPhone and Android.

## Principles
- Free forever. No ads, no purchases, no subscriptions.
- Privacy: no account, no location, no tracking, no analytics, no third-party SDKs. Store label: "Data Not Collected".
- Network only when the user taps play/download.
- Sacred text is never typed, generated or edited by AI; only loaded from verified source files.

## Content sources
See docs/CONTENT-SOURCES.md.

## Audio
- Main: King Fahd Glorious Qur'an Printing Complex. Backup 1: Islamic Network / alquran.cloud. Backup 2: mp3quran.net (after written permission).
- Failover tries the same reciter on the next source; ask user before switching reciter.
- Stream online or download once; Wi-Fi-only option; storage screen.
- Check early whether King Fahd files are per surah or per verse (timing files needed if per surah).
- Monthly GitHub Action checks all sources; opens a GitHub Issue on failure.

## Languages
- Interface: Arabic + English first; then Urdu, Indonesian, Turkish, French, Bengali, and more.
- Full RTL support. Native-speaker review. Never machine-translate Quran/azkar.

## Roadmap (build order — released together as ONE complete release, see docs/NEXT-STEPS.md)
- v1: Quran reader, azkar with counters, reminders, bookmarks, search, Arabic + English, dark mode.
- v2: Recitation (stream / download once), repeat & range play, more languages and translations.
- v3: Memorization: hide mode, "what comes next", progress map, revision planner, backup export. Plus "Listen" engine.
- v4: Kids section.
- v5: Library (hadith, seerah, moral stories).
- Later: Quran Radio (own audio), prayer times (city list, no GPS).

## Listen engine (on-device Quran speech recognition)
- Recitation following: highlights where the user is; helps memorization. Does not judge tajweed.
- Recite-to-find: user recites a few words; app shows top 3 matching verses; user taps the right one. Never auto-jumps.
- Quran-specific model matched against the 6,236 verses. Microphone only on tap; on device; audio never saved/uploaded.
- Ship only if testing passes: 100+ clips from varied voices; top-3 accuracy 90%+. Typed search stays the main search.

## AI usage
- Build time (human-reviewed): topic tags, kids quiz content, story drafts, UI translations.
- On device: OS text-to-speech for translations only (never Quran), letter-tracing check, spaced-repetition review.
- Never: cloud AI or chatbots in the app; AI fatwas; AI voice reciting Quran.

## Kids section (v4)
- Inside the main app, behind a parent gate.
- Games: ayah word-order puzzle, build-a-masjid, masjid jigsaw, spot the difference. Candidates: five prayers through the day, sun & moon letters, memory cards, name that surah, "what would you do?".
- No animal or character guide; voice + text only. Wudu & prayer: faceless modest figure (boy/girl), English + Arabic.
- Quran stories: English + Arabic, male or female narrator, no music, real reciter audio for verses, scholar-reviewed, places/objects only.
- No animals/birds anywhere. No leaderboards, purchases, or microphone in Kids section. Quran words never popped/shot/smashed/dropped.

## Spot the difference (Kids + "Relax" mode for adults)
- Scenes: masjids of the world, inside a masjid, Ramadan night, Eid morning, Andalusian courtyards, geometric patterns, Islamic home, gardens.
- No people/animals. Quran calligraphy, names of Allah, the Prophet's ﷺ name are locked. Ka'bah and Masjid an-Nabawi never altered.
- Randomness: each scene has 15–25 change spots with several variants; each play picks random spots, variants and side; random time-of-day palette and arrangement; random cards between levels.
- Fairness: no overlaps, minimum size/contrast by difficulty, always solvable; automated test renders thousands of combinations.
- Difficulty: 3 big → 7 subtle differences. No timer, lives or penalty; hint glow. Found items speak their Arabic name + meaning.
- Between levels: dhikr phrase, Arabic word, short authentic hadith (with source), masjid fact — English + Arabic audio.

## Infrastructure
- Code: GitHub (public repo, GPL-3.0; secrets in GitHub Secrets). Builds: GitHub Actions (iOS via macOS runners).
- Website + privacy policy: GitHub Pages. Hetzner: optional mirror only. Google Drive: originals, licenses, encrypted keys.
- Workspace: see docs/WORKFLOW.md.

## Cost
- Google Play ~$25 once. Apple $99/year (waived for eligible nonprofits). Domain optional.

## Legacy
See docs/CARETAKERS.md.
