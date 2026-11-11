// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'قنديل';

  @override
  String get tabQuran => 'القرآن';

  @override
  String get tabAzkar => 'الأذكار';

  @override
  String get tabMemorize => 'الحفظ';

  @override
  String get tabKids => 'الأطفال';

  @override
  String get settings => 'الإعدادات';

  @override
  String get comingSoon => 'قريبًا إن شاء الله';

  @override
  String get azkarPlaceholder =>
      'أذكار الصباح والمساء وبعد الصلاة والنوم، مع العدّاد والمصادر.';

  @override
  String get memorizePlaceholder =>
      'التكرار، والإخفاء والتسميع، وخطة مراجعة لطيفة.';

  @override
  String get kidsPlaceholder =>
      'الحروف، وقصار السور، والأدعية، وألعاب تعليمية هادئة للأطفال.';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'مثل لغة الجهاز';

  @override
  String get theme => 'المظهر';

  @override
  String get themeSystem => 'مثل إعداد الجهاز';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get aboutPromise => 'مجاني دائمًا. بلا إعلانات. بلا حساب. بلا تتبّع.';

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get salam => 'السلام عليكم';

  @override
  String get greetingMorning => 'صباح الخير';

  @override
  String get greetingDay => 'طاب يومك';

  @override
  String get greetingEvening => 'مساء الخير';

  @override
  String get startReading => 'ابدأ القراءة';

  @override
  String startReadingPlace(String page, String juz) {
    return 'صفحة $page · الجزء $juz';
  }

  @override
  String get start => 'ابدأ';

  @override
  String get morningAzkar => 'أذكار الصباح';

  @override
  String get eveningAzkar => 'أذكار المساء';

  @override
  String get azkarCardSubtitle => 'دقائق من الذكر';

  @override
  String get memorizeCardSubtitle => 'اختر سورة لمراجعتها';

  @override
  String get kidsCardSubtitle => 'الحروف والسور والألعاب';

  @override
  String get continueReading => 'تابع القراءة';

  @override
  String get continueButton => 'تابع';

  @override
  String get surahsTab => 'السور';

  @override
  String get juzTab => 'الأجزاء';

  @override
  String get bookmarksTab => 'العلامات';

  @override
  String surahTitle(String name) {
    return 'سورة $name';
  }

  @override
  String juzTitle(String number) {
    return 'الجزء $number';
  }

  @override
  String pageNumber(String number) {
    return 'صفحة $number';
  }

  @override
  String verseCount(String count) {
    return '$count آية';
  }

  @override
  String get meccan => 'مكية';

  @override
  String get medinan => 'مدنية';

  @override
  String verseRef(String surah, String verse) {
    return 'سورة $surah، الآية $verse';
  }

  @override
  String startsAt(String place) {
    return 'يبدأ من $place';
  }

  @override
  String get addBookmark => 'أضف علامة';

  @override
  String get removeBookmark => 'احذف العلامة';

  @override
  String get noBookmarks =>
      'لا توجد علامات بعد. اضغط على آية أثناء القراءة لإضافة علامة.';

  @override
  String get sourcesTitle => 'عن التطبيق والمصادر';

  @override
  String get quranTextSource =>
      'نص القرآن: مشروع تنزيل (الرسم العثماني، الإصدار 1.1)، tanzil.net. يُستخدم كما هو دون تغيير وفق رخصة المشاع الإبداعي (نسب المصنف 3.0).';
}
