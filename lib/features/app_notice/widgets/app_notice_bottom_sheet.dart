import 'package:flutter/material.dart';
import 'package:trus_app/models/api/app_notice/app_notice.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

class AppNoticeBottomSheet extends StatelessWidget {
  final AppNotice notice;
  final Future<void> Function(AppNoticeAction action) onAction;

  const AppNoticeBottomSheet({
    super.key,
    required this.notice,
    required this.onAction,
  });

  static Future<void> show(
    BuildContext context, {
    required AppNotice notice,
    required Future<void> Function(AppNoticeAction action) onAction,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: notice.dismissible,
      enableDrag: notice.dismissible,
      backgroundColor: Colors.transparent,
      builder: (_) => PopScope(
        canPop: notice.dismissible,
        child: AppNoticeBottomSheet(notice: notice, onAction: onAction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final actions = notice.actions.isEmpty && !notice.dismissible
        ? const [
            AppNoticeAction(
              id: -1,
              label: 'Zavřít',
              type: AppNoticeActionType.close,
              style: AppNoticeActionStyle.primary,
            ),
          ]
        : notice.actions;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        12,
        12,
        12 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppWidgetValues.cardShadow,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (notice.dismissible)
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
                  Icons.new_releases_outlined,
                  size: 38,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  notice.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  notice.message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  for (var index = 0; index < actions.length; index++) ...[
                    _ActionButton(action: actions[index], onAction: onAction),
                    if (index < actions.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final AppNoticeAction action;
  final Future<void> Function(AppNoticeAction action) onAction;

  const _ActionButton({required this.action, required this.onAction});

  @override
  Widget build(BuildContext context) {
    Future<void> onPressed() async {
      Navigator.of(context).pop();
      await onAction(action);
    }

    return action.style == AppNoticeActionStyle.secondary
        ? OutlinedButton(onPressed: onPressed, child: Text(action.label))
        : FilledButton(onPressed: onPressed, child: Text(action.label));
  }
}
