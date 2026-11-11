import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../quran/quran_scope.dart';
import '../quran/reader_screen.dart' show surahName;
import '../theme.dart';
import 'recitation_controller.dart';
import 'reciters.dart';

/// Bar at the bottom of the reader while recitation plays: the verse being
/// recited, the reciter and source (credited as CLAUDE.md §4 requires),
/// pause/resume and stop. Also tells the user when a verse cannot be played.
class PlayerBar extends StatefulWidget {
  const PlayerBar({super.key, required this.controller});

  final RecitationController controller;

  @override
  State<PlayerBar> createState() => _PlayerBarState();
}

class _PlayerBarState extends State<PlayerBar> {
  RecitationIssue _shown = RecitationIssue.none;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    final issue = widget.controller.issue;
    if (issue != _shown && issue != RecitationIssue.none) {
      _shown = issue;
      WidgetsBinding.instance.addPostFrameCallback((_) => _report(issue));
    }
    _shown = issue;
    if (mounted) setState(() {});
  }

  Future<void> _report(RecitationIssue issue) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final c = widget.controller;
    final lang = Localizations.localeOf(context).languageCode;
    if (issue == RecitationIssue.connectToDownload) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.connectToDownload)));
      c.clearIssue();
      return;
    }
    // Reciter unavailable: ASK before switching (never automatic).
    final settings = QuranScope.of(context).settings;
    final current = c.reciter;
    final choice = await showDialog<Reciter>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.reciterUnavailable(current.name(lang))),
        actions: [
          for (final r in Reciters.all.where((r) => r.id != current.id))
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(r),
              child: Text(r.name(lang)),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.notNow),
          ),
        ],
      ),
    );
    c.clearIssue();
    if (choice != null) settings.reciterId = choice.id;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final ref = c.current;
    if (!c.isActive || ref == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final quran = QuranScope.of(context).quran;
    final lang = Localizations.localeOf(context).languageCode;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? QandeelColors.gold : QandeelColors.green;

    return Material(
      color: scheme.surfaceContainerLowest,
      elevation: 6,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Icon(Icons.graphic_eq, color: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.verseRef(
                        surahName(context, quran.surah(ref.surah)),
                        localNumber(context, ref.ayah),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      [
                        c.reciter.name(lang),
                        if (c.source != null) c.source!.creditName,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: c.isPaused ? l10n.resume : l10n.pause,
                icon: Icon(
                  c.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                ),
                onPressed: c.isPaused ? c.resume : c.pause,
              ),
              IconButton(
                tooltip: l10n.stopPlayback,
                icon: const Icon(Icons.stop_rounded),
                onPressed: c.stop,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
