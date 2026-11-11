import 'package:flutter/material.dart';

/// User preferences for language and theme.
///
/// Kept in memory for now. Saving them on the device (never online) will be
/// added later with a small, owner-approved storage package.
class AppSettings extends ChangeNotifier {
  AppSettings({this._locale, this._themeMode = ThemeMode.system});

  /// Languages the interface supports. Arabic and English first.
  static const supportedLocales = [Locale('en'), Locale('ar')];

  Locale? _locale;
  ThemeMode _themeMode;

  /// `null` means "same as the phone".
  Locale? get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  set locale(Locale? value) {
    if (value == _locale) return;
    _locale = value;
    notifyListeners();
  }

  set themeMode(ThemeMode value) {
    if (value == _themeMode) return;
    _themeMode = value;
    notifyListeners();
  }
}
