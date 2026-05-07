import 'package:flutter/material.dart';

import '../../models/api/notification/notification_api_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_widget_values.dart';
import '../utils/calendar.dart';

class NotificationListTile extends StatelessWidget {
  final NotificationApiModel notificationModel;
  final VoidCallback? onTap;

  const NotificationListTile({
    super.key,
    required this.notificationModel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    final userInitial = notificationModel.userName.trim().isEmpty
        ? '?'
        : notificationModel.userName.trim().substring(0, 1).toUpperCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppWidgetValues.borderRadiusXl,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: AppWidgetValues.borderRadiusXl,
            boxShadow: AppWidgetValues.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colors.accentSoft,
                  child: Text(
                    userInitial,
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notificationModel.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatDateForFrontend(notificationModel.date),
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notificationModel.userName,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notificationModel.text,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}