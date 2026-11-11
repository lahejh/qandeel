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

  @override
  String get textSize => 'حجم الخط';

  @override
  String get search => 'بحث';

  @override
  String get searchHint => 'سورة، أو ٢:٢٥٥، أو كلمات';

  @override
  String get searchHelp =>
      'ابحث باسم السورة أو رقمها، أو برقم آية مثل ٢:٢٥٥، أو بكلمات عربية (دون الحاجة إلى التشكيل).';

  @override
  String get noResults => 'لا توجد نتائج.';

  @override
  String get clearSearch => 'مسح';

  @override
  String verseResults(String count) {
    return 'الآيات ($count)';
  }

  @override
  String moreResults(String count) {
    return 'تُعرض أول $count نتيجة. أضف كلمة أخرى لتضييق البحث.';
  }

  @override
  String get playFromHere => 'استمع من هنا';

  @override
  String get playPage => 'استمع لهذه الصفحة';

  @override
  String get repeatVerse => 'كرّر هذه الآية';

  @override
  String get repeatPage => 'كرّر هذه الصفحة';

  @override
  String repeatCount(String count) {
    return 'التكرار: $count×';
  }

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get resume => 'متابعة';

  @override
  String get stopPlayback => 'إيقاف';

  @override
  String get recitation => 'التلاوة';

  @override
  String get reciter => 'القارئ';

  @override
  String get saveRecitations => 'حفظ التلاوات على الجهاز';

  @override
  String get saveRecitationsHint =>
      'تُحمَّل كل آية مرة واحدة ثم تعمل دون إنترنت. عند الإيقاف: استماع عبر الإنترنت فقط.';

  @override
  String get downloads => 'التلاوات المحفوظة';

  @override
  String get delete => 'حذف';

  @override
  String get cancel => 'إلغاء';

  @override
  String deleteConfirm(String name) {
    return 'حذف كل الآيات المحفوظة بصوت $name؟';
  }

  @override
  String savedSize(String count, String size) {
    return '$count آية · $size م.ب';
  }

  @override
  String get nothingSaved => 'لا شيء محفوظ';

  @override
  String get connectToDownload =>
      'هذه الآية غير محفوظة على الجهاز بعد. اتصل بالإنترنت لتحميلها.';

  @override
  String reciterUnavailable(String name) {
    return 'تلاوة $name غير متاحة الآن. هل تريد اختيار قارئ آخر؟';
  }

  @override
  String get notNow => 'ليس الآن';

  @override
  String get recitationSource =>
      'التلاوات الصوتية: الشبكة الإسلامية (alquran.cloud)، بترخيص من القرّاء أو ورثتهم للاستخدام المجاني غير التجاري. وستُستخدم تسجيلات مجمع الملك فهد لطباعة المصحف الشريف أولًا عند توفرها مجددًا.';
}
