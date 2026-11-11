import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// Small key-value storage for user data that stays on this device:
/// settings, last-read page, bookmarks. Never synced or sent anywhere by the
/// app (CLAUDE.md §2).
///
/// The rest of the app only sees this interface, so the storage package can
/// be replaced in a yearly update without touching other code.
abstract class LocalStore {
  String? getString(String key);

  /// Saves in the background; callers do not wait.
  void setString(String key, String value);

  void remove(String key);
}

/// Every key the app stores. Listed in one place so caretakers can see
/// exactly what is kept on the device.
class StoreKeys {
  static const locale =
      'settings.locale'; // "en", "ar"; absent = phone language
  static const themeMode = 'settings.themeMode'; // "light", "dark", "system"
  static const quranFontSize = 'settings.quranFontSize'; // e.g. "26"
  static const lastReadPage = 'quran.lastReadPage'; // "1".."604"
  static const bookmarks = 'quran.bookmarks'; // "2:255,18:10"
  static const reciter = 'audio.reciter'; // reciter id, e.g. "husary"
  static const saveRecitations = 'audio.save'; // "true" = stream and save
  static const wifiOnly = 'audio.wifiOnly'; // "true" = save only on Wi-Fi

  static const all = {
    locale,
    themeMode,
    quranFontSize,
    lastReadPage,
    bookmarks,
    reciter,
    saveRecitations,
    wifiOnly,
  };
}

/// Storage on the phone, using the Flutter team's `shared_preferences`
/// package (Android SharedPreferences / iOS UserDefaults). No network.
class DeviceStore implements LocalStore {
  DeviceStore._(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static Future<DeviceStore> open() async => DeviceStore._(
    await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: StoreKeys.all,
      ),
    ),
  );

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  void setString(String key, String value) =>
      unawaited(_prefs.setString(key, value));

  @override
  void remove(String key) => unawaited(_prefs.remove(key));
}

/// In-memory storage for tests (and a safe fallback).
class MemoryStore implements LocalStore {
  MemoryStore([Map<String, String>? values]) : values = {...?values};

  final Map<String, String> values;

  @override
  String? getString(String key) => values[key];

  @override
  void setString(String key, String value) => values[key] = value;

  @override
  void remove(String key) => values.remove(key);
}
