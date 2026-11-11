import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qandeel/app.dart';
import 'package:qandeel/settings/app_settings.dart';

void main() {
  testWidgets('App starts with the four sections in English', (tester) async {
    await tester.pumpWidget(
      QandeelApp(settings: AppSettings(locale: const Locale('en'))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Qandeel'), findsOneWidget);
    for (final tab in ['Quran', 'Azkar', 'Memorize', 'Kids']) {
      expect(find.text(tab), findsWidgets);
    }
  });

  testWidgets('Tapping a tab shows that section', (tester) async {
    await tester.pumpWidget(
      QandeelApp(settings: AppSettings(locale: const Locale('en'))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Azkar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Morning, evening'), findsOneWidget);

    await tester.tap(find.text('Kids'));
    await tester.pumpAndSettle();
    expect(find.textContaining('calm learning games'), findsOneWidget);
  });

  testWidgets('Arabic shows Arabic text and right-to-left layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      QandeelApp(settings: AppSettings(locale: const Locale('ar'))),
    );
    await tester.pumpAndSettle();

    expect(find.text('قنديل'), findsOneWidget);
    expect(find.text('القرآن'), findsWidgets);
    final context = tester.element(find.byType(Scaffold).first);
    expect(Directionality.of(context), TextDirection.rtl);
  });

  testWidgets('Settings can switch language and theme', (tester) async {
    final settings = AppSettings(locale: const Locale('en'));
    await tester.pumpWidget(QandeelApp(settings: settings));
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
