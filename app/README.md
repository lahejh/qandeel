# app/ — Qandeel Flutter app

Package id: `io.github.lahejh.qandeel` (based on the free `lahejh.github.io` address).
Display name: "Qandeel". Languages: English + Arabic (full right-to-left).

## Run it
```
cd app
flutter pub get
flutter test        # all tests must pass before every commit
flutter run         # on an Android emulator or connected phone
```
iPhone builds run on GitHub Actions (no Mac needed).

## Layout
| Path | What |
|---|---|
| `lib/main.dart` | Entry point |
| `lib/app.dart` | MaterialApp: themes, languages, RTL |
| `lib/theme.dart` | Colors (deep green + lantern gold) |
| `lib/home/` | Main screen with Quran / Azkar / Memorize / Kids tabs |
| `lib/settings/` | Language and theme settings |
| `lib/l10n/` | Interface text: `app_en.arb`, `app_ar.arb` (UI only — never Quran/azkar text) |
| `test/` | Widget tests |

Interface text lives only in the `.arb` files. To add a language, add `app_xx.arb`
(reviewed by a native speaker) and add the locale to `AppSettings.supportedLocales`.
