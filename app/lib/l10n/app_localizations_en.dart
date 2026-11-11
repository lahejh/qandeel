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

  @override
  String get tabHome => 'Home';

  @override
  String get salam => 'Assalamu alaikum';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingDay => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get startReading => 'START READING';

  @override
  String startReadingPlace(String page, String juz) {
    return 'Page $page · Juz $juz';
  }

  @override
  String get start => 'Start';

  @override
  String get morningAzkar => 'Morning azkar';

  @override
  String get eveningAzkar => 'Evening azkar';

  @override
  String get azkarCardSubtitle => 'A few minutes of remembrance';

  @override
  String get memorizeCardSubtitle => 'Choose a surah to revise';

  @override
  String get kidsCardSubtitle => 'Letters, surahs and games';

  @override
  String get continueReading => 'CONTINUE READING';

  @override
  String get continueButton => 'Continue';

  @override
  String get surahsTab => 'Surahs';

  @override
  String get juzTab => 'Juz';

  @override
  String get bookmarksTab => 'Bookmarks';

  @override
  String surahTitle(String name) {
    return 'Surah $name';
  }

  @override
  String juzTitle(String number) {
    return 'Juz $number';
  }

  @override
  String pageNumber(String number) {
    return 'Page $number';
  }

  @override
  String verseCount(String count) {
    return '$count verses';
  }

  @override
  String get meccan => 'Meccan';

  @override
  String get medinan => 'Medinan';

  @override
  String verseRef(String surah, String verse) {
    return 'Surah $surah, verse $verse';
  }

  @override
  String startsAt(String place) {
    return 'Starts at $place';
  }

  @override
  String get addBookmark => 'Add bookmark';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String get noBookmarks =>
      'No bookmarks yet. Tap a verse while reading to bookmark it.';

  @override
  String get sourcesTitle => 'About & sources';

  @override
  String get quranTextSource =>
      'Quran text: Tanzil Project (Uthmani, version 1.1), tanzil.net. Used verbatim under the Creative Commons Attribution 3.0 license.';

  @override
  String get textSize => 'Text size';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Surah, 2:255, or Arabic words';

  @override
  String get searchHelp =>
      'Search by surah name or number, a verse like 2:255, or Arabic words (no need for diacritics).';

  @override
  String get noResults => 'No results.';

  @override
  String get clearSearch => 'Clear';

  @override
  String verseResults(String count) {
    return 'Verses ($count)';
  }

  @override
  String moreResults(String count) {
    return 'Showing the first $count. Add another word to narrow the search.';
  }
}
