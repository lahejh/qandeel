// Integrity checks for the azkar database (CLAUDE.md §1). The data is not
// shown in the app yet; see content/azkar/SOURCE.md.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const appDb = 'assets/azkar/hisn_elmoslem.db';
const sourceDb = '../content/azkar/hisn_elmoslem.db';

void main() {
  test('app copy is byte-for-byte identical to content/azkar', () {
    expect(File(appDb).readAsBytesSync(), File(sourceDb).readAsBytesSync());
  });

  test('size matches content/azkar/SOURCE.md', () {
    expect(File(appDb).lengthSync(), 344064);
  });

  test('file is an SQLite database', () {
    final header = File(appDb).openSync().readSync(16);
    expect(ascii.decode(header.sublist(0, 15)), 'SQLite format 3');
  });

  test('verification report exists and covers every entry', () {
    final report = File('../docs/azkar-verification.md').readAsStringSync();
    expect(report, contains('Entries checked: **335**'));
  });
}
