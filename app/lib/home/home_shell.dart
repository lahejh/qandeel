import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../settings/app_settings.dart';
import '../settings/settings_screen.dart';
import 'section_placeholder.dart';

/// Main screen with the four sections: Quran, Azkar, Memorize, Kids.
///
/// Icons are objects only (no faces, people or animals) — see CLAUDE.md.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final sections = [
      (
        l10n.tabQuran,
        Icons.menu_book_outlined,
        Icons.menu_book,
        l10n.quranPlaceholder,
      ),
      (
        l10n.tabAzkar,
        Icons.light_mode_outlined,
        Icons.light_mode,
        l10n.azkarPlaceholder,
      ),
      (
        l10n.tabMemorize,
        Icons.repeat,
        Icons.repeat_on,
        l10n.memorizePlaceholder,
      ),
      (
        l10n.tabKids,
        Icons.extension_outlined,
        Icons.extension,
        l10n.kidsPlaceholder,
      ),
    ];
    final current = sections[_index];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SettingsScreen(settings: widget.settings),
              ),
            ),
          ),
        ],
      ),
      body: SectionPlaceholder(
        key: ValueKey(_index),
        icon: current.$3,
        title: current.$1,
        description: current.$4,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final s in sections)
            NavigationDestination(
              icon: Icon(s.$2),
              selectedIcon: Icon(s.$3),
              label: s.$1,
            ),
        ],
      ),
    );
  }
}
