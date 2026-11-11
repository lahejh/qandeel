import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qandeel/app.dart';
import 'package:qandeel/audio/audio_files.dart';
import 'package:qandeel/audio/downloads_screen.dart';
import 'package:qandeel/audio/recitation_controller.dart';
import 'package:qandeel/audio/reciters.dart';
import 'package:qandeel/quran/quran.dart';
import 'package:qandeel/quran/quran_search.dart';
import 'package:qandeel/quran/reader_screen.dart';
import 'package:qandeel/quran/reading_state.dart';
import 'package:qandeel/settings/app_settings.dart';

final quran = Quran.parse(
  text: File('assets/quran/quran-uthmani.txt').readAsStringSync(),
  metadata: File('assets/quran/quran-data.xml').readAsStringSync(),
);
final search = QuranSearch.parse(
  quran,
  File('assets/quran/quran-simple-clean.txt').readAsStringSync(),
);

/// Backend that "plays" until told to finish, so the bar can be inspected.
class HoldingBackend implements AudioBackend {
  final played = <String>[];
  @override
  Future<void> play(PlayableAudio audio) async {
    played.add(audio.file?.path.split('/').last ?? audio.uri.toString());
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}

void main() {
  late Directory tmp;
  late AudioFiles files;
  setUp(() {
    tmp = Directory.systemTemp.createTempSync('qandeel_ui');
    files = AudioFiles(Directory('${tmp.path}/audio'));
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  RecitationController controller(
    AppSettings settings,
    http.Client client,
    AudioBackend backend,
  ) => RecitationController(
    quran: quran,
    settings: settings,
    files: files,
    fetcher: AudioFetcher(files, client: client),
    backend: backend,
    isOffline: () async => false,
  );

  Widget app(
    AppSettings settings,
    RecitationController c, {
    ReadingState? reading,
  }) => QandeelApp(
    quran: quran,
    search: search,
    settings: settings,
    recitation: c,
    reading: reading,
    now: DateTime(2026, 11, 11, 8),
  );

  testWidgets(
    'verse menu offers recitation; player bar credits reciter and source',
    (tester) async {
      final settings = AppSettings(
        locale: const Locale('en'),
        saveRecitations: false,
      );
      final backend = HoldingBackend();
      final c = controller(
        settings,
        MockClient((_) async => http.Response('', 200)),
        backend,
      );
      await tester.pumpWidget(app(settings, c));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      // Tap verse 1:2 to open its menu.
      await tester.tapOnText(
        find.textRange.ofSubstring(
          quran.verse(const VerseRef(1, 2)).displayText,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Play from here'), findsOneWidget);
      expect(find.text('Play this page'), findsOneWidget);
      expect(find.text('Repeat this verse'), findsOneWidget);

      await tester.tap(find.text('Play from here'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // menu closes
      expect(find.text('Surah Al-Faatiha, verse 2'), findsOneWidget);
      expect(
        find.textContaining('Mahmoud Khalil Al-Husary · Islamic Network'),
        findsOneWidget,
      );
      expect(backend.played.single, endsWith('/ar.husary/2.mp3'));

      await tester.tap(find.byTooltip('Stop'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Surah Al-Faatiha, verse 2'), findsNothing);
    },
  );

  testWidgets('unavailable reciter: asks, switches only if the user chooses', (
    tester,
  ) async {
    final settings = AppSettings(
      locale: const Locale('en'),
      reciterId: 'ayyoub',
    );
    final c = controller(
      settings,
      MockClient((_) async => http.Response('', 404)),
      HoldingBackend(),
    );
    await tester.pumpWidget(app(settings, c));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    await c.playFrom(const VerseRef(1, 1));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Recitation by Muhammad Ayyoub is not available'),
      findsOneWidget,
    );
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(settings.reciterId, 'ayyoub');

    await c.playFrom(const VerseRef(1, 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ali Al-Huthaify'));
    await tester.pumpAndSettle();
    expect(settings.reciterId, 'huthaify');
  });

  testWidgets('offline and not saved: "connect to download" message', (
    tester,
  ) async {
    final settings = AppSettings(locale: const Locale('en'));
    final c = RecitationController(
      quran: quran,
      settings: settings,
      files: files,
      fetcher: AudioFetcher(
        files,
        client: MockClient((_) async => throw const SocketException('x')),
      ),
      backend: HoldingBackend(),
      isOffline: () async => true,
    );
    await tester.pumpWidget(app(settings, c));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await c.playFrom(const VerseRef(1, 1));
    await tester.pump();
    await tester.pump();
    expect(
      find.textContaining('Connect to the internet to download it'),
      findsOneWidget,
    );
  });

  testWidgets('settings: reciter, save switch, saved recitations with delete', (
    tester,
  ) async {
    final settings = AppSettings(locale: const Locale('en'));
    final ok = MockClient(
      (req) async => http.Response.bytes(
        [1, 2, 3],
        200,
        headers: {
          'etag': '"${md5.convert([1, 2, 3])}"',
        },
      ),
    );
    final c = controller(settings, ok, HoldingBackend());
    await tester.runAsync(
      () => c.fetcher.fetch(Reciters.husary, quran.verses.first),
    );
    await tester.pumpWidget(app(settings, c));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Maher Al-Muaiqly'), 100);
    await tester.ensureVisible(find.text('Maher Al-Muaiqly'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Maher Al-Muaiqly'));
    await tester.pumpAndSettle();
    expect(settings.reciterId, 'muaiqly');

    await tester.scrollUntilVisible(
      find.text('Save recitations on this phone'),
      100,
    );
    await tester.tap(find.text('Save recitations on this phone'));
    await tester.pumpAndSettle();
    expect(settings.saveRecitations, isFalse);

    await tester.scrollUntilVisible(find.text('Saved recitations'), 100);
    await tester.ensureVisible(find.text('Saved recitations'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved recitations'));
    await tester.pumpAndSettle();
    expect(find.byType(DownloadsScreen), findsOneWidget);
    expect(find.textContaining('1 verses'), findsOneWidget);
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    // Let the real file deletion finish, then redraw.
    for (var i = 0; i < 5 && files.usage(Reciters.husary).files > 0; i++) {
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
    }
    await tester.pumpAndSettle();
    expect(files.usage(Reciters.husary).files, 0);
    expect(find.text('Nothing saved'), findsNWidgets(4));
  });

  testWidgets('reader without audio (no controller) still works', (
    tester,
  ) async {
    await tester.pumpWidget(
      QandeelApp(
        quran: quran,
        search: search,
        settings: AppSettings(locale: const Locale('en')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.byType(ReaderScreen), findsOneWidget);
  });
}
