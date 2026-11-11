# Yearly update guide

Both stores require yearly updates. If they're missed, the app stops reaching new users or can't be updated.
Anyone with Claude Code can do this — about one day of work.

## When
- **October** — after Apple's new iOS release (Apple requires the newest Xcode/SDK for uploads each spring).
- **June** — before Google Play's yearly target-API deadline (usually 31 August).
- Also: read every email from Apple / Google developer accounts — they warn months ahead.
- Apple also removes apps not updated for ~3 years with very low downloads — another reason to update yearly.

## Steps
1. `git pull` on your PC.
2. Update Flutter (`flutter upgrade`) and Android Studio.
3. In Claude Code, ask:
   > "Update Flutter and all packages to the latest versions, raise the Android target SDK and iOS deployment
   > target to what the stores now require, fix any warnings, and run all tests. Do not touch content/."
4. Test on a real Android phone and a real iPhone (TestFlight). Check: Quran text, audio, azkar, kids section.
5. Bump the version number, commit, push. GitHub Actions builds both apps.
6. Upload to Google Play (internal test → production) and App Store Connect (TestFlight → review).
7. Refresh QuranEnc translations if a newer version exists (their terms require it).
8. Check the monthly audio-source issues on GitHub are all closed.
9. Renew Apple membership (or fee waiver) if due.
