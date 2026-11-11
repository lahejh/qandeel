import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'quran.dart';
import 'quran_scope.dart';
import 'reader_screen.dart';

/// Opens the mushaf reader at [page].
Future<void> openReader(BuildContext context, int page) => Navigator.of(context)
    .push(
      MaterialPageRoute<void>(builder: (_) => ReaderScreen(initialPage: page)),
    );

/// Quran tab: lists of surahs, juz and bookmarks. Each item opens the reader
/// at the right mushaf page.
class QuranIndexScreen extends StatelessWidget {
  const QuranIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: l10n.surahsTab),
              Tab(text: l10n.juzTab),
              Tab(text: l10n.bookmarksTab),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [_SurahList(), _JuzList(), _BookmarkList()],
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahList extends StatelessWidget {
  const _SurahList();

  @override
  Widget build(BuildContext context) {
    final quran = QuranScope.of(context).quran;
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return ListView.builder(
      itemCount: quran.surahs.length,
      itemBuilder: (context, i) {
        final s = quran.surahs[i];
        final page = quran.pageOf(VerseRef(s.number, 1));
        final details = [
          if (!isArabic) s.nameEnglish,
          l10n.verseCount(localNumber(context, s.verseCount)),
          s.isMeccan ? l10n.meccan : l10n.medinan,
        ].join(' · ');
        return ListTile(
          leading: _NumberBadge(number: s.number),
          title: Text(l10n.surahTitle(surahName(context, s))),
          subtitle: Text(details, style: TextStyle(color: muted)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isArabic)
                Text(
                  s.nameArabic,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: headingArabicFont,
                    fontSize: 20,
                  ),
                ),
              Text(
                localNumber(context, page),
                style: TextStyle(fontSize: 12, color: muted),
              ),
            ],
          ),
          onTap: () => openReader(context, page),
        );
      },
    );
  }
}

class _JuzList extends StatelessWidget {
  const _JuzList();

  @override
  Widget build(BuildContext context) {
    final quran = QuranScope.of(context).quran;
    final l10n = AppLocalizations.of(context);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return ListView.builder(
      itemCount: Quran.juzCount,
      itemBuilder: (context, i) {
        final start = quran.juzStarts[i];
        final page = quran.pageOf(start);
        final place = l10n.verseRef(
          surahName(context, quran.surah(start.surah)),
          localNumber(context, start.ayah),
        );
        return ListTile(
          leading: _NumberBadge(number: i + 1),
          title: Text(l10n.juzTitle(localNumber(context, i + 1))),
          subtitle: Text(l10n.startsAt(place), style: TextStyle(color: muted)),
          trailing: Text(
            l10n.pageNumber(localNumber(context, page)),
            style: TextStyle(fontSize: 12, color: muted),
          ),
          onTap: () => openReader(context, page),
        );
      },
    );
  }
}

class _BookmarkList extends StatelessWidget {
  const _BookmarkList();

  @override
  Widget build(BuildContext context) {
    final scope = QuranScope.of(context);
    final l10n = AppLocalizations.of(context);
    final bookmarks = scope.reading.bookmarks;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    if (bookmarks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.noBookmarks,
            textAlign: TextAlign.center,
            style: TextStyle(color: muted),
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: bookmarks.length,
      itemBuilder: (context, i) {
        final ref = bookmarks[i];
        final page = scope.quran.pageOf(ref);
        return ListTile(
          leading: const Icon(Icons.bookmark),
          title: Text(
            l10n.verseRef(
              surahName(context, scope.quran.surah(ref.surah)),
              localNumber(context, ref.ayah),
            ),
          ),
          subtitle: Text(
            l10n.pageNumber(localNumber(context, page)),
            style: TextStyle(color: muted),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.bookmark_remove_outlined),
            tooltip: l10n.removeBookmark,
            onPressed: () => scope.reading.toggleBookmark(ref),
          ),
          onTap: () => openReader(context, page),
        );
      },
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? QandeelColors.gold : QandeelColors.green;
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        color: color.withValues(alpha: 0.08),
      ),
      child: Text(
        localNumber(context, number),
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
