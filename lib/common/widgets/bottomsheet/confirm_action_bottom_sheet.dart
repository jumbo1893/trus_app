import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

class ConfirmActionBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Future<void> Function()? onConfirm;
  final IconData? icon;
  final bool isDanger;

  const ConfirmActionBottomSheet({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText = 'Potvrdit',
    this.cancelText = 'Zrušit',
    this.icon,
    this.isDanger = false,
  });

  static Future<void> show(
      BuildContext context, {
        required String title,
        required String message,
        required Future<void> Function()? onConfirm,
        String confirmText = 'Potvrdit',
        String cancelText = 'Zrušit',
        IconData? icon,
        bool isDanger = false,
      }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmActionBottomSheet(
        title: title,
        message: message,
        onConfirm: onConfirm,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        isDanger: isDanger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final confirmBackgroundColor =
    isDanger ? colors.errorForeground : colors.accent;

    final confirmForegroundColor =
    isDanger ? Colors.white : theme.colorScheme.onPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppWidgetValues.cardShadow,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: colors.textMuted.withAlpha(60),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                if (icon != null) ...[
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDanger
                          ? colors.errorBackground
                          : colors.accentSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isDanger
                          ? colors.errorForeground
                          : colors.accent,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(cancelText),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await onConfirm?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmBackgroundColor,
                          foregroundColor: confirmForegroundColor,
                        ),
                        child: Text(confirmText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}