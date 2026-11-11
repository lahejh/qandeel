import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qandeel/app.dart';
import 'package:qandeel/quran/quran.dart';
import 'package:qandeel/quran/reader_screen.dart';
import 'package:qandeel/quran/reading_state.dart';
import 'package:qandeel/settings/app_settings.dart';

// Loaded once from the bundled verified files.
final quran = Quran.parse(
  text: File('assets/quran/quran-uthmani.txt').readAsStringSync(),
  metadata: File('assets/quran/quran-data.xml').readAsStringSync(),
);

final morning = DateTime(2026, 11, 11, 8);
final evening = DateTime(2026, 11, 11, 20);

QandeelApp app(
  String lang, {
  DateTime? now,
  ThemeMode theme = ThemeMode.light,
  ReadingState? reading,
}) => QandeelApp(
  quran: quran,
  settings: AppSettings(locale: Locale(lang), themeMode: theme),
  reading: reading,
  now: now ?? morning,
);

void main() {
  testWidgets('Home shows greeting, reading card and five tabs', (
    tester,
  ) async {
    await tester.pumpWidget(app('en'));
    await tester.pumpAndSettle();

    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text('سورة الفاتحة'), findsOneWidget);
    expect(find.text('Morning azkar'), findsOneWidget);
    for (final tab in ['Home', 'Quran', 'Azkar', 'Memorize', 'Kids']) {
      expect(find.text(tab), findsWidgets);
    }
  });

  testWidgets('Evening shows evening greeting and evening azkar', (
    tester,
  ) async {
    await tester.pumpWidget(app('en', now: evening));
    await tester.pumpAndSettle();

    expect(find.text('Good evening'), findsOneWidget);
    expect(find.text('Evening azkar'), findsOneWidget);
  });

  testWidgets('Start opens page 1; home then shows Continue reading', (
    tester,
  ) async {
    final reading = ReadingState();
    await tester.pumpWidget(app('en', reading: reading));
    await tester.pumpAndSettle();
    expect(find.text('START READING'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.byType(ReaderScreen), findsOneWidget);
    expect(find.text('Surah Al-Faatiha'), findsOneWidget);
    expect(find.text('Page 1 · Juz 1'), findsOneWidget);
    expect(reading.lastReadPage, 1);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('CONTINUE READING'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Continue reading shows the last page and its surah', (
    tester,
  ) async {
    await tester.pumpWidget(app('en', reading: ReadingState(lastReadPage: 50)));
    await tester.pumpAndSettle();
    final first = quran.versesOnPage(50).first.ref;
    expect(
      find.text('سورة ${quran.surah(first.surah).nameArabic}'),
      findsOneWidget,
    );
    expect(find.text('Page 50 · Juz ${quran.juzOf(first)}'), findsOneWidget);
  });

  testWidgets('Quran tab lists surahs; tapping one opens its page', (
    tester,
  ) async {
    final reading = ReadingState();
    await tester.pumpWidget(app('en', reading: reading));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quran'));
    await tester.pumpAndSettle();

    expect(find.text('Surah Al-Faatiha'), findsOneWidget);
    await tester.tap(find.text('Surah Al-Baqara'));
    await tester.pumpAndSettle();
    expect(find.byType(ReaderScreen), findsOneWidget);
    expect(reading.lastReadPage, 2);
    // Basmala header is shown separately above Al-Baqara.
    expect(
      find.text(quran.verse(const VerseRef(2, 1)).basmalaHeader!),
      findsOneWidget,
    );
  });

  testWidgets('Swiping turns the page like a mushaf', (tester) async {
    final reading = ReadingState();
    await tester.pumpWidget(app('en', reading: reading));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    // The next page comes from the left: drag from left to right.
    await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
    await tester.pumpAndSettle();
    expect(reading.lastReadPage, 2);
  });

  testWidgets('Juz and bookmarks tabs', (tester) async {
    final reading = ReadingState(bookmarks: [const VerseRef(2, 255)]);
    await tester.pumpWidget(app('en', reading: reading));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quran'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Juz'));
    await tester.pumpAndSettle();
    expect(find.text('Juz 1'), findsOneWidget);

    await tester.tap(find.text('Bookmarks'));
    await tester.pumpAndSettle();
    expect(find.text('Surah Al-Baqara, verse 255'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove bookmark'));
    await tester.pumpAndSettle();
    expect(reading.bookmarks, isEmpty);
    expect(find.textContaining('No bookmarks yet'), findsOneWidget);
  });

  testWidgets('Azkar card opens Azkar', (tester) async {
    await tester.pumpWidget(app('en'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Morning azkar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Morning, evening'), findsOneWidget);
  });

  testWidgets('Arabic shows Arabic text and right-to-left layout', (
    tester,
  ) async {
    await tester.pumpWidget(app('ar', theme: ThemeMode.dark));
    await tester.pumpAndSettle();

    expect(find.text('صباح الخير'), findsOneWidget);
    expect(find.text('الرئيسية'), findsWidgets);
    final context = tester.element(find.byType(Scaffold).first);
    expect(Directionality.of(context), TextDirection.rtl);
  });

  testWidgets('Settings can switch language and theme', (tester) async {
    final settings = AppSettings(locale: const Locale('en'));
    await tester.pumpWidget(
      QandeelApp(quran: quran, settings: settings, now: morning),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(settings.themeMode, ThemeMode.dark);

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(settings.locale, const Locale('ar'));
    expect(find.text('الإعدادات'), findsOneWidget);
  });

  testWidgets('Arabic Quran index uses Arabic names and digits', (
    tester,
  ) async {
    await tester.pumpWidget(app('ar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('القرآن').last);
    await tester.pumpAndSettle();
    expect(find.text('سورة ${quran.surah(1).nameArabic}'), findsOneWidget);
    expect(find.text('٧ آية · مكية'), findsOneWidget);
  });

  testWidgets('Settings credits the Quran text source', (tester) async {
    await tester.pumpWidget(app('en'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.textContaining('Tanzil'), 100);
    expect(find.textContaining('tanzil.net'), findsOneWidget);
  });
}
