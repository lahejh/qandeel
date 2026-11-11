import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../settings/app_settings.dart';
import '../theme.dart';
import 'quran.dart';
import 'quran_scope.dart';

/// Font for Quran text. Amiri (bundled, SIL OFL) for now; the KFGQPC
/// Uthmanic font replaces it once its license copy is saved (CLAUDE.md §5).
const quranFont = 'Amiri';

/// Mushaf reader: one screen per Madinah mushaf page (1–604), turned like a
/// printed mushaf (the next page comes from the left), whatever the app
/// language. Verses flow as text; the exact 15-line layout comes later with
/// a licensed line-layout dataset (see docs/NEXT-STEPS.md).
///
/// Tap a verse to bookmark it. The page being read is saved as the last-read
/// position. The text-size button changes the Quran text size (saved).
class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key, required this.initialPage});

  final int initialPage;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late final PageController _controller = PageController(
    initialPage: widget.initialPage - 1,
  );
  late int _page = widget.initialPage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Record the opened page (after this frame, to avoid notifying listeners
    // during build).
    final reading = QuranScope.of(context).reading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) reading.lastReadPage = _page;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _page = index + 1);
    QuranScope.of(context).reading.lastReadPage = _page;
  }

  void _showTextSize(BuildContext context) {
    final settings = QuranScope.of(context).settings;
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.textSize,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    const Icon(Icons.text_decrease),
                    Expanded(
                      child: Slider(
                        value: settings.quranFontSize,
                        min: AppSettings.minQuranFontSize,
                        max: AppSettings.maxQuranFontSize,
                        divisions: 11,
                        onChanged: (v) => settings.quranFontSize = v,
                      ),
                    ),
                    const Icon(Icons.text_increase),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final quran = QuranScope.of(context).quran;
    final first = quran.versesOnPage(_page).first.ref;
    final surah = quran.surah(first.surah);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.format_size),
            tooltip: l10n.textSize,
            onPressed: () => _showTextSize(context),
          ),
        ],
        title: Column(
          children: [
            Text(
              l10n.surahTitle(surahName(context, surah)),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            Text(
              '${l10n.pageNumber(localNumber(context, _page))} · '
              '${l10n.juzTitle(localNumber(context, quran.juzOf(first)))}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        // Mushaf page order: page 2 is to the left of page 1.
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: PageView.builder(
            controller: _controller,
            itemCount: Quran.pageCount,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) => ListenableBuilder(
              listenable: QuranScope.of(context).settings,
              builder: (context, _) =>
                  MushafPage(key: ValueKey(index), page: index + 1),
            ),
          ),
        ),
      ),
    );
  }
}

/// Surah name in the interface language: Arabic name in Arabic, the
/// transliterated name otherwise. Both come from Tanzil's metadata.
String surahName(BuildContext context, Surah s) =>
    Localizations.localeOf(context).languageCode == 'ar'
    ? s.nameArabic
    : s.nameTransliterated;

/// One mushaf page.
class MushafPage extends StatefulWidget {
  const MushafPage({super.key, required this.page});

  final int page;

  @override
  State<MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends State<MushafPage> {
  final _recognizers = <VerseRef, TapGestureRecognizer>{};
  VerseRef? _selected;

  @override
  void dispose() {
    for (final r in _recognizers.values) {
      r.dispose();
    }
    super.dispose();
  }

  TapGestureRecognizer _recognizerFor(VerseRef ref) => _recognizers.putIfAbsent(
    ref,
    () => TapGestureRecognizer()..onTap = () => _openVerseMenu(ref),
  );

  Future<void> _openVerseMenu(VerseRef ref) async {
    setState(() => _selected = ref);
    final scope = QuranScope.of(context);
    final l10n = AppLocalizations.of(context);
    final surah = scope.quran.surah(ref.surah);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final marked = scope.reading.isBookmarked(ref);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  l10n.verseRef(
                    surahName(context, surah),
                    localNumber(context, ref.ayah),
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ListTile(
                leading: Icon(
                  marked
                      ? Icons.bookmark_remove_outlined
                      : Icons.bookmark_add_outlined,
                ),
                title: Text(marked ? l10n.removeBookmark : l10n.addBookmark),
                onTap: () {
                  scope.reading.toggleBookmark(ref);
                  Navigator.of(sheetContext).pop();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (mounted) setState(() => _selected = null);
  }

  @override
  Widget build(BuildContext context) {
    final scope = QuranScope.of(context);
    final quran = scope.quran;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final verses = quran.versesOnPage(widget.page);

    final textStyle = TextStyle(
      fontFamily: quranFont,
      fontSize: scope.settings.quranFontSize,
      height: 2.1,
      color: scheme.onSurface,
    );
    final markColor = isDark ? QandeelColors.gold : QandeelColors.green;
    final highlight = (isDark ? QandeelColors.gold : QandeelColors.green)
        .withValues(alpha: 0.14);

    // Build blocks: a surah header (and basmala) starts a new block; verses
    // in between flow together as one paragraph.
    final blocks = <Widget>[];
    var spans = <InlineSpan>[];
    void flush() {
      if (spans.isEmpty) return;
      blocks.add(
        Text.rich(
          TextSpan(children: spans),
          style: textStyle,
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
        ),
      );
      spans = [];
    }

    for (final v in verses) {
      if (v.ref.ayah == 1) {
        flush();
        blocks.add(_SurahHeader(surah: quran.surah(v.ref.surah)));
        final basmala = v.basmalaHeader;
        if (basmala != null) {
          blocks.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                basmala,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: textStyle,
              ),
            ),
          );
        }
      }
      final marked = scope.reading.isBookmarked(v.ref);
      final selected = _selected == v.ref;
      spans.add(
        TextSpan(
          text: v.displayText,
          recognizer: _recognizerFor(v.ref),
          style: (marked || selected)
              ? TextStyle(backgroundColor: highlight)
              : null,
        ),
      );
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _VerseEnd(
            number: v.ref.ayah,
            color: markColor,
            marked: marked,
          ),
        ),
      );
      spans.add(const TextSpan(text: ' '));
    }
    flush();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        ...blocks,
        const SizedBox(height: 16),
        Center(
          child: Text(
            arabicDigits('${widget.page}'),
            style: TextStyle(
              fontFamily: quranFont,
              fontSize: 16,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Decorated surah title shown where a surah starts.
class _SurahHeader extends StatelessWidget {
  const _SurahHeader({required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? QandeelColors.gold : QandeelColors.green;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.06),
      ),
      child: Text(
        'سورة ${surah.nameArabic}',
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontFamily: headingArabicFont,
          fontSize: 24,
          color: color,
        ),
      ),
    );
  }
}

/// Verse-end marker: a small ring with the verse number in Arabic-Indic
/// digits. Drawn as a widget so it does not depend on font support for U+06DD.
class _VerseEnd extends StatelessWidget {
  const _VerseEnd({
    required this.number,
    required this.color,
    required this.marked,
  });

  final int number;
  final Color color;
  final bool marked;

  @override
  Widget build(BuildContext context) {
    // No `alignment` here: it would make the marker fill the whole line.
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      padding: const EdgeInsets.fromLTRB(4, 5, 4, 3),
      decoration: BoxDecoration(
        shape: number < 100 ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: number < 100 ? null : BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.2),
        color: marked ? color.withValues(alpha: 0.18) : null,
      ),
      child: Text(
        arabicDigits('$number'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: quranFont,
          fontSize: 13,
          height: 1.2,
          color: color,
        ),
      ),
    );
  }
}
