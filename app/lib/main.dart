import 'package:flutter/material.dart';

import 'app.dart';
import 'quran/quran.dart';
import 'quran/reading_state.dart';
import 'settings/app_settings.dart';
import 'storage/local_store.dart';

/// Qandeel (قنديل) — a free Quran & Azkar app for the whole family.
///
/// Read CLAUDE.md and docs/PLAN.md in the repository root before changing
/// anything. The app must stay free, private and offline-first.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The verified Quran text is bundled with the app and loaded once.
  final quran = await Quran.load();
  // Saved on this phone only (settings, last page, bookmarks).
  final store = await DeviceStore.open();
  runApp(
    QandeelApp(
      quran: quran,
      settings: AppSettings.load(store),
      reading: ReadingState.load(store),
    ),
  );
}
