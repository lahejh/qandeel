import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
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
            _Header(l10n.sourcesTitle),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(l10n.quranTextSource),
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
