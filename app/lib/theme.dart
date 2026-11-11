import 'package:flutter/material.dart';

/// Qandeel colors: calm deep green with warm lantern gold.
/// Day: soft off-white. Night: deep green-black.
class QandeelColors {
  static const green = Color(0xFF0E4D45);
  static const gold = Color(0xFFF2C063);
  static const onGold = Color(0xFF2B2108);

  static const dayBackground = Color(0xFFF5F6F2);
  static const daySurface = Color(0xFFFFFFFF);
  static const dayBorder = Color(0xFFE3E7E2);
  static const dayText = Color(0xFF1B2925);
  static const dayMuted = Color(0xFF55625E);

  static const nightBackground = Color(0xFF0B1513);
  static const nightSurface = Color(0xFF13211E);
  static const nightBorder = Color(0xFF23342F);
  static const nightText = Color(0xFFEAF1EE);
  static const nightMuted = Color(0xFFA3B4AE);
}

/// Interface fonts are bundled (never downloaded): IBM Plex Sans for Latin,
/// IBM Plex Sans Arabic for Arabic. Amiri is used for surah names.
const uiFont = 'IBMPlexSans';
const uiFontFallback = ['IBMPlexSansArabic'];
const headingArabicFont = 'Amiri';

ThemeData buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: QandeelColors.green,
        brightness: brightness,
      ).copyWith(
        primary: isDark ? const Color(0xFF9FD8C8) : QandeelColors.green,
        onPrimary: isDark ? const Color(0xFF0B1513) : Colors.white,
        tertiary: QandeelColors.gold,
        surface: isDark
            ? QandeelColors.nightBackground
            : QandeelColors.dayBackground,
        onSurface: isDark ? QandeelColors.nightText : QandeelColors.dayText,
        onSurfaceVariant: isDark
            ? QandeelColors.nightMuted
            : QandeelColors.dayMuted,
        surfaceContainerLowest: isDark
            ? QandeelColors.nightSurface
            : QandeelColors.daySurface,
        outlineVariant: isDark
            ? QandeelColors.nightBorder
            : QandeelColors.dayBorder,
      );

  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    fontFamily: uiFont,
    fontFamilyFallback: uiFontFallback,
    scaffoldBackgroundColor: scheme.surface,
  );

  return base.copyWith(
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark ? const Color(0xFF0F1B18) : Colors.white,
      indicatorColor: isDark
          ? const Color(0xFF2A2A17)
          : const Color(0xFFDDEEE8),
      surfaceTintColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? (isDark ? QandeelColors.gold : QandeelColors.green)
              : scheme.onSurfaceVariant,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: uiFont,
          fontFamilyFallback: uiFontFallback,
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
          color: states.contains(WidgetState.selected)
              ? (isDark ? QandeelColors.gold : QandeelColors.green)
              : scheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}
