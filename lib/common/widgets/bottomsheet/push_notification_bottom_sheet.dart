import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

class PushNotificationBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String navigateText;
  final VoidCallback onOk;
  final VoidCallback onGo;

  const PushNotificationBottomSheet({
    super.key,
    required this.title,
    required this.message,
    required this.navigateText,
    required this.onOk,
    required this.onGo,
  });

  static Future<void> show(
      BuildContext context, {
        required String title,
        required String message,
        required String navigateText,
        required VoidCallback onOk,
        required VoidCallback onGo,
      }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PushNotificationBottomSheet(
        title: title,
        message: message,
        navigateText: navigateText,
        onOk: onOk,
        onGo: onGo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: colors.textMuted.withAlpha(60),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Icon(
                  Icons.notifications_active_outlined,
                  size: 34,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: onGo,
                  child: Text(
                    navigateText,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: onOk,
                  child: const Text("OK"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
