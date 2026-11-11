# Qandeel (قنديل) — Quran & Azkar

*Qandeel* means "lantern".

A free Quran & azkar app for the whole family — reading, azkar, recitation, memorization,
a kids section and an Islamic library — for iPhone and Android. Built as sadaqah jariyah.

- **Free forever.** No ads, no purchases, no subscriptions.
- **Private.** No account, no location, no tracking. Works offline.
- **Accurate.** Quran text and translations come only from verified sources and are never edited.

## Repository layout
| Folder | What's inside |
|---|---|
| `app/` | Flutter app (created with `flutter create`) |
| `content/` | Quran text, translations, azkar, hadith, stories, cards — from verified sources only |
| `levels/` | Kids game data (spot-the-difference scenes, change spots, variants) |
| `tools/` | Scripts (content import, checksum lists, test helpers) |
| `site/` | Website and privacy policy (GitHub Pages) |
| `.github/workflows/` | Automatic Android/iOS builds and the monthly audio-source check |
| `docs/` | Plan, content sources, workflow, yearly update guide, caretaker guide |

## Start here
1. Read `CLAUDE.md` (rules) and `docs/PLAN.md` (what we're building).
2. Set up your PC: `docs/WORKFLOW.md`.
3. What to build next: `docs/NEXT-STEPS.md`.
4. Yearly maintenance: `docs/YEARLY-UPDATE.md`.
5. Taking over this project? Read `docs/CARETAKERS.md`.

## License
Code: GPL-3.0 (see `LICENSE`). Content (Quran text, translations, audio, hadith) keeps its own
licenses and attribution requirements — see `docs/CONTENT-SOURCES.md`.
