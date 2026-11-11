import 'package:flutter/services.dart';

/// The Quran text and its metadata, loaded from the verified Tanzil files.
///
/// SACRED TEXT RULES (CLAUDE.md §1): the text comes only from
/// `assets/quran/quran-uthmani.txt`, which is a byte-for-byte copy of
/// `content/quran/quran-uthmani.txt`. Nothing here changes it. The only
/// display-time processing is splitting the stored basmala off verse 1 so it
/// can be shown as a header (see [Verse.basmalaHeader]); tests prove the two
/// parts join back to the exact stored line.
class Quran {
  Quran._(this.verses, this.surahs, this.juzStarts, this.pageStarts)
    : _firstIndexOfSurah = [for (final s in surahs) s.firstVerseIndex];

  static const textAsset = 'assets/quran/quran-uthmani.txt';
  static const metadataAsset = 'assets/quran/quran-data.xml';

  /// Number of pages in the Madinah mushaf (as in Tanzil's metadata).
  static const pageCount = 604;
  static const juzCount = 30;

  /// All 6,236 verses in order.
  final List<Verse> verses;

  /// All 114 surahs in order (index 0 = Al-Fatiha).
  final List<Surah> surahs;

  /// First verse of each juz (index 0 = juz 1).
  final List<VerseRef> juzStarts;

  /// First verse of each mushaf page (index 0 = page 1).
  final List<VerseRef> pageStarts;

  final List<int> _firstIndexOfSurah;

  /// Loads both bundled files.
  static Future<Quran> load([AssetBundle? bundle]) async {
    final b = bundle ?? rootBundle;
    // cache: false — the text is parsed once and kept in [Quran].
    final text = await b.loadString(textAsset, cache: false);
    final meta = await b.loadString(metadataAsset, cache: false);
    return Quran.parse(text: text, metadata: meta);
  }

  /// Parses the Tanzil `sura|aya|text` file and `quran-data.xml`.
  ///
  /// Throws [FormatException] if anything is missing or out of order, so a
  /// damaged file can never be shown silently.
  factory Quran.parse({required String text, required String metadata}) {
    final verses = <Verse>[];
    for (final line in text.split('\n')) {
      // Blank lines and the copyright block (lines starting with '#').
      if (line.isEmpty || line.startsWith('#')) continue;
      final a = line.indexOf('|');
      final b = a < 0 ? -1 : line.indexOf('|', a + 1);
      if (a < 0 || b < 0) {
        throw FormatException('Unexpected line in Quran text', line);
      }
      verses.add(
        Verse(
          VerseRef(
            int.parse(line.substring(0, a)),
            int.parse(line.substring(a + 1, b)),
          ),
          line.substring(b + 1),
          verses.length,
        ),
      );
    }

    final suraTags = _tags(metadata, 'sura');
    final surahs = <Surah>[
      for (final t in suraTags)
        Surah(
          number: int.parse(t['index']!),
          verseCount: int.parse(t['ayas']!),
          firstVerseIndex: int.parse(t['start']!),
          nameArabic: t['name']!,
          nameTransliterated: t['tname']!,
          nameEnglish: t['ename']!,
          isMeccan: t['type'] == 'Meccan',
        ),
    ];

    VerseRef refOf(Map<String, String> t) =>
        VerseRef(int.parse(t['sura']!), int.parse(t['aya']!));
    final juzStarts = [for (final t in _tags(metadata, 'juz')) refOf(t)];
    final pageStarts = [for (final t in _tags(metadata, 'page')) refOf(t)];

    final quran = Quran._(
      List.unmodifiable(verses),
      List.unmodifiable(surahs),
      List.unmodifiable(juzStarts),
      List.unmodifiable(pageStarts),
    );
    quran._check();
    return quran;
  }

  /// Consistency checks between the text and the metadata.
  void _check() {
    void expectCount(int actual, int expected, String what) {
      if (actual != expected) {
        throw FormatException('Expected $expected $what, found $actual');
      }
    }

    expectCount(surahs.length, 114, 'surahs');
    expectCount(verses.length, 6236, 'verses');
    expectCount(juzStarts.length, juzCount, 'juz');
    expectCount(pageStarts.length, pageCount, 'pages');
    for (final s in surahs) {
      for (var i = 0; i < s.verseCount; i++) {
        final v = verses[s.firstVerseIndex + i];
        if (v.ref.surah != s.number || v.ref.ayah != i + 1) {
          throw FormatException('Verse order mismatch at ${v.ref}');
        }
      }
    }
  }

