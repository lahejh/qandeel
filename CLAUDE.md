# CLAUDE.md — rules for this project

Read this first, every session. These rules are non-negotiable unless the owner changes this file.

## What this is
A free Quran & azkar app for the whole family (reading, azkar, recitation, memorization, kids, library),
built with Flutter for iPhone and Android, published as sadaqah jariyah.
App name: **Qandeel (قنديل)** — "lantern". Store name format: "Qandeel: Quran & Azkar". Repo/folder: qandeel.
Full plan: docs/PLAN.md. License: GPL-3.0 (code). Content keeps its own licenses (docs/CONTENT-SOURCES.md).

## 1. Sacred text (most important)
- NEVER write, generate, retype, "fix" or reformat Quran text, translations, tafsir, hadith or azkar.
- Quran text comes ONLY from content/quran/ (Tanzil.net, Uthmani). Load it; never edit it.
- Translations ONLY from content/translations/ (QuranEnc.com). Show source + version for each.
- Azkar ONLY from content/azkar/; hadith ONLY from content/hadith/; stories ONLY from content/stories/.
- Every dhikr/hadith shows its reference. Keep all source/copyright notices.
- If something in the text looks wrong: STOP and tell the owner. Do not change it.
- Write tests that verify: 114 surahs, 6,236 verses, and spot-check verses match the source file exactly.

## 2. Privacy
- No ads, no analytics, no crash reporting, no third-party SDKs (no Firebase, no Google/Facebook SDKs).
- No accounts or login. All user data (bookmarks, progress, settings) stays on the device.
- No network activity unless the user taps play or download.
- Permissions allowed: local notifications (azkar reminders). Microphone ONLY for the Listen feature,
  ONLY when the user taps, processed on device, never saved or uploaded. Nothing else (no location, contacts, photos).
- Before adding any package: tell the owner what it does and whether it sends data anywhere.
- Store label target: "Data Not Collected".

## 3. Free forever
- No in-app purchases, subscriptions, ads, locked content, or "premium".

## 4. Audio
- Sources in order: 1) King Fahd Glorious Qur'an Printing Complex, 2) Islamic Network / alquran.cloud,
  3) mp3quran.net (only after written permission). Credit reciter + source in the app.
- On failure, try the SAME reciter on the next source; if none has it, ASK the user before switching reciter.
- Play: local file if downloaded -> else stream if online -> else "connect to download" message.
- Setting: "Stream only" / "Stream and save" (default save). Each file downloaded once. Wi-Fi-only toggle (default on).
- One file per verse where possible; verify downloads with checksums. Storage screen with delete per reciter.
- Never use AI/TTS voices for Quran recitation.

## 5. Languages & layout
- Flutter localization (ARB files). Arabic + English first.
- Full RTL support from day one (Arabic, Urdu, Persian).
- Never machine-translate Quran/azkar/hadith content. UI translations are reviewed by native speakers.
- Fonts: KFGQPC for Quran text.

## 6. Kids section
- Behind a parent gate (exit kids mode, settings, downloads, links).
- NO images of people, faces, animals or birds anywhere. Exception: a faceless, modest human figure
  ONLY in wudu/salah lessons (boy and girl versions).
- NEVER depict prophets, angels or Companions in any form. Stories show places and objects only.
- No character/animal guide: voice + simple text only. No music (voice and gentle sound effects only).
- No leaderboards, no social features, no purchases, no "game over", no lives, no pressure timers,
  no streaks that reset, no guilt messages. Parent-set daily time limit; calm, easy exit.
- Quran words/verses are NEVER popped, shot, smashed, dropped or used as obstacles.
  Only respectful actions: choose, place, arrange. After a Quran answer, play the correct recitation.
- Spot-the-difference: random scenes and random differences from defined "change spots";
  calligraphy of Quran / names of Allah / the Prophet's name are LOCKED (never a difference);
  Ka'bah and Masjid an-Nabawi are never altered. Every generated puzzle must be solvable.

## 7. AI in the app
- Allowed on device only: Quran-specific speech model (recitation following, recite-to-find with top-3 results),
  OS text-to-speech for translations (never Quran), letter-tracing check, spaced-repetition review.
- Never: cloud AI, chatbots, AI fatwas, AI-generated religious content shown to users without human review.

## 8. Code & repo
- Flutter app lives in app/. Keep dependencies minimal so yearly updates stay easy.
- NEVER commit keys, certificates, keystores, passwords or server credentials. Use GitHub Secrets in CI.
- Large media masters stay in Google Drive (not git).
- Write clear comments and keep docs/ up to date so future caretakers can maintain the app.
- After each working step: run tests, then commit with a clear message.

## 9. Two-PC workflow
- PCs "xhbl" and "pc1" each have a clone of this repo. Start: git pull. End: commit + push.
- Never put this repo inside a Google Drive synced folder.
