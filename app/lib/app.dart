import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'home/home_shell.dart';
import 'l10n/app_localizations.dart';
import 'quran/quran.dart';
import 'quran/quran_scope.dart';
import 'quran/reading_state.dart';
import 'settings/app_settings.dart';
import 'theme.dart';

class QandeelApp extends StatelessWidget {
  QandeelApp({
    super.key,
    required this.quran,
    AppSettings? settings,
    ReadingState? reading,
    this.now,
  }) : settings = settings ?? AppSettings(),
       reading = reading ?? ReadingState();

  final Quran quran;
  final AppSettings settings;
  final ReadingState reading;

  /// For tests; defaults to the current time.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: settings.themeMode,
        locale: settings.locale,
        supportedLocales: AppSettings.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // QuranScope sits above the Navigator so pushed screens see it too.
        builder: (context, child) => QuranScope(
          quran: quran,
          settings: settings,
          reading: reading,
          child: child!,
        ),
        home: HomeShell(settings: settings, now: now),
      ),
    );
  }
}
