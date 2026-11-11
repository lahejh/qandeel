import 'package:flutter/material.dart';

/// Calm colors inspired by a lantern at night: deep green with warm gold.
const _seed = Color(0xFF0F5C4D);
const _lanternGold = Color(0xFFC9973F);

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: brightness,
    tertiary: _lanternGold,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
