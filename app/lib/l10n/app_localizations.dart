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

  /// Placeholder description of the Quran section.
  ///
  /// In en, this message translates to:
  /// **'Read the Quran in the Madinah Mushaf layout, with bookmarks and search.'**
  String get quranPlaceholder;

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

  /// Where reading starts: page and juz.
  ///
  /// In en, this message translates to:
  /// **'Page 1 · Juz 1'**
  String get startReadingPlace;

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
