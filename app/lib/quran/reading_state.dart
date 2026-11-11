import 'package:flutter/foundation.dart';

import '../storage/local_store.dart';
import 'quran.dart';

/// Where the reader is and which verses are bookmarked. Saved on the device
/// through [LocalStore] whenever it changes.
class ReadingState extends ChangeNotifier {
  ReadingState({
    this._lastReadPage,
    Iterable<VerseRef> bookmarks = const [],
    LocalStore? store,
  }) : _bookmarks = {...bookmarks},
       _store = store ?? MemoryStore();

  /// Reads the saved state. Anything unreadable is ignored, never fatal.
  factory ReadingState.load(LocalStore store) {
    final page = int.tryParse(store.getString(StoreKeys.lastReadPage) ?? '');
    final marks = <VerseRef>[];
    for (final item in (store.getString(StoreKeys.bookmarks) ?? '').split(
      ',',
    )) {
      final parts = item.split(':');
      if (parts.length != 2) continue;
      final s = int.tryParse(parts[0]), a = int.tryParse(parts[1]);
      if (s != null && a != null && s >= 1 && s <= 114 && a >= 1) {
        marks.add(VerseRef(s, a));
      }
    }
    return ReadingState(
      lastReadPage: (page != null && page >= 1 && page <= Quran.pageCount)
          ? page
          : null,
      bookmarks: marks,
      store: store,
    );
  }

  int? _lastReadPage;
  final Set<VerseRef> _bookmarks;
  final LocalStore _store;

  /// Last mushaf page opened (1–604), or `null` if the reader was never opened.
  int? get lastReadPage => _lastReadPage;

  /// Bookmarked verses, in Quran order.
  List<VerseRef> get bookmarks => _bookmarks.toList()..sort();

  bool isBookmarked(VerseRef ref) => _bookmarks.contains(ref);

  set lastReadPage(int? page) {
    if (page == _lastReadPage) return;
    _lastReadPage = page;
    if (page == null) {
      _store.remove(StoreKeys.lastReadPage);
    } else {
      _store.setString(StoreKeys.lastReadPage, '$page');
    }
    notifyListeners();
  }

  void toggleBookmark(VerseRef ref) {
    if (!_bookmarks.remove(ref)) _bookmarks.add(ref);
    _store.setString(StoreKeys.bookmarks, bookmarks.join(','));
    notifyListeners();
  }
}
