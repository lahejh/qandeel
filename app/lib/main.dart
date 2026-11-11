import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'audio/audio_files.dart';
import 'audio/just_audio_backend.dart';
import 'audio/network_check.dart';
import 'audio/recitation_controller.dart';
import 'quran/quran.dart';
import 'quran/quran_search.dart';
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
  final search = await QuranSearch.load(quran);
  // Saved on this phone only (settings, last page, bookmarks).
  final store = await DeviceStore.open();
  final settings = AppSettings.load(store);
  // Recitation files live in the app's private folder (never shared).
  final support = await getApplicationSupportDirectory();
  final files = AudioFiles(Directory('${support.path}/audio'));
  final recitation = RecitationController(
    quran: quran,
    settings: settings,
    files: files,
    fetcher: AudioFetcher(files),
    backend: JustAudioBackend(),
    canSaveOnThisNetwork: () => canSaveOnThisNetwork(settings),
  );
  runApp(
    QandeelApp(
      quran: quran,
      search: search,
      recitation: recitation,
      settings: settings,
      reading: ReadingState.load(store),
    ),
  );
}
