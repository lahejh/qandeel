import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qandeel/audio/audio_files.dart';
import 'package:qandeel/audio/network_check.dart';
import 'package:qandeel/audio/recitation_controller.dart';
import 'package:qandeel/audio/reciters.dart';
import 'package:qandeel/quran/quran.dart';
import 'package:qandeel/settings/app_settings.dart';

class RecordingBackend implements AudioBackend {
  final played = <String>[];
  @override
  Future<void> play(PlayableAudio a) async =>
      played.add(a.file != null ? 'file' : 'stream');
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
  test('Wi-Fi rule', () {
    expect(wifiAllowsSaving([ConnectivityResult.wifi]), isTrue);
    expect(wifiAllowsSaving([ConnectivityResult.ethernet]), isTrue);
    expect(
      wifiAllowsSaving([ConnectivityResult.mobile, ConnectivityResult.wifi]),
      isTrue,
    );
    expect(wifiAllowsSaving([ConnectivityResult.mobile]), isFalse);
    expect(wifiAllowsSaving([ConnectivityResult.none]), isNull);
  });

  test('setting off: saving allowed on any network', () async {
    final s = AppSettings(wifiOnly: false);
    expect(
      await canSaveOnThisNetwork(
        s,
        check: () async => [ConnectivityResult.mobile],
      ),
      isTrue,
    );
    expect(
      await canSaveOnThisNetwork(
        AppSettings(),
        check: () async => [ConnectivityResult.mobile],
      ),
      isFalse,
    );
  });

  test('Wi-Fi only setting is saved and on by default', () {
    expect(AppSettings().wifiOnly, isTrue);
  });

  test('on mobile data with Wi-Fi only: streams, saves nothing', () async {
    final quran = Quran.parse(
      text: File('assets/quran/quran-uthmani.txt').readAsStringSync(),
      metadata: File('assets/quran/quran-data.xml').readAsStringSync(),
    );
    final tmp = Directory.systemTemp.createTempSync('qandeel_wifi');
    addTearDown(() => tmp.deleteSync(recursive: true));
    final files = AudioFiles(Directory('${tmp.path}/audio'));
    final settings = AppSettings();
    final backend = RecordingBackend();
    final c = RecitationController(
      quran: quran,
      settings: settings,
      files: files,
      fetcher: AudioFetcher(
        files,
        client: MockClient(
          (_) async => http.Response.bytes(
            [1],
            200,
            headers: {
              'etag': '"${md5.convert([1])}"',
            },
          ),
        ),
      ),
      backend: backend,
      isOffline: () async => false,
      canSaveOnThisNetwork: () => canSaveOnThisNetwork(
        settings,
        check: () async => [ConnectivityResult.mobile],
      ),
    );
    await c.playRange(const VerseRef(1, 1), const VerseRef(1, 2));
    expect(backend.played, ['stream', 'stream']);
    expect(files.usage(Reciters.husary).files, 0);
  });
}
