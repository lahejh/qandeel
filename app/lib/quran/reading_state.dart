import 'package:flutter/foundation.dart';

import 'quran.dart';

/// Where the reader is and which verses are bookmarked.
///
/// Kept in memory for now. Build step 4 adds saving on the device (never
/// online) with a small, owner-approved storage package — only this class
/// needs to change for that.
class ReadingState extends ChangeNotifier {
  ReadingState({this._lastReadPage, Iterable<VerseRef> bookmarks = const []})
    : _bookmarks = {...bookmarks};

  int? _lastReadPage;
  final Set<VerseRef> _bookmarks;

  /// Last mushaf page opened (1–604), or `null` if the reader was never opened.
  int? get lastReadPage => _lastReadPage;

  /// Bookmarked verses, in Quran order.
  List<VerseRef> get bookmarks => _bookmarks.toList()..sort();

  bool isBookmarked(VerseRef ref) => _bookmarks.contains(ref);

  set lastReadPage(int? page) {
    if (page == _lastReadPage) return;
    _lastReadPage = page;
    notifyListeners();
  }

  void toggleBookmark(VerseRef ref) {
    if (!_bookmarks.remove(ref)) _bookmarks.add(ref);
    notifyListeners();
  }
}
