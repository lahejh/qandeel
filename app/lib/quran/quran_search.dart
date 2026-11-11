import 'package:flutter/services.dart';

import 'quran.dart';

/// Finds surahs by name and verses by Arabic words.
///
/// Verse search matches against Tanzil's "simple-clean" text (no
/// diacritics), bundled as `assets/quran/quran-simple-clean.txt`, an exact
/// copy of `content/quran/`. That text is only used for matching; results
/// always show the Uthmani text. Normalizing (below) is applied to an
/// in-memory copy for comparison only — no file is changed.
class QuranSearch {
  QuranSearch._(this.quran, this._verseKeys);

  static const cleanTextAsset = 'assets/quran/quran-simple-clean.txt';

  final Quran quran;

  /// Normalized search key per verse, same order as [Quran.verses].
  final List<String> _verseKeys;

  static Future<QuranSearch> load(Quran quran, [AssetBundle? bundle]) async {
    final text = await (bundle ?? rootBundle).loadString(
      cleanTextAsset,
      cache: false,
    );
    return QuranSearch.parse(quran, text);
  }

  /// Builds the index. Throws [FormatException] if the clean text does not
  /// list exactly the same verses as the Uthmani text.
  factory QuranSearch.parse(Quran quran, String cleanText) {
    final keys = <String>[];
    for (final line in cleanText.split('\n')) {
      if (line.isEmpty || line.startsWith('#')) continue;
      final parts = line.split('|');
      if (parts.length != 3) {
        throw FormatException('Unexpected line in clean text', line);
      }
      final i = keys.length;
      if (i >= quran.verses.length) {
        throw const FormatException('Clean text has too many verses');
      }
      final ref = quran.verses[i].ref;
      if (int.parse(parts[0]) != ref.surah || int.parse(parts[1]) != ref.ayah) {
        throw FormatException('Clean text out of step at $ref', line);
      }
      var words = parts[2];
      // Skip the basmala Tanzil prepends to verse 1 (same rule as display).
      if (quran.verses[i].hasPrependedBasmala) {
        words = words.split(' ').skip(4).join(' ');
      }
      keys.add(' ${normalizeArabic(words)} ');
    }
    if (keys.length != quran.verses.length) {
      throw const FormatException('Clean text has too few verses');
    }
    return QuranSearch._(quran, keys);
  }

  /// Verses containing all the typed Arabic words (in any order). Each word
  /// may match part of a longer word, so "رحم" finds "الرحمن".
  List<Verse> searchVerses(String query) {
    final words = normalizeArabic(query)
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return const [];
    // A single short fragment would match too much to be useful.
    if (words.length == 1 && words.first.length < 2) return const [];
    return [
      for (var i = 0; i < _verseKeys.length; i++)
        if (words.every(_verseKeys[i].contains)) quran.verses[i],
    ];
  }

  /// Surahs whose number, Arabic, transliterated or English name matches.
  List<Surah> searchSurahs(String query) {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final number = int.tryParse(_westernDigits(q));
    if (number != null) {
      return number >= 1 && number <= 114 ? [quran.surah(number)] : const [];
    }
    final arabic = normalizeArabic(q).replaceAll(' ', '');
    final latin = _latinKey(q);
    return [
      for (final s in quran.surahs)
        if ((arabic.isNotEmpty &&
                _withoutAl(normalizeArabic(s.nameArabic).replaceAll(' ', ''))
                    .contains(_withoutAl(arabic))) ||
            (latin.isNotEmpty &&
                (_latinKey(s.nameTransliterated).contains(latin) ||
                    _latinKey(s.nameEnglish).contains(latin))))
          s,
    ];
  }

  /// A verse reference typed as "2:255" or "٢:٢٥٥", if valid.
  VerseRef? parseReference(String query) {
    final m = RegExp(r'^\s*(\d{1,3})\s*[:：.]\s*(\d{1,3})\s*$')
        .firstMatch(_westernDigits(query));
    if (m == null) return null;
    final s = int.parse(m.group(1)!), a = int.parse(m.group(2)!);
    if (s < 1 || s > 114 || a < 1 || a > quran.surah(s).verseCount) {
      return null;
    }
    return VerseRef(s, a);
  }
}

/// Makes Arabic comparable regardless of diacritics and spelling variants:
/// removes tashkeel, Quranic marks and tatweel; unifies alef, hamza, yaa
/// and taa marbuta forms; keeps only Arabic letters and single spaces.
/// Used only for comparison, never for display.
String normalizeArabic(String input) {
  final out = StringBuffer();
  var lastWasSpace = true;
  for (final c in input.runes) {
    int? ch = c;
    if (c == 0x0622 || c == 0x0623 || c == 0x0625 || c == 0x0671) {
      ch = 0x0627; // آ أ إ ٱ -> ا
    } else if (c == 0x0649 || c == 0x0626 || c == 0x06CC) {
      ch = 0x064A; // ى ئ ی -> ي
    } else if (c == 0x0624) {
      ch = 0x0648; // ؤ -> و
    } else if (c == 0x0629) {
      ch = 0x0647; // ة -> ه
    } else if (c == 0x06A9) {
      ch = 0x0643; // ک -> ك
    } else if (c == 0x0621) {
      ch = null; // standalone hamza: spelled inconsistently, ignore
    } else if (c >= 0x0627 && c <= 0x064A && c != 0x0640) {
      ch = c; // Arabic letters
    } else if (c == 0x20 || c == 0x0A || c == 0x09 || c == 0x06DD) {
      ch = 0x20;
    } else {
      ch = null; // diacritics, Quranic marks, tatweel, digits, punctuation
    }
    if (ch == null) continue;
    if (ch == 0x20) {
      if (!lastWasSpace) out.writeCharCode(0x20);
      lastWasSpace = true;
    } else {
      out.writeCharCode(ch);
      lastWasSpace = false;
    }
  }
  return out.toString().trim();
}

String _withoutAl(String s) => s.startsWith('ال') ? s.substring(2) : s;

/// "Al-Baqara", "al baqarah", "Baqarah" -> "baqara".
String _latinKey(String s) {
  var k = s.toLowerCase().replaceAll(RegExp('[^a-z]'), '');
  if (k.startsWith('al') && k.length > 4) k = k.substring(2);
  k = k.replaceAllMapped(RegExp(r'(.)\1+'), (m) => m.group(1)!); // aa -> a
  if (k.endsWith('h') && k.length > 3) k = k.substring(0, k.length - 1);
  return k;
}

String _westernDigits(String s) => String.fromCharCodes(
  s.codeUnits.map(
    (c) => c >= 0x0660 && c <= 0x0669
        ? c - 0x0660 + 0x30
        : c >= 0x06F0 && c <= 0x06F9
        ? c - 0x06F0 + 0x30
        : c,
  ),
);
