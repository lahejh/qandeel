import 'package:flutter/material.dart';

import 'app.dart';
import 'quran/quran.dart';

/// Qandeel (قنديل) — a free Quran & Azkar app for the whole family.
///
/// Read CLAUDE.md and docs/PLAN.md in the repository root before changing
/// anything. The app must stay free, private and offline-first.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The verified Quran text is bundled with the app and loaded once.
  final quran = await Quran.load();
  runApp(QandeelApp(quran: quran));
}
