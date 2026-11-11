import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';

/// Home dashboard: what you need right now.
///
/// - Top card: where you are in the Quran (day or night artwork by theme).
/// - Azkar card: morning or evening depending on the time.
/// - Memorize and Kids shortcuts.
///
/// Reading progress is not stored yet, so the top card starts at Al-Fatiha.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenTab, this.now});

  /// Switches the bottom tab (1 = Quran, 2 = Azkar, 3 = Memorize, 4 = Kids).
  final ValueChanged<int> onOpenTab;

  /// For tests; defaults to the current time.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final hour = (now ?? DateTime.now()).hour;
    final greeting = hour < 12
        ? l10n.greetingMorning
        : hour < 16
        ? l10n.greetingDay
        : l10n.greetingEvening;
    final isEveningAzkar = hour >= 15 || hour < 4;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          l10n.salam,
          style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          greeting,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _ReadingCard(onStart: () => onOpenTab(1)),
        const SizedBox(height: 16),
        _RowCard(
          icon: isEveningAzkar
              ? Icons.nightlight_outlined
              : Icons.light_mode_outlined,
          title: isEveningAzkar ? l10n.eveningAzkar : l10n.morningAzkar,
          subtitle: l10n.azkarCardSubtitle,
          onTap: () => onOpenTab(2),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SmallCard(
                icon: Icons.repeat,
                title: l10n.tabMemorize,
                subtitle: l10n.memorizeCardSubtitle,
                onTap: () => onOpenTab(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SmallCard(
                icon: Icons.mosque_outlined,
                title: l10n.tabKids,
                subtitle: l10n.kidsCardSubtitle,
                onTap: () => onOpenTab(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 14, color: scheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                l10n.aboutPromise,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Large card with artwork. The artwork's calm side is on the left, so it is
/// mirrored in right-to-left languages to keep text on the calm side.
class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final textColor = isDark ? Colors.white : QandeelColors.dayText;
    final mutedColor = isDark
        ? const Color(0xFFCFE3DD)
        : const Color(0xFF3E4B47);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 214),
        child: Stack(
          children: [
            Positioned.fill(
              child: Transform.flip(
                flipX: isRtl,
                child: Image.asset(
                  isDark
                      ? 'assets/images/home_night.jpg'
                      : 'assets/images/home_day.jpg',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.2, 0),
                  excludeFromSemantics: true,
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(
                width: 200,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.startReading,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: mutedColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'سورة الفاتحة',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: headingArabicFont,
                          fontSize: 28,
                          height: 1.25,
                          color: textColor,
                        ),
                      ),
                      Text(
                        l10n.startReadingPlace,
                        style: TextStyle(fontSize: 14, color: mutedColor),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: onStart,
                        style: FilledButton.styleFrom(
                          backgroundColor: isDark
                              ? QandeelColors.gold
                              : QandeelColors.green,
                          foregroundColor: isDark
                              ? QandeelColors.onGold
                              : Colors.white,
                          minimumSize: const Size(0, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          textStyle: const TextStyle(
                            fontFamily: uiFont,
                            fontFamilyFallback: uiFontFallback,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: Text(l10n.start),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _CardShell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A17) : const Color(0xFFFBF1DC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: isDark ? QandeelColors.gold : const Color(0xFF9A6413),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: scheme.onSurfaceVariant,
            textDirection: Directionality.of(context),
          ),
        ],
      ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  const _SmallCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _CardShell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 84),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 26, color: scheme.primary),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}
