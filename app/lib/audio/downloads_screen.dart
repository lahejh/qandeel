import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../quran/quran_scope.dart';
import 'reciters.dart';

/// Saved recitations per reciter, with delete (CLAUDE.md §4 storage screen).
class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  Future<void> _delete(Reciter r) async {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final files = QuranScope.of(context).recitation!.files;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        content: Text(l10n.deleteConfirm(r.name(lang))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(d).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(d).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await files.deleteAll(r);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final files = QuranScope.of(context).recitation!.files;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.downloads)),
      body: ListView(
        children: [
          for (final r in Reciters.all)
            Builder(
              builder: (context) {
                final u = files.usage(r);
                final mb = (u.bytes / (1024 * 1024)).toStringAsFixed(1);
                return ListTile(
                  leading: const Icon(Icons.record_voice_over_outlined),
                  title: Text(r.name(lang)),
                  subtitle: Text(
                    u.files == 0
                        ? l10n.nothingSaved
                        : l10n.savedSize(localNumber(context, u.files), mb),
                    style: TextStyle(color: muted),
                  ),
                  trailing: u.files == 0
                      ? null
                      : IconButton(
                          tooltip: l10n.delete,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(r),
                        ),
                );
              },
            ),
        ],
      ),
    );
  }
}
