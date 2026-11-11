import 'package:flutter/widgets.dart';

import 'quran.dart';
import 'reading_state.dart';

/// Makes the loaded [Quran] and the [ReadingState] available to every screen.
/// Widgets that read [ReadingState] through [of] rebuild when it changes.
class QuranScope extends InheritedNotifier<ReadingState> {
  const QuranScope({
    super.key,
    required this.quran,
    required ReadingState reading,
    required super.child,
  }) : super(notifier: reading);

  final Quran quran;

  ReadingState get reading => notifier!;

  static QuranScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<QuranScope>();
    assert(scope != null, 'No QuranScope above this widget');
    return scope!;
  }
}

/// Numbers in the user's language: Arabic-Indic digits (٠–٩) in Arabic.
String localNumber(BuildContext context, int n) {
  final s = n.toString();
  if (Localizations.localeOf(context).languageCode != 'ar') return s;
  return arabicDigits(s);
}

/// Converts 0–9 to Arabic-Indic digits ٠–٩ (used for verse-end markers).
String arabicDigits(String s) => String.fromCharCodes(
  s.codeUnits.map((c) => c >= 0x30 && c <= 0x39 ? c - 0x30 + 0x0660 : c),
);
