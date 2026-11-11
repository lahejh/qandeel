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
  String get quranPlaceholder =>
      'اقرأ القرآن بترتيب مصحف المدينة، مع العلامات والبحث.';

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
}
