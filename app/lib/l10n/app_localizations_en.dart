// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Qandeel';

  @override
  String get tabQuran => 'Quran';

  @override
  String get tabAzkar => 'Azkar';

  @override
  String get tabMemorize => 'Memorize';

  @override
  String get tabKids => 'Kids';

  @override
  String get settings => 'Settings';

  @override
  String get comingSoon => 'Coming soon, in sha Allah';

  @override
  String get quranPlaceholder =>
      'Read the Quran in the Madinah Mushaf layout, with bookmarks and search.';

  @override
  String get azkarPlaceholder =>
      'Morning, evening, after-prayer and sleep azkar, with counters and references.';

  @override
  String get memorizePlaceholder =>
      'Repeat, hide-and-recite, and a gentle revision plan.';

  @override
  String get kidsPlaceholder =>
      'Letters, short surahs, duas and calm learning games for children.';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Same as phone';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'Same as phone';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get aboutPromise => 'Free forever. No ads. No account. No tracking.';
}