  Surah surah(int number) => surahs[number - 1];

  /// The verse for a reference. Throws [RangeError] if it does not exist.
  Verse verse(VerseRef ref) {
    final s = surah(ref.surah);
    if (ref.ayah < 1 || ref.ayah > s.verseCount) {
      throw RangeError('No verse $ref');
    }
    return verses[_firstIndexOfSurah[ref.surah - 1] + ref.ayah - 1];
  }

  int indexOf(VerseRef ref) => verse(ref).index;

  /// Mushaf page (1–604) that contains [ref].
  int pageOf(VerseRef ref) =>
      _lastStartAtOrBefore(pageStarts, indexOf(ref)) + 1;

  /// Juz (1–30) that contains [ref].
  int juzOf(VerseRef ref) => _lastStartAtOrBefore(juzStarts, indexOf(ref)) + 1;

  /// Verses printed on mushaf [page] (1–604), in order.
  List<Verse> versesOnPage(int page) {
    final start = indexOf(pageStarts[page - 1]);
    final end = page == pageCount ? verses.length : indexOf(pageStarts[page]);
    return verses.sublist(start, end);
  }

  int _lastStartAtOrBefore(List<VerseRef> starts, int index) {
    var lo = 0, hi = starts.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (indexOf(starts[mid]) <= index) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo;
  }

  /// Reads `<tag a="1" b="2" />` elements from the Tanzil metadata file.
  /// The file is simple and fixed, so a small parser avoids an XML package.
  static List<Map<String, String>> _tags(String xml, String tag) {
    final element = RegExp('<$tag\\s([^>]*?)/?>');
    final attribute = RegExp(r'(\w+)="([^"]*)"');
    return [
      for (final m in element.allMatches(xml))
        {
          for (final a in attribute.allMatches(m.group(1)!))
            a.group(1)!: a.group(2)!,
        },
    ];
  }
}

/// A verse position: surah 1–114, ayah 1–n.
class VerseRef implements Comparable<VerseRef> {
  const VerseRef(this.surah, this.ayah);

  final int surah;
  final int ayah;

  @override
  bool operator ==(Object other) =>
      other is VerseRef && other.surah == surah && other.ayah == ayah;

  @override
  int get hashCode => surah * 1000 + ayah;

  @override
  int compareTo(VerseRef other) =>
      surah != other.surah ? surah - other.surah : ayah - other.ayah;

  @override
  String toString() => '$surah:$ayah';
}

class Verse {
  const Verse(this.ref, this.text, this.index);

  final VerseRef ref;

  /// Exactly as stored in the Tanzil file (for verse 1 of most surahs this
  /// includes the basmala at the start).
  final String text;

  /// Position 0–6235 in the whole Quran.
  final int index;

  /// Whether the stored text starts with the basmala that Tanzil prepends to
  /// verse 1 of every surah except Al-Fatiha (where it is the verse itself)
  /// and At-Tawbah (which has none).
  bool get hasPrependedBasmala =>
      ref.ayah == 1 && ref.surah != 1 && ref.surah != 9;

  /// The basmala exactly as stored at the start of this verse (its first
  /// four words), or `null`. Shown as a header above the surah.
  String? get basmalaHeader {
    if (!hasPrependedBasmala) return null;
    return text.substring(0, _basmalaEnd);
  }

  /// The verse text to show after the basmala header.
  /// `basmalaHeader + ' ' + displayText == text` (tested for all surahs).
  String get displayText =>
      hasPrependedBasmala ? text.substring(_basmalaEnd + 1) : text;

  /// Index of the space after the fourth word.
  int get _basmalaEnd {
    var pos = -1;
    for (var i = 0; i < 4; i++) {
      pos = text.indexOf(' ', pos + 1);
    }
    return pos;
  }
}

class Surah {
  const Surah({
    required this.number,
    required this.verseCount,
    required this.firstVerseIndex,
    required this.nameArabic,
    required this.nameTransliterated,
    required this.nameEnglish,
    required this.isMeccan,
  });

  final int number;
  final int verseCount;
  final int firstVerseIndex;

  /// From quran-data.xml, e.g. "الفاتحة".
  final String nameArabic;

  /// e.g. "Al-Faatiha".
  final String nameTransliterated;

  /// e.g. "The Opening".
  final String nameEnglish;
  final bool isMeccan;
}
