import 'package:flutter/material.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/features/achievement/widget/achievement_rarity_style.dart';
import 'package:trus_app/models/api/achievement/achievement_detail.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

import '../../../models/api/achievement/achievement_rarity.dart';

class AchievementListTile extends StatelessWidget {
  final AchievementDetail detail;
  final VoidCallback? onTap;

  const AchievementListTile({
    super.key,
    required this.detail,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = castDoubleToPercentage(detail.successRate);

    final badgeStyle = AchievementRarityStyle.forListTile(
      rarity: detail.achievement.rarity,
      successPercentage: percentage,
    );

    final rarityStyle = AchievementRarityStyle.fromRarity(
      detail.achievement.rarity,
    );

    final accomplishedCount = detail.accomplishedCount ?? 0;
    final totalCount = detail.totalCount ?? 0;

    return Material(
      color: context.appColors.cardBackground,
      borderRadius: AppWidgetValues.borderRadiusXl,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppWidgetValues.borderRadiusXl,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            borderRadius: AppWidgetValues.borderRadiusXl,
            boxShadow: AppWidgetValues.cardShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AchievementBadge(
                percentage: percentage,
                color: badgeStyle.color,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _AchievementContent(
                  detail: detail,
                  accomplishedCount: accomplishedCount,
                  totalCount: totalCount,
                  rarityColor: rarityStyle.color,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: context.appColors.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final int percentage;
  final Color color;

  const _AchievementBadge({
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 64,
      height: 74,
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 48 : 24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withAlpha(isDark ? 150 : 95),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_rounded,
            size: 21,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            '$percentage%',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementContent extends StatelessWidget {
  final AchievementDetail detail;
  final int accomplishedCount;
  final int totalCount;
  final Color rarityColor;

  const _AchievementContent({
    required this.detail,
    required this.accomplishedCount,
    required this.totalCount,
    required this.rarityColor,
  });

  @override
  Widget build(BuildContext context) {
    final achievement = detail.achievement;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          achievement.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.appColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          achievement.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.appColors.textSecondary,
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _RarityChip(
              label: achievement.rarity.title.toUpperCase(),
              color: rarityColor,
            ),
            const SizedBox(width: 9),
            Icon(
              Icons.people_alt_outlined,
              size: 14,
              color: context.appColors.textMuted,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '$accomplishedCount / $totalCount hráčů',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.appColors.textMuted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RarityChip extends StatelessWidget {
  final String label;
  final Color color;

  const _RarityChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 48 : 22),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.35,
        ),
      ),
    );
  }
}