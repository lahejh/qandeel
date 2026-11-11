import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qandeel/audio/audio_files.dart';
import 'package:qandeel/audio/recitation_controller.dart';
import 'package:qandeel/audio/reciters.dart';
import 'package:qandeel/quran/quran.dart';
import 'package:qandeel/settings/app_settings.dart';

final quran = Quran.parse(
  text: File('assets/quran/quran-uthmani.txt').readAsStringSync(),
  metadata: File('assets/quran/quran-data.xml').readAsStringSync(),
);

/// Fake audio bytes for a verse (not real audio; tests only).
List<int> bytesFor(Uri uri) => uri.toString().codeUnits;
String etagFor(Uri uri) => '"${md5.convert(bytesFor(uri))}"';

/// Two sources carrying the SAME reciter, for failover tests.
const twoSources = Reciter(
  id: 'test',
  nameArabic: 'اختبار',
  nameEnglish: 'Test',
  sources: [
    ReciterSource(AudioSourceKind.kingFahdComplex, 'none'), // no URLs yet
    ReciterSource(AudioSourceKind.islamicNetwork, 'first'),
    ReciterSource(AudioSourceKind.islamicNetwork, 'second'),
  ],
);

class FakeBackend implements AudioBackend {
  final played = <String>[];
  bool Function(PlayableAudio)? failWhen;

