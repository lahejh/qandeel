import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qandeel/quran/quran.dart';
import 'package:qandeel/quran/reading_state.dart';
import 'package:qandeel/settings/app_settings.dart';
import 'package:qandeel/storage/local_store.dart';

void main() {
  test('reading state is saved and loaded back', () {
    final store = MemoryStore();
    ReadingState.load(store)
      ..lastReadPage = 77
      ..toggleBookmark(const VerseRef(18, 10))
      ..toggleBookmark(const VerseRef(2, 255));

    final reloaded = ReadingState.load(store);
    expect(reloaded.lastReadPage, 77);
    expect(reloaded.bookmarks, const [VerseRef(2, 255), VerseRef(18, 10)]);

    reloaded.toggleBookmark(const VerseRef(2, 255));
    expect(ReadingState.load(store).bookmarks, const [VerseRef(18, 10)]);
  });

  test('settings are saved and loaded back', () {
    final store = MemoryStore();
    AppSettings.load(store)
      ..locale = const Locale('ar')
      ..themeMode = ThemeMode.dark
      ..quranFontSize = 30;

    final reloaded = AppSettings.load(store);
    expect(reloaded.locale, const Locale('ar'));
    expect(reloaded.themeMode, ThemeMode.dark);
    expect(reloaded.quranFontSize, 30);

    reloaded.locale = null; // back to "same as phone"
    expect(AppSettings.load(store).locale, isNull);
  });

  test('damaged or unknown saved values fall back safely', () {
    final store = MemoryStore({
      StoreKeys.lastReadPage: '999',
      StoreKeys.bookmarks: 'x,2:255,,200:1,3',
      StoreKeys.locale: 'xx',
      StoreKeys.themeMode: 'purple',
      StoreKeys.quranFontSize: '500',
    });
    final reading = ReadingState.load(store);
    expect(reading.lastReadPage, isNull);
    expect(reading.bookmarks, const [VerseRef(2, 255)]);

    final settings = AppSettings.load(store);
    expect(settings.locale, isNull);
    expect(settings.themeMode, ThemeMode.system);
    expect(settings.quranFontSize, AppSettings.maxQuranFontSize);
  });

  test('only the listed keys are stored', () {
    final store = MemoryStore();
    AppSettings.load(store)
      ..locale = const Locale('en')
      ..themeMode = ThemeMode.light
      ..quranFontSize = 20;
    ReadingState.load(store)
      ..lastReadPage = 3
      ..toggleBookmark(const VerseRef(1, 1));
    expect(StoreKeys.all.containsAll(store.values.keys), isTrue);
  });
}
