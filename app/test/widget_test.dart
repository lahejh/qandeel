import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qandeel/app.dart';
import 'package:qandeel/settings/app_settings.dart';

final morning = DateTime(2026, 11, 11, 8);
final evening = DateTime(2026, 11, 11, 20);

QandeelApp app(
  String lang, {
  DateTime? now,
  ThemeMode theme = ThemeMode.light,
}) => QandeelApp(
  settings: AppSettings(locale: Locale(lang), themeMode: theme),
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

  testWidgets('Start opens the Quran tab; azkar card opens Azkar', (
    tester,
  ) async {
    await tester.pumpWidget(app('en'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Madinah Mushaf'), findsOneWidget);

    await tester.tap(find.text('Home'));
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
    await tester.pumpWidget(QandeelApp(settings: settings, now: morning));
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
}
