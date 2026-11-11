// Verifies the Quran text is complete and unchanged (CLAUDE.md §1).
//
// No Quran text is typed in this file: every expected value is read from the
// verified source file itself.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qandeel/quran/quran.dart';

// Paths relative to app/ (where `flutter test` runs).
const appText = 'assets/quran/quran-uthmani.txt';
const appMeta = 'assets/quran/quran-data.xml';
const sourceText = '../content/quran/quran-uthmani.txt';
const sourceMeta = '../content/quran/quran-data.xml';

void main() {
  late List<int> textBytes;
  late Quran quran;

  setUpAll(() {
    textBytes = File(appText).readAsBytesSync();
    quran = Quran.parse(
      text: utf8.decode(textBytes),
      metadata: File(appMeta).readAsStringSync(),
    );
  });

  test('app copies are byte-for-byte identical to content/quran', () {
    expect(File(appText).readAsBytesSync(), File(sourceText).readAsBytesSync());
    expect(File(appMeta).readAsBytesSync(), File(sourceMeta).readAsBytesSync());
  });

  test('file size matches the size recorded in content/quran/SOURCE.md', () {
    expect(textBytes.length, 1370878);
    expect(File(appMeta).lengthSync(), 77234);
  });

  test('Tanzil copyright block is kept', () {
    final text = utf8.decode(textBytes);
    expect(
      text,
      contains('PLEASE DO NOT REMOVE OR CHANGE THIS COPYRIGHT BLOCK'),
    );
    expect(text, contains('Tanzil Quran Text (Uthmani, Version 1.1)'));
  });

  test('114 surahs and 6,236 verses', () {
    expect(quran.surahs.length, 114);
    expect(quran.verses.length, 6236);
    expect(quran.surahs.fold<int>(0, (n, s) => n + s.verseCount), 6236);
    expect(quran.surah(2).verseCount, 286);
    expect(quran.surah(108).verseCount, 3);
  });

  test('every verse matches its line in the source file exactly', () {
    // Independent of the parser: split the raw bytes on newline (0x0A) and
    // compare each verse line, byte for byte, with the parsed verse.
    final lines = <List<int>>[];
    var start = 0;
    for (var i = 0; i < textBytes.length; i++) {
      if (textBytes[i] == 0x0A) {
        lines.add(textBytes.sublist(start, i));
        start = i + 1;
      }
    }
    final verseLines = lines.take(6236).toList();
    for (final v in quran.verses) {
      final expected = verseLines[v.index];
      final actual = utf8.encode('${v.ref.surah}|${v.ref.ayah}|${v.text}');
      expect(actual, expected, reason: 'verse ${v.ref}');
    }
  });

  test('spot checks: lookups return the right line', () {
    final raw = utf8.decode(textBytes).split('\n');
    for (final ref in const [
      VerseRef(1, 1),
      VerseRef(2, 255),
      VerseRef(9, 1),
      VerseRef(18, 10),
      VerseRef(36, 58),
      VerseRef(112, 1),
      VerseRef(114, 6),
    ]) {
      final line = raw.firstWhere(
        (l) => l.startsWith('${ref.surah}|${ref.ayah}|'),
      );
      expect(
        quran.verse(ref).text,
        line.substring(line.indexOf('|', line.indexOf('|') + 1) + 1),
      );
    }
  });

  test('basmala header + rest joins back to the exact stored verse', () {
    final fatihaBasmala = quran.verse(const VerseRef(1, 1)).text;
    var withHeader = 0;
    for (final s in quran.surahs) {
      final v = quran.verse(VerseRef(s.number, 1));
      final header = v.basmalaHeader;
      if (s.number == 1 || s.number == 9) {
        expect(header, isNull);
        expect(v.displayText, v.text);
        continue;
      }
      withHeader++;
      expect('$header ${v.displayText}', v.text, reason: 'surah ${s.number}');
      expect(header!.split(' ').length, 4);
      expect(v.displayText, isNotEmpty);
      // Same basmala as Al-Fatiha 1:1, except 95 and 97 where the stored form
      // starts with a shaddah (kept as stored; see SOURCE.md).
      if (s.number != 95 && s.number != 97) {
        expect(header, fatihaBasmala, reason: 'surah ${s.number}');
      }
    }
    expect(withHeader, 112);
  });

  test('metadata: pages and juz', () {
    expect(quran.pageStarts.length, 604);
    expect(quran.juzStarts.length, 30);
    expect(quran.pageOf(const VerseRef(1, 1)), 1);
    expect(quran.pageOf(const VerseRef(2, 1)), 2);
    expect(quran.pageOf(const VerseRef(114, 6)), 604);
    expect(quran.juzOf(const VerseRef(2, 142)), 2);
    expect(quran.juzOf(const VerseRef(2, 141)), 1);
    expect(quran.juzOf(const VerseRef(114, 1)), 30);
    // Every verse is on exactly one page.
    var total = 0;
    for (var p = 1; p <= 604; p++) {
      final onPage = quran.versesOnPage(p);
      expect(onPage, isNotEmpty, reason: 'page $p');
      total += onPage.length;
    }
    expect(total, 6236);
  });
}