  @override
  Future<void> play(PlayableAudio audio) async {
    if (failWhen?.call(audio) ?? false) throw Exception('cannot load');
    played.add(audio.file?.path.split('/').last ?? audio.uri.toString());
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
    tmp = Directory.systemTemp.createTempSync('qandeel_audio');
    files = AudioFiles(Directory('${tmp.path}/audio'));
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  test('Islamic Network URLs use the global verse number', () {
    const s = ReciterSource(AudioSourceKind.islamicNetwork, 'ar.husary');
    expect(
      s.verseUri(quran.verse(const VerseRef(1, 1))).toString(),
      'https://cdn.islamic.network/quran/audio/128/ar.husary/1.mp3',
    );
    expect(
      s.verseUri(quran.verse(const VerseRef(2, 255))).path,
      endsWith('/262.mp3'),
    );
    expect(
      s.verseUri(quran.verse(const VerseRef(114, 6))).path,
      endsWith('/6236.mp3'),
    );
  });

  test('every offered reciter has at least one source with URLs', () {
    for (final r in Reciters.all) {
      final usable = r.sources.where((s) {
        try {
          s.verseUri(quran.verses.first);
          return true;
        } on UnsupportedError {
          return false;
        }
      });
      expect(usable, isNotEmpty, reason: r.id);
    }
    expect(Reciters.defaultReciter.id, 'husary');
    expect(Reciters.byId('unknown').id, 'husary');
  });

  test('checksum: ETag MD5 must match the bytes', () {
    final bytes = [1, 2, 3];
    final good = '"${md5.convert(bytes)}"';
    expect(checksumMatches(bytes, good), isTrue);
    expect(checksumMatches([1, 2, 4], good), isFalse);
    expect(checksumMatches(bytes, null), isTrue); // cannot check, non-empty
    expect(checksumMatches([], null), isFalse);
  });

  test('download is verified, saved once, then used offline', () async {
    var calls = 0;
    final client = MockClient((req) async {
      calls++;
      return http.Response.bytes(
        bytesFor(req.url),
        200,
        headers: {'etag': etagFor(req.url)},
      );
    });
    final fetcher = AudioFetcher(files, client: client);
    final verse = quran.verse(const VerseRef(1, 1));
    final first = await fetcher.fetch(Reciters.husary, verse);
    expect(first.file.path, endsWith('/husary/001001.mp3'));
    expect(first.file.existsSync(), isTrue);
    await fetcher.fetch(Reciters.husary, verse);
    expect(calls, 1);
    expect(files.usage(Reciters.husary).files, 1);
    await files.deleteAll(Reciters.husary);
    expect(files.usage(Reciters.husary).files, 0);
  });

  test(
    'failover: same reciter, next source; bad checksum is rejected',
    () async {
      final client = MockClient((req) async {
        if (req.url.path.contains('/first/')) {
          // Corrupted file: checksum does not match.
          return http.Response.bytes(
            [9, 9, 9],
            200,
            headers: {'etag': etagFor(req.url)},
          );
        }
        return http.Response.bytes(
          bytesFor(req.url),
          200,
          headers: {'etag': etagFor(req.url)},
        );
      });
      final got = await AudioFetcher(
        files,
        client: client,
      ).fetch(twoSources, quran.verse(const VerseRef(2, 1)));
      expect(got.source.edition, 'second');
    },
  );

  test(
    'all sources fail -> ReciterUnavailable; no connection -> NoConnection',
    () async {
      final notFound = AudioFetcher(
        files,
        client: MockClient((_) async => http.Response('', 404)),
      );
      expect(
        () => notFound.fetch(twoSources, quran.verses.first),
        throwsA(isA<ReciterUnavailable>()),
      );
      final offline = AudioFetcher(
        files,
        client: MockClient((_) async => throw const SocketException('offline')),
      );
      expect(
        () => offline.fetch(twoSources, quran.verses.first),
        throwsA(isA<NoConnection>()),
      );
    },
  );

  group('RecitationController', () {
    RecitationController make({
      required http.Client client,
      required AppSettings settings,
      FakeBackend? backend,
      bool offline = false,
    }) => RecitationController(
      quran: quran,
      settings: settings,
      files: files,
      fetcher: AudioFetcher(files, client: client),
      backend: backend ?? FakeBackend(),
      isOffline: () async => offline,
    );

    final okClient = MockClient(
      (req) async => http.Response.bytes(
        bytesFor(req.url),
        200,
        headers: {'etag': etagFor(req.url)},
      ),
    );

    test('plays a range in order with repeats (stream and save)', () async {
      final backend = FakeBackend();
      final c = make(
        client: okClient,
        settings: AppSettings(),
        backend: backend,
      );
      await c.playRange(
        const VerseRef(1, 1),
        const VerseRef(1, 3),
        repeatEach: 2,
      );
      expect(backend.played, [
        '001001.mp3',
        '001001.mp3',
        '001002.mp3',
        '001002.mp3',
        '001003.mp3',
        '001003.mp3',
      ]);
      expect(c.isActive, isFalse);
      expect(c.issue, RecitationIssue.none);
      expect(c.source?.kind, AudioSourceKind.islamicNetwork);
    });

    test('repeat range plays the whole range again', () async {
      final backend = FakeBackend();
      final c = make(
        client: okClient,
        settings: AppSettings(),
        backend: backend,
      );
      await c.playRange(
        const VerseRef(112, 1),
        const VerseRef(112, 2),
        repeatRange: 2,
      );
      expect(backend.played, [
        '112001.mp3',
        '112002.mp3',
        '112001.mp3',
        '112002.mp3',
      ]);
    });

    test('stream only: plays from the network, saves nothing', () async {
      final backend = FakeBackend();
      final c = make(
        client: okClient,
        settings: AppSettings(saveRecitations: false),
        backend: backend,
      );
      await c.playRange(const VerseRef(1, 1), const VerseRef(1, 1));
      expect(
        backend.played.single,
        'https://cdn.islamic.network/quran/audio/128/ar.husary/1.mp3',
      );
      expect(files.usage(Reciters.husary).files, 0);
    });

    test('saved files play without network', () async {
      final saved = files.fileFor(Reciters.husary, const VerseRef(1, 1));
      saved.parent.createSync(recursive: true);
      saved.writeAsBytesSync([1]);
      final backend = FakeBackend();
      final c = make(
        client: MockClient((_) async => throw const SocketException('offline')),
        settings: AppSettings(),
        backend: backend,
      );
      await c.playRange(const VerseRef(1, 1), const VerseRef(1, 1));
      expect(backend.played, ['001001.mp3']);
      expect(c.issue, RecitationIssue.none);
    });

    test('offline and not saved -> "connect to download"', () async {
      final c = make(
        client: MockClient((_) async => throw const SocketException('offline')),
        settings: AppSettings(),
        offline: true,
      );
      await c.playFrom(const VerseRef(1, 1));
      expect(c.issue, RecitationIssue.connectToDownload);
      expect(c.isActive, isFalse);
    });

    test(
      'reciter unavailable -> asks; never switches reciter itself',
      () async {
        final settings = AppSettings(reciterId: 'huthaify');
        final c = make(
          client: MockClient((_) async => http.Response('', 404)),
          settings: settings,
        );
        await c.playFrom(const VerseRef(1, 1));
        expect(c.issue, RecitationIssue.reciterUnavailable);
        expect(settings.reciterId, 'huthaify');
      },
    );

    test(
      'stream failure falls over to the next source of the same reciter',
      () async {
        final backend = FakeBackend()
          ..failWhen = (a) => a.uri?.path.contains('/first/') ?? false;
        final c = RecitationController(
          quran: quran,
          settings: AppSettings(saveRecitations: false),
          files: files,
          fetcher: AudioFetcher(files, client: okClient),
          backend: backend,
          isOffline: () async => false,
          findReciter: (_) => twoSources,
        );
        await c.playRange(const VerseRef(1, 1), const VerseRef(1, 2));
        expect(backend.played, [
          'https://cdn.islamic.network/quran/audio/128/second/1.mp3',
          'https://cdn.islamic.network/quran/audio/128/second/2.mp3',
        ]);
        expect(c.source?.edition, 'second');
        expect(c.issue, RecitationIssue.none);
      },
    );

    test('download failover: first source broken, second used', () async {
      final backend = FakeBackend();
      final c = RecitationController(
        quran: quran,
        settings: AppSettings(),
        files: files,
        fetcher: AudioFetcher(
          files,
          client: MockClient(
            (req) async => req.url.path.contains('/first/')
                ? http.Response('', 503)
                : http.Response.bytes(
                    bytesFor(req.url),
                    200,
                    headers: {'etag': etagFor(req.url)},
                  ),
          ),
        ),
        backend: backend,
        isOffline: () async => false,
        findReciter: (_) => twoSources,
      );
      await c.playRange(const VerseRef(1, 1), const VerseRef(1, 1));
      expect(backend.played, ['001001.mp3']);
      expect(c.source?.edition, 'second');
    });
  });
}
