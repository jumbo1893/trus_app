import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/screen/custom_consumer_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_widget_values.dart';
import '../controller/appearance_notifier.dart';

class AppearanceScreen extends CustomConsumerWidget {
  static const String id = 'appearance-screen';

  const AppearanceScreen({super.key})
      : super(title: 'Vzhled', name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(appearanceNotifierProvider);
    final notifier = ref.read(appearanceNotifierProvider.notifier);
    final colors = context.appColors;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Container(
            padding: AppWidgetValues.cardPadding,
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: AppWidgetValues.borderRadiusLg,
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  color: colors.shadow.withValues(alpha: 0.10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Barevný režim', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 6),
                Text(
                  'Automatický režim respektuje nastavení telefonu.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 18),
                _ThemeModeOption(
                  icon: Icons.settings_suggest_outlined,
                  title: 'Automatický',
                  subtitle: 'Podle nastavení zařízení',
                  value: ThemeMode.system,
                  selectedMode: selectedMode,
                  onChanged: notifier.setThemeMode,
                ),
                _ThemeModeOption(
                  icon: Icons.light_mode_outlined,
                  title: 'Světlý',
                  subtitle: 'Vždy světlý vzhled',
                  value: ThemeMode.light,
                  selectedMode: selectedMode,
                  onChanged: notifier.setThemeMode,
                ),
                _ThemeModeOption(
                  icon: Icons.dark_mode_outlined,
                  title: 'Tmavý',
                  subtitle: 'Vždy tmavý vzhled',
                  value: ThemeMode.dark,
                  selectedMode: selectedMode,
                  onChanged: notifier.setThemeMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeMode value;
  final ThemeMode selectedMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selectedMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final selected = selectedMode == value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? colors.accentSoft : colors.backgroundSecondary,
        borderRadius: AppWidgetValues.borderRadiusMd,
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: AppWidgetValues.borderRadiusMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: RadioListTile<ThemeMode>(
              value: value,
              groupValue: selectedMode,
              onChanged: (mode) {
                if (mode != null) onChanged(mode);
              },
              activeColor: colors.accent,
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                icon,
                color: selected ? colors.accent : colors.textSecondary,
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                subtitle,
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
