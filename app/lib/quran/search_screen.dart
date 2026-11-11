import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'quran.dart';
import 'quran_index_screen.dart';
import 'quran_scope.dart';
import 'reader_screen.dart';

/// Search: surah names (Arabic, English, transliterated or number), verse
/// references like "2:255", and Arabic words without diacritics.
/// Everything is searched on the phone; nothing is sent anywhere.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  /// Most verses listed at once; the total is always shown.
  static const maxVerseResults = 200;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scope = QuranScope.of(context);
    final search = scope.search;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    final ref = search.parseReference(_query);
    final surahs = search.searchSurahs(_query);
    final verses = search.searchVerses(_query);
    final shown = verses.take(SearchScreen.maxVerseResults).toList();

    final results = <Widget>[
      if (ref != null)
        ListTile(
          leading: const Icon(Icons.arrow_forward),
          title: Text(
            l10n.verseRef(
              surahName(context, scope.quran.surah(ref.surah)),
              localNumber(context, ref.ayah),
            ),
          ),
          onTap: () =>
              openReader(context, scope.quran.pageOf(ref), highlight: ref),
        ),
      if (surahs.isNotEmpty) _SectionHeader(l10n.surahsTab),
      for (final s in surahs)
        ListTile(
          leading: const Icon(Icons.menu_book_outlined),
          title: Text(l10n.surahTitle(surahName(context, s))),
          subtitle: Text(
            l10n.verseCount(localNumber(context, s.verseCount)),
            style: TextStyle(color: muted),
          ),
          onTap: () =>
              openReader(context, scope.quran.pageOf(VerseRef(s.number, 1))),
        ),
      if (verses.isNotEmpty)
        _SectionHeader(l10n.verseResults(localNumber(context, verses.length))),
      for (final v in shown) _VerseResult(verse: v),
      if (verses.length > shown.length)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.moreResults(localNumber(context, shown.length)),
            textAlign: TextAlign.center,
            style: TextStyle(color: muted),
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
          ),
          onChanged: (q) => setState(() => _query = q),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.clearSearch,
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.trim().isEmpty
          ? _Message(l10n.searchHelp)
          : results.isEmpty
          ? _Message(l10n.noResults)
          : ListView(children: results),
    );
  }
}

class _VerseResult extends StatelessWidget {
  const _VerseResult({required this.verse});

  final Verse verse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final quran = QuranScope.of(context).quran;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return ListTile(
      title: Text(
        // Uthmani text exactly as stored (without the basmala header).
        verse.displayText,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: quranFont,
          fontSize: 20,
          height: 1.9,
        ),
      ),
      subtitle: Text(
        l10n.verseRef(
          surahName(context, quran.surah(verse.ref.surah)),
          localNumber(context, verse.ref.ayah),
        ),
        style: TextStyle(color: muted),
      ),
      onTap: () =>
          openReader(context, quran.pageOf(verse.ref), highlight: verse.ref),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ),
  );
}
