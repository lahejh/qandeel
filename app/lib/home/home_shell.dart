import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../quran/quran_index_screen.dart';
import '../quran/search_screen.dart';
import '../settings/app_settings.dart';
import '../settings/settings_screen.dart';
import 'home_screen.dart';
import 'section_placeholder.dart';

/// Main screen with five tabs: Home, Quran, Azkar, Memorize, Kids.
///
/// Icons are objects only (no faces, people or animals) — see CLAUDE.md.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.settings, this.now});

  final AppSettings settings;

  /// For tests; defaults to the current time.
  final DateTime? now;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _openTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final tabs = [
      (l10n.tabHome, Icons.home_outlined, Icons.home),
      (l10n.tabQuran, Icons.menu_book_outlined, Icons.menu_book),
      (l10n.tabAzkar, Icons.light_mode_outlined, Icons.light_mode),
      (l10n.tabMemorize, Icons.repeat, Icons.repeat_on),
      (l10n.tabKids, Icons.mosque_outlined, Icons.mosque),
    ];
    final placeholders = {
      2: l10n.azkarPlaceholder,
      3: l10n.memorizePlaceholder,
      4: l10n.kidsPlaceholder,
    };

    final Widget body = _index == 0
        ? HomeScreen(onOpenTab: _openTab, now: widget.now)
        : _index == 1
        ? const QuranIndexScreen()
        : SectionPlaceholder(
            key: ValueKey(_index),
            icon: tabs[_index].$3,
            title: tabs[_index].$1,
            description: placeholders[_index]!,
          );

    return Scaffold(
      appBar: AppBar(
        title: _index == 0 ? null : Text(tabs[_index].$1),
        actions: [
          if (_index == 1)
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: l10n.search,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SettingsScreen(settings: widget.settings),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(top: false, child: body),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _openTab,
        destinations: [
          for (final t in tabs)
            NavigationDestination(
              icon: Icon(t.$2),
              selectedIcon: Icon(t.$3),
              label: t.$1,
            ),
        ],
      ),
    );
  }
}
