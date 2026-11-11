import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../quran/quran.dart';
import 'reciters.dart';

/// Recitation files saved on this device: one file per verse, in the app's
/// private folder, one sub-folder per reciter. Each file is downloaded once
/// and checked against the source's MD5 before it is kept.
class AudioFiles {
  AudioFiles(this.root);

  /// e.g. `<app support dir>/audio`. Never synced or shared by the app.
  final Directory root;

  Directory folderOf(Reciter r) => Directory('${root.path}/${r.id}');

  /// `<root>/<reciter>/SSSAAA.mp3`, e.g. husary/002255.mp3
  File fileFor(Reciter r, VerseRef ref) => File(
    '${folderOf(r).path}/'
    '${ref.surah.toString().padLeft(3, '0')}${ref.ayah.toString().padLeft(3, '0')}.mp3',
  );

  bool has(Reciter r, VerseRef ref) => fileFor(r, ref).existsSync();

  /// Number of saved verses and their total size in bytes.
  ({int files, int bytes}) usage(Reciter r) {
    final dir = folderOf(r);
    if (!dir.existsSync()) return (files: 0, bytes: 0);
    var files = 0, bytes = 0;
    for (final f in dir.listSync().whereType<File>()) {
      if (!f.path.endsWith('.mp3')) continue;
      files++;
      bytes += f.lengthSync();
    }
    return (files: files, bytes: bytes);
  }

  /// Deletes every saved file of one reciter.
  Future<void> deleteAll(Reciter r) async {
    final dir = folderOf(r);
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}

/// No source could be reached (no connection).
class NoConnection implements Exception {
  const NoConnection();
}

/// Every source for this reciter failed for this verse. The app must ASK the
/// user before switching to another reciter (CLAUDE.md §4).
class ReciterUnavailable implements Exception {
  const ReciterUnavailable(this.reciter);
  final Reciter reciter;
}

/// A verse that was downloaded and verified.
class FetchedVerse {
  const FetchedVerse(this.file, this.source);
  final File file;
  final ReciterSource source;
}

/// Downloads verse files, trying the SAME reciter on each source in order.
/// Network is used only here, and only because the user tapped play.
class AudioFetcher {
  AudioFetcher(
    this.files, {
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  final AudioFiles files;
  final http.Client _client;
  final Duration timeout;

  /// Downloads in progress, so the same file is never fetched twice at once.
  final _inFlight = <String, Future<FetchedVerse>>{};

  /// Returns the saved file, downloading it first if needed.
  Future<FetchedVerse> fetch(Reciter reciter, Verse verse) {
    final target = files.fileFor(reciter, verse.ref);
    if (target.existsSync()) {
      return Future.value(FetchedVerse(target, reciter.sources.first));
    }
    return _inFlight.putIfAbsent(
      target.path,
      // Block body on purpose: returning the removed Future from
      // whenComplete would make the download wait for itself.
      () => _download(reciter, verse, target).whenComplete(() {
        _inFlight.remove(target.path);
      }),
    );
  }

  Future<FetchedVerse> _download(
    Reciter reciter,
    Verse verse,
    File target,
  ) async {
    var reachedAny = false;
    for (final source in reciter.sources) {
      final Uri uri;
      try {
        uri = source.verseUri(verse);
      } on UnsupportedError {
        continue; // source has no files yet (e.g. King Fahd Complex today)
      }
      try {
        final response = await _client.get(uri).timeout(timeout);
        reachedAny = true;
        if (response.statusCode != 200 || response.bodyBytes.isEmpty) continue;
        if (!checksumMatches(response.bodyBytes, response.headers['etag'])) {
          continue; // damaged or unexpected file: try the next source
        }
        await target.parent.create(recursive: true);
        // Write to a temporary name first so a half-written file is never used.
        final temp = File('${target.path}.part');
        await temp.writeAsBytes(response.bodyBytes, flush: true);
        await temp.rename(target.path);
        return FetchedVerse(target, source);
      } on SocketException {
        continue;
      } on TimeoutException {
        continue;
      } on http.ClientException {
        continue;
      }
    }
    if (!reachedAny) throw const NoConnection();
    throw ReciterUnavailable(reciter);
  }

  void close() => _client.close();
}

/// True if [bytes] match the MD5 in an ETag like `"5155f8bb…"`. If the ETag
/// is not a plain MD5 (e.g. missing), the file cannot be checked this way and
/// is accepted only when non-empty.
bool checksumMatches(List<int> bytes, String? etag) {
  if (etag == null) return bytes.isNotEmpty;
  final tag = etag.replaceAll('"', '').replaceFirst('W/', '').toLowerCase();
  if (!RegExp(r'^[0-9a-f]{32}$').hasMatch(tag)) return bytes.isNotEmpty;
  return md5.convert(bytes).toString() == tag;
}
