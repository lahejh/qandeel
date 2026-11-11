# Workflow — two PCs, GitHub, Google Drive

**Rule:** GitHub = everything the app is built from. Google Drive = everything else. PCs = working copies.

## One-time setup on each PC (xhbl and pc1)
1. Install: Git, Flutter SDK, Android Studio (Android SDK + emulator), VS Code (optional), Claude Code.
2. Clone the repo to the same place on both PCs: `C:\Users\<you>\source\qandeel`.
3. Do NOT put the repo inside a Google Drive synced folder.
4. Check: `flutter doctor` should show Android toolchain OK. (iOS builds run on GitHub Actions — no Mac needed.)

## Every session
1. `git pull` (get the other PC's work).
2. Open Claude Code in the repo folder and work in small steps.
3. Run tests; commit with a clear message; `git push`.
4. Don't work on the same feature on both PCs at once.

## Google Drive folder "Qandeel"
- 01 Licenses & permissions — copies of every license page / permission email
- 02 Source content — original downloads (Tanzil, QuranEnc, HadeethEnc, azkar)
- 03 Audio recordings — masters from narrators and kids lessons
- 04 Design — scene layer files, icons, store screenshots
- 05 Store listings — descriptions per language
- 06 Keys — ENCRYPTED archive only (Android keystore, Apple certificates); password in password manager
- 07 Organization & legacy — masjid/charity agreement, caretaker instructions
- 08 Listen test clips — only with consent of each person recorded

## Where builds happen
- Android: locally (Android Studio / `flutter build`) or GitHub Actions.
- iPhone: GitHub Actions macOS runners (free for public repos). Test on a real iPhone via TestFlight.
