# Workflows
- ci.yml — (active) on every push: flutter analyze, flutter test, build a debug Android APK (downloadable from the Actions run).

## Planned
- build-android.yml — build APK/AAB on every push to main.
- build-ios.yml — build iOS on macOS runners (free for public repos); upload to TestFlight with secrets.
- check-audio-sources.yml — 1st of every month (+ manual): download sample files per reciter per source,
  verify HTTP 200 / non-empty / checksum; open or update a GitHub Issue on failure, close it when it passes.
