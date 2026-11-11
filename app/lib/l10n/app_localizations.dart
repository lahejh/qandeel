import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// App name shown in the title bar and launcher.
  ///
  /// In en, this message translates to:
  /// **'Qandeel'**
  String get appTitle;

  /// Bottom navigation tab: Quran reader.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get tabQuran;

  /// Bottom navigation tab: daily remembrances.
  ///
  /// In en, this message translates to:
  /// **'Azkar'**
  String get tabAzkar;

  /// Bottom navigation tab: memorization tools.
  ///
  /// In en, this message translates to:
  /// **'Memorize'**
  String get tabMemorize;

  /// Bottom navigation tab: kids section.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get tabKids;

  /// Settings screen title and button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Placeholder text for sections not built yet.
  ///
  /// In en, this message translates to:
  /// **'Coming soon, in sha Allah'**
  String get comingSoon;

  /// Placeholder description of the Azkar section.
  ///
  /// In en, this message translates to:
  /// **'Morning, evening, after-prayer and sleep azkar, with counters and references.'**
  String get azkarPlaceholder;

  /// Placeholder description of the Memorize section.
  ///
  /// In en, this message translates to:
  /// **'Repeat, hide-and-recite, and a gentle revision plan.'**
  String get memorizePlaceholder;

  /// Placeholder description of the Kids section.
  ///
  /// In en, this message translates to:
  /// **'Letters, short surahs, duas and calm learning games for children.'**
  String get kidsPlaceholder;

  /// Settings: language option label.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Settings: follow the device language.
  ///
  /// In en, this message translates to:
  /// **'Same as phone'**
  String get languageSystem;

  /// Settings: theme option label.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Settings: follow the device light/dark setting.
  ///
  /// In en, this message translates to:
  /// **'Same as phone'**
  String get themeSystem;

  /// Settings: light theme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Settings: dark theme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Short promise shown in settings/about.
  ///
  /// In en, this message translates to:
  /// **'Free forever. No ads. No account. No tracking.'**
  String get aboutPromise;

  /// Bottom navigation tab: home dashboard.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// Greeting shown at the top of the home screen.
  ///
  /// In en, this message translates to:
  /// **'Assalamu alaikum'**
  String get salam;

  /// Home greeting before noon.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// Home greeting from noon until late afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingDay;

  /// Home greeting in the evening and night.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// Label on the main home card when nothing has been read yet.
  ///
  /// In en, this message translates to:
  /// **'START READING'**
  String get startReading;

  /// Where reading starts or continues: page and juz.
  ///
  /// In en, this message translates to:
  /// **'Page {page} · Juz {juz}'**
  String startReadingPlace(String page, String juz);

  /// Button that opens the Quran reader.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Home card title before Asr time (approx.).
  ///
  /// In en, this message translates to:
  /// **'Morning azkar'**
  String get morningAzkar;

  /// Home card title in the evening.
  ///
  /// In en, this message translates to:
  /// **'Evening azkar'**
  String get eveningAzkar;

  /// Subtitle on the home azkar card.
  ///
  /// In en, this message translates to:
  /// **'A few minutes of remembrance'**
  String get azkarCardSubtitle;

  /// Subtitle on the home Memorize card.
  ///
  /// In en, this message translates to:
  /// **'Choose a surah to revise'**
  String get memorizeCardSubtitle;

  /// Subtitle on the home Kids card.
  ///
  /// In en, this message translates to:
  /// **'Letters, surahs and games'**
  String get kidsCardSubtitle;

  /// Label on the main home card after the reader was opened.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE READING'**
  String get continueReading;

  /// Button that reopens the Quran reader at the last page.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Quran index tab: list of surahs.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get surahsTab;

  /// Quran index tab: list of the 30 juz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get juzTab;

  /// Quran index tab: bookmarked verses.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksTab;

  /// Surah title. name = Arabic name in Arabic UI, transliterated in English UI.
  ///
  /// In en, this message translates to:
  /// **'Surah {name}'**
  String surahTitle(String name);

  /// Title of a juz.
  ///
  /// In en, this message translates to:
  /// **'Juz {number}'**
  String juzTitle(String number);

  /// Mushaf page number.
  ///
  /// In en, this message translates to:
  /// **'Page {number}'**
  String pageNumber(String number);

  /// Number of verses in a surah (no plural forms, kept simple).
  ///
  /// In en, this message translates to:
  /// **'{count} verses'**
  String verseCount(String count);

  /// Surah revealed in Makkah.
  ///
  /// In en, this message translates to:
  /// **'Meccan'**
  String get meccan;

  /// Surah revealed in Madinah.
  ///
  /// In en, this message translates to:
  /// **'Medinan'**
  String get medinan;

  /// A verse reference.
  ///
  /// In en, this message translates to:
  /// **'Surah {surah}, verse {verse}'**
  String verseRef(String surah, String verse);

  /// Where a juz starts.
  ///
  /// In en, this message translates to:
  /// **'Starts at {place}'**
  String startsAt(String place);

  /// Verse menu: bookmark this verse.
  ///
  /// In en, this message translates to:
  /// **'Add bookmark'**
  String get addBookmark;

  /// Verse menu: remove the bookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get removeBookmark;

  /// Empty bookmarks list.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet. Tap a verse while reading to bookmark it.'**
  String get noBookmarks;

  /// Settings: section listing content sources.
  ///
  /// In en, this message translates to:
  /// **'About & sources'**
  String get sourcesTitle;

  /// Credit for the Quran text (required by Tanzil).
  ///
  /// In en, this message translates to:
  /// **'Quran text: Tanzil Project (Uthmani, version 1.1), tanzil.net. Used verbatim under the Creative Commons Attribution 3.0 license.'**
  String get quranTextSource;

  /// Reader: Quran text size control.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// Search button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Search field hint.
  ///
  /// In en, this message translates to:
  /// **'Surah, 2:255, or Arabic words'**
  String get searchHint;

  /// Help text before typing.
  ///
  /// In en, this message translates to:
  /// **'Search by surah name or number, a verse like 2:255, or Arabic words (no need for diacritics).'**
  String get searchHelp;

  /// Search found nothing.
  ///
  /// In en, this message translates to:
  /// **'No results.'**
  String get noResults;

  /// Clear the search field.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearSearch;

  /// Header for verse results with total count.
  ///
  /// In en, this message translates to:
  /// **'Verses ({count})'**
  String verseResults(String count);

  /// Shown when there are more results than listed.
  ///
  /// In en, this message translates to:
  /// **'Showing the first {count}. Add another word to narrow the search.'**
  String moreResults(String count);

  /// Verse menu: recite from this verse to the end of the surah.
  ///
  /// In en, this message translates to:
  /// **'Play from here'**
  String get playFromHere;

  /// Verse menu: recite every verse on this page.
  ///
  /// In en, this message translates to:
  /// **'Play this page'**
  String get playPage;

  /// Verse menu: recite this verse several times.
  ///
  /// In en, this message translates to:
  /// **'Repeat this verse'**
  String get repeatVerse;

  /// Verse menu: recite this page several times.
  ///
  /// In en, this message translates to:
  /// **'Repeat this page'**
  String get repeatPage;

  /// Label for the chosen repeat count.
  ///
  /// In en, this message translates to:
  /// **'Repeat: {count}×'**
  String repeatCount(String count);

  /// Player button.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Player button.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// Player button.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopPlayback;

  /// Settings section title.
  ///
  /// In en, this message translates to:
  /// **'Recitation'**
  String get recitation;

  /// Settings: reciter choice.
  ///
  /// In en, this message translates to:
  /// **'Reciter'**
  String get reciter;

  /// Settings switch: stream and save (on) or stream only (off).
  ///
  /// In en, this message translates to:
  /// **'Save recitations on this phone'**
  String get saveRecitations;

  /// Explains the save switch.
  ///
  /// In en, this message translates to:
  /// **'Each verse is downloaded once and then plays without internet. Off: listen online only.'**
  String get saveRecitationsHint;

  /// Storage screen title and settings entry.
  ///
  /// In en, this message translates to:
  /// **'Saved recitations'**
  String get downloads;

  /// Delete button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm deleting one reciter's files.
  ///
  /// In en, this message translates to:
  /// **'Delete all saved verses recited by {name}?'**
  String deleteConfirm(String name);

  /// Saved verses count and size.
  ///
  /// In en, this message translates to:
  /// **'{count} verses · {size} MB'**
  String savedSize(String count, String size);

  /// No files for this reciter.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved'**
  String get nothingSaved;

  /// Shown when offline and the verse is not saved.
  ///
  /// In en, this message translates to:
  /// **'This verse is not saved on this phone yet. Connect to the internet to download it.'**
  String get connectToDownload;

  /// Asks before switching reciter (never switched automatically).
  ///
  /// In en, this message translates to:
  /// **'Recitation by {name} is not available right now. Would you like to choose another reciter?'**
  String reciterUnavailable(String name);

  /// Dismiss button.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// Credit for recitation audio.
  ///
  /// In en, this message translates to:
  /// **'Recitation audio: Islamic Network (alquran.cloud), recordings licensed by the reciters or their estates for free, non-commercial use. Recordings of the King Fahd Glorious Qur\'an Printing Complex will be used first once they are available again.'**
  String get recitationSource;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
