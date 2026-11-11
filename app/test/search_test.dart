// Search tests. No Quran text is typed here: queries are taken from the
// verified files themselves.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qandeel/quran/quran.dart';
import 'package:qandeel/quran/quran_search.dart';

void main() {
  final quran = Quran.parse(
    text: File('assets/quran/quran-uthmani.txt').readAsStringSync(),
    metadata: File('assets/quran/quran-data.xml').readAsStringSync(),
  );
  final cleanText = File('assets/quran/quran-simple-clean.txt')
      .readAsStringSync();
  final search = QuranSearch.parse(quran, cleanText);

  /// Words of a verse in the clean (no diacritics) file.
  List<String> cleanWords(VerseRef ref) {
    final line = cleanText
        .split('\n')
        .firstWhere((l) => l.startsWith('${ref.surah}|${ref.ayah}|'));
    return line.split('|')[2].split(' ');
  }

  test('clean text is a byte-for-byte copy and lines up with Uthmani', () {
    expect(
      File('assets/quran/quran-simple-clean.txt').readAsBytesSync(),
      File('../content/quran/quran-simple-clean.txt').readAsBytesSync(),
    );
    expect(File('assets/quran/quran-simple-clean.txt').lengthSync(), 781176);
    expect(
      cleanText,
      contains('Tanzil Quran Text (Simple Clean, Version 1.1)'),
    );
    // QuranSearch.parse throws if any verse is out of step; check the refs too.
    final refs = [
      for (final l in cleanText.split('\n'))
        if (l.isNotEmpty && !l.startsWith('#')) l.split('|').take(2).join(':'),
    ];
    expect(refs, [for (final v in quran.verses) '${v.ref}']);
  });

  test('a mismatched clean text is rejected', () {
    final broken = cleanText.replaceFirst('2|1|', '2|9|');
    expect(() => QuranSearch.parse(quran, broken), throwsFormatException);
  });

  test('words from a verse find that verse', () {
    for (final ref in const [
      VerseRef(2, 255),
      VerseRef(18, 10),
      VerseRef(112, 1),
    ]) {
      final words = cleanWords(ref);
      // Last words: verse 1 starts with the prepended basmala, which search
      // skips on purpose.
      final query = words.skip(words.length - 2).join(' ');
      expect(
        search.searchVerses(query).map((v) => v.ref),
        contains(ref),
        reason: query,
      );
    }
  });

  test('all words must match; order does not matter', () {
    final words = cleanWords(const VerseRef(2, 255));
    final reversed = '${words[3]} ${words[1]}';
    final hits = search.searchVerses(reversed).map((v) => v.ref).toList();
    expect(hits, contains(const VerseRef(2, 255)));
    for (final ref in hits) {
      final key = normalizeArabic(cleanWords(ref).join(' '));
      expect(key, contains(normalizeArabic(words[3])));
      expect(key, contains(normalizeArabic(words[1])));
    }
  });

  test('prepended basmala is skipped; real basmala verses are found', () {
    final basmala = cleanWords(const VerseRef(1, 1)).join(' ');
    final hits = search.searchVerses(basmala).map((v) => v.ref).toList();
    expect(hits, contains(const VerseRef(1, 1)));
    expect(hits, contains(const VerseRef(27, 30)));
    expect(hits, isNot(contains(const VerseRef(2, 1))));
    expect(hits.length, lessThan(5));
  });

  test('diacritics and letter variants do not matter', () {
    // Ordinary (non-Quran) words.
    expect(normalizeArabic('مَدْرَسَةٌ'), normalizeArabic('مدرسه'));
    expect(normalizeArabic('أَحْمَد إِبْرَاهِيم آمِن'), 'احمد ابراهيم امن');
    expect(normalizeArabic('مُسْتَشْفَى'), normalizeArabic('مستشفي'));
    expect(normalizeArabic('  كـتـاب  ،  قلم '), 'كتاب قلم');
    // The same verse typed with Uthmani marks still matches its clean text.
    final uthmaniWords = quran.verse(const VerseRef(112, 1)).text.split(' ');
    expect(
      search.searchVerses(uthmaniWords.last).map((v) => v.ref),
      contains(const VerseRef(112, 1)),
    );
  });

  test('too-short or empty queries return nothing', () {
    expect(search.searchVerses(''), isEmpty);
    expect(search.searchVerses('   '), isEmpty);
    expect(search.searchVerses('a b'), isEmpty);
    expect(search.searchVerses(normalizeArabic('ب')), isEmpty);
  });

  test('surah search by number, English, transliteration and Arabic', () {
    List<int> nums(String q) =>
        search.searchSurahs(q).map((s) => s.number).toList();
    expect(nums('2'), [2]);
    expect(nums('١١٤'), [114]);
    expect(nums('115'), isEmpty);
    expect(nums('baqara'), contains(2));
    expect(nums('Al-Baqarah'), contains(2));
    expect(nums('the cow'), [2]);
    expect(nums('fatiha'), [1]);
    // Arabic names come from the metadata, with and without "ال".
    final baqara = quran.surah(2).nameArabic;
    expect(nums(baqara), contains(2));
    expect(nums(baqara.substring(2)), contains(2));
  });

  test('verse references', () {
    expect(search.parseReference('2:255'), const VerseRef(2, 255));
    expect(search.parseReference(' ٢:٢٥٥ '), const VerseRef(2, 255));
    expect(search.parseReference('114.6'), const VerseRef(114, 6));
    expect(search.parseReference('1:8'), isNull);
    expect(search.parseReference('115:1'), isNull);
    expect(search.parseReference('baqara'), isNull);
  });
}
