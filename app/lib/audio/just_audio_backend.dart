import 'dart:async';

import 'package:just_audio/just_audio.dart';

import 'recitation_controller.dart';

/// Plays recitation with the `just_audio` package (approved 2026-11-11).
/// It only plays what it is given; it sends nothing anywhere.
class JustAudioBackend implements AudioBackend {
  final _player = AudioPlayer();
  Completer<void>? _stopped;

  @override
  Future<void> play(PlayableAudio audio) async {
    final stopped = _stopped = Completer<void>();
    if (audio.file != null) {
      await _player.setFilePath(audio.file!.path);
    } else {
      await _player.setUrl(audio.uri.toString());
    }
    unawaited(_player.play());
    // Finished when the item completes, or when stop() is called. Pausing
    // does not finish it.
    await Future.any([
      _player.processingStateStream.firstWhere(
        (s) => s == ProcessingState.completed,
      ),
      stopped.future,
    ]);
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.play();

  @override
  Future<void> stop() async {
    final stopped = _stopped;
    if (stopped != null && !stopped.isCompleted) stopped.complete();
    await _player.stop();
  }

  @override
  Future<void> dispose() => _player.dispose();
}
