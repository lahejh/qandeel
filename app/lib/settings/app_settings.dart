import 'package:flutter/material.dart';

import '../storage/local_store.dart';

/// User preferences: language, theme and Quran text size. Saved on the
/// device through [LocalStore] whenever they change (never online).
class AppSettings extends ChangeNotifier {
  AppSettings({
    this._locale,
    this._themeMode = ThemeMode.system,
    this._quranFontSize = defaultQuranFontSize,
    LocalStore? store,
  }) : _store = store ?? MemoryStore();

  /// Reads saved settings. Unknown values fall back to the defaults.
  factory AppSettings.load(LocalStore store) {
    final code = store.getString(StoreKeys.locale);
    final size = double.tryParse(
      store.getString(StoreKeys.quranFontSize) ?? '',
    );
    return AppSettings(
      locale: supportedLocales.where((l) => l.languageCode == code).firstOrNull,
      themeMode:
          ThemeMode.values
              .where((m) => m.name == store.getString(StoreKeys.themeMode))
              .firstOrNull ??
          ThemeMode.system,
      quranFontSize: size == null
          ? defaultQuranFontSize
          : size.clamp(minQuranFontSize, maxQuranFontSize),
      store: store,
    );
  }

  /// Languages the interface supports. Arabic and English first.
  static const supportedLocales = [Locale('en'), Locale('ar')];

  static const defaultQuranFontSize = 24.0;
  static const minQuranFontSize = 18.0;
  static const maxQuranFontSize = 40.0;

  Locale? _locale;
  ThemeMode _themeMode;
  double _quranFontSize;
  final LocalStore _store;

  /// `null` means "same as the phone".
  Locale? get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  /// Size of the Quran text in the reader.
  double get quranFontSize => _quranFontSize;

  set locale(Locale? value) {
    if (value == _locale) return;
    _locale = value;
    if (value == null) {
      _store.remove(StoreKeys.locale);
    } else {
      _store.setString(StoreKeys.locale, value.languageCode);
    }
    notifyListeners();
  }

  set themeMode(ThemeMode value) {
    if (value == _themeMode) return;
    _themeMode = value;
    _store.setString(StoreKeys.themeMode, value.name);
    notifyListeners();
  }

  set quranFontSize(double value) {
    final v = value.clamp(minQuranFontSize, maxQuranFontSize);
    if (v == _quranFontSize) return;
    _quranFontSize = v;
    _store.setString(StoreKeys.quranFontSize, '$v');
    notifyListeners();
  }
}
