import 'package:flutter/material.dart';

import '../audio/downloads_screen.dart';
import '../audio/reciters.dart';
import '../l10n/app_localizations.dart';
import '../quran/quran_scope.dart';
import 'app_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.settings)),
        body: ListView(
          children: [
            _Header(l10n.language),
            RadioGroup<String>(
              groupValue: settings.locale?.languageCode ?? 'system',
              onChanged: (code) => settings.locale =
                  (code == null || code == 'system') ? null : Locale(code),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'system',
                    title: Text(l10n.languageSystem),
                  ),
                  // Language names are shown in their own language on purpose.
                  const RadioListTile<String>(
                    value: 'en',
                    title: Text('English'),
                  ),
                  const RadioListTile<String>(
                    value: 'ar',
                    title: Text('العربية'),
                  ),
                ],
              ),
            ),
            const Divider(),
            _Header(l10n.theme),
            RadioGroup<ThemeMode>(
              groupValue: settings.themeMode,
              onChanged: (mode) =>
                  settings.themeMode = mode ?? ThemeMode.system,
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    title: Text(l10n.themeSystem),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    title: Text(l10n.themeLight),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    title: Text(l10n.themeDark),
                  ),
                ],
              ),
            ),
            const Divider(),
            _Header(l10n.recitation),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
              child: Text(l10n.reciter, style: theme.textTheme.bodySmall),
            ),
            RadioGroup<String>(
              groupValue: Reciters.byId(settings.reciterId).id,
              onChanged: (id) => settings.reciterId = id,
              child: Column(
                children: [
                  for (final r in Reciters.all)
                    RadioListTile<String>(
                      value: r.id,
                      title: Text(
                        r.name(Localizations.localeOf(context).languageCode),
                      ),
                    ),
                ],
              ),
            ),
            SwitchListTile(
              value: settings.saveRecitations,
              onChanged: (v) => settings.saveRecitations = v,
              title: Text(l10n.saveRecitations),
              subtitle: Text(l10n.saveRecitationsHint),
            ),
            SwitchListTile(
              value: settings.wifiOnly,
              // Only meaningful while saving is on.
              onChanged: settings.saveRecitations
                  ? (v) => settings.wifiOnly = v
                  : null,
              title: Text(l10n.wifiOnly),
              subtitle: Text(l10n.wifiOnlyHint),
            ),
            if (QuranScope.of(context).recitation != null)
              ListTile(
                leading: const Icon(Icons.download_done_outlined),
                title: Text(l10n.downloads),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DownloadsScreen(),
                  ),
                ),
              ),
            const Divider(),
            _Header(l10n.sourcesTitle),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(l10n.quranTextSource),
            ),
            ListTile(
              leading: const Icon(Icons.graphic_eq),
              title: Text(l10n.recitationSource),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.aboutPromise,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
