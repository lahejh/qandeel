import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../quran/quran.dart';
import '../settings/app_settings.dart';
import 'audio_files.dart';
import 'reciters.dart';

/// What to play: a saved file or a stream address.
class PlayableAudio {
  PlayableAudio.file(File this.file) : uri = null;
  PlayableAudio.stream(Uri this.uri) : file = null;

  final File? file;
  final Uri? uri;
}

/// Plays one item at a time. The app uses [JustAudioBackend]; tests use a fake.
abstract class AudioBackend {
  /// Plays [audio] and completes when it has finished, or when [stop] is
  /// called. Throws if the audio cannot be loaded.
  Future<void> play(PlayableAudio audio);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> dispose();
}

/// Why playback stopped by itself.
enum RecitationIssue {
  none,

  /// Not saved on the phone and no connection: "Connect to download".
  connectToDownload,

  /// No source has this reciter right now: ask the user before switching.
  reciterUnavailable,
}

/// Plays verses in the chosen reciter's voice: one verse, a range, with
/// repeats. Order for each verse (CLAUDE.md §4): saved file → stream (or
/// download once when "Stream and save" is on) → "connect to download".
/// Never switches reciter on its own.
class RecitationController extends ChangeNotifier {
  RecitationController({
    required this.quran,
    required this.settings,
    required this.files,
    required this.fetcher,
    required this.backend,
    this.canSaveOnThisNetwork = _unknownNetwork,
    this.isOffline = _lookupOffline,
    this.findReciter = Reciters.byId,
  });

  /// Reciter for the saved setting (tests can supply their own catalogue).
  final Reciter Function(String? id) findReciter;

  final Quran quran;
  final AppSettings settings;
  final AudioFiles files;
  final AudioFetcher fetcher;
  final AudioBackend backend;

  /// Whether downloads may be saved on the current network (the "Wi-Fi
  /// only" setting). Returns null when the network type is unknown.
  final Future<bool?> Function() canSaveOnThisNetwork;
  static Future<bool?> _unknownNetwork() async => null;

  /// Whether the phone is offline (used only after a stream failed, to
  /// choose between "connect to download" and "reciter unavailable").
  final Future<bool> Function() isOffline;
  static Future<bool> _lookupOffline() async {
    try {
      final result = await InternetAddress.lookup('cdn.islamic.network')
          .timeout(const Duration(seconds: 5));
      return result.isEmpty;
    } catch (_) {
      return true;
    }
  }

  int _session = 0;
  VerseRef? _current;
  bool _playing = false;
  bool _paused = false;
  ReciterSource? _source;
  RecitationIssue _issue = RecitationIssue.none;

  /// Verse being recited now (for highlighting and following the page).
  VerseRef? get current => _current;
  bool get isActive => _playing;
  bool get isPaused => _paused;
  RecitationIssue get issue => _issue;
  Reciter get reciter => findReciter(settings.reciterId);

  /// Source of the verse being played, for the on-screen credit.
  ReciterSource? get source => _source;

  /// Plays verses [from]..[to] (inclusive, in Quran order). Each verse is
  /// played [repeatEach] times; the whole range [repeatRange] times.
  Future<void> playRange(
    VerseRef from,
    VerseRef to, {
    int repeatEach = 1,
    int repeatRange = 1,
  }) async {
    final session = ++_session;
    await backend.stop();
    _playing = true;
    _paused = false;
    _issue = RecitationIssue.none;
    notifyListeners();

    final start = quran.indexOf(from), end = quran.indexOf(to);
    try {
      for (var r = 0; r < repeatRange; r++) {
        for (var i = start; i <= end; i++) {
          final verse = quran.verses[i];
          final audio = await _resolve(verse);
          if (session != _session) return;
          if (i < end) _prefetch(quran.verses[i + 1]);
          for (var k = 0; k < repeatEach; k++) {
            _current = verse.ref;
            notifyListeners();
            await _playWithFailover(verse, audio);
            if (session != _session) return;
          }
        }
      }
    } on NoConnection {
      if (session == _session) _issue = RecitationIssue.connectToDownload;
    } on ReciterUnavailable {
      if (session == _session) _issue = RecitationIssue.reciterUnavailable;
    }
    if (session == _session) {
      _playing = false;
      _paused = false;
      _current = null;
      notifyListeners();
    }
  }

  /// Plays from [from] to the end of its surah.
  Future<void> playFrom(VerseRef from) =>
      playRange(from, VerseRef(from.surah, quran.surah(from.surah).verseCount));

  Future<void> pause() async {
    if (!_playing || _paused) return;
    _paused = true;
    notifyListeners();
    await backend.pause();
  }

  Future<void> resume() async {
    if (!_playing || !_paused) return;
    _paused = false;
    notifyListeners();
    await backend.resume();
  }

  Future<void> stop() async {
    _session++;
    _playing = false;
    _paused = false;
    _current = null;
    notifyListeners();
    await backend.stop();
  }

  /// The user saw the issue message.
  void clearIssue() {
    _issue = RecitationIssue.none;
    notifyListeners();
  }

  Future<PlayableAudio> _resolve(Verse verse) async {
    final r = reciter;
    final saved = files.fileFor(r, verse.ref);
    if (saved.existsSync()) {
      _source ??= r.sources.first;
      return PlayableAudio.file(saved);
    }
    if (settings.saveRecitations && await canSaveOnThisNetwork() != false) {
      final fetched = await fetcher.fetch(r, verse);
      _source = fetched.source;
      return PlayableAudio.file(fetched.file);
    }
    // Stream only (or saving not allowed on this network).
    final source = _firstStreamable(r, verse, after: null);
    if (source == null) throw ReciterUnavailable(r);
    _source = source;
    return PlayableAudio.stream(source.verseUri(verse));
  }

  /// Plays; if a stream fails, tries the same reciter on the next source.
  Future<void> _playWithFailover(Verse verse, PlayableAudio audio) async {
    if (audio.file != null) {
      try {
        await backend.play(audio);
        return;
      } catch (_) {
        // A saved file that will not play is damaged: delete it and fetch it
        // once more. If that also fails, stop with a clear message.
        if (audio.file!.existsSync()) await audio.file!.delete();
        final again = await _resolve(verse);
        try {
          await backend.play(again);
          return;
        } catch (_) {
          throw ReciterUnavailable(reciter);
        }
      }
    }
    var current = audio;
    while (true) {
      try {
        await backend.play(current);
        return;
      } catch (_) {
        final next = _firstStreamable(reciter, verse, after: _source);
        if (next == null) {
          throw await isOffline()
              ? const NoConnection()
              : ReciterUnavailable(reciter);
        }
        _source = next;
        current = PlayableAudio.stream(next.verseUri(verse));
      }
    }
  }

  ReciterSource? _firstStreamable(
    Reciter r,
    Verse verse, {
    ReciterSource? after,
  }) {
    var passed = after == null;
    for (final s in r.sources) {
      if (!passed) {
        passed = identical(s, after);
        continue;
      }
      try {
        s.verseUri(verse);
        return s;
      } on UnsupportedError {
        continue;
      }
    }
    return null;
  }

  void _prefetch(Verse next) {
    if (!settings.saveRecitations) return;
    unawaited(
      canSaveOnThisNetwork().then((ok) {
        if (ok == false) return null;
        return fetcher.fetch(reciter, next).then<void>((_) {}, onError: (_) {});
      }),
    );
  }

  @override
  void dispose() {
    _session++;
    unawaited(backend.dispose());
    super.dispose();
  }
}
