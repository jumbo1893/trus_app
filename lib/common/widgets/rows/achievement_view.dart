import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/achievement/screens/view_player_achievement_detail_screen.dart';
import 'package:trus_app/features/achievement/widget/achievement_category_style.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/models/api/achievement/achievement_category.dart';
import 'package:trus_app/models/api/achievement/achievement_player_detail.dart';
import 'package:trus_app/models/api/achievement/player_achievement_api_model.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

import '../../../features/achievement/widget/achievement_rarity_style.dart';
import '../../utils/utils.dart';

class AchievementView extends ConsumerWidget {
  final AchievementPlayerDetail? achievementPlayerDetail;

  const AchievementView({Key? key, required this.achievementPlayerDetail})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (achievementPlayerDetail == null) {
      return const SizedBox.shrink();
    }

    final detail = achievementPlayerDetail!;
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    final allAchievements = [
      ...detail.accomplishedPlayerAchievements,
      ...detail.notAccomplishedPlayerAchievements,
    ];

    final groupedAchievements = _groupAchievementsByCategory(allAchievements);

    final title =
        "Splněno ${castDoubleToPercentage(detail.successRate)} % achievementů";
    final subtitle =
        "${detail.accomplishedPlayerAchievements.length}/${detail.totalCount} dokončeno";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppWidgetValues.borderRadiusXl,
        boxShadow: AppWidgetValues.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Achievementy",
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: textTheme.bodyLarge?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 16),
          _AchievementProgressBar(
            progress: detail.totalCount == null || detail.totalCount == 0
                ? 0
                : detail.accomplishedPlayerAchievements.length /
                      detail.totalCount!,
          ),
          const SizedBox(height: 18),

          for (final category in AchievementCategory.values)
            if ((groupedAchievements[category] ?? []).isNotEmpty) ...[
              _AchievementSection(
                category: category,
                achievements: groupedAchievements[category]!,
                onTap: (achievement) {
                  ref
                      .read(screenVariablesNotifierProvider.notifier)
                      .setPlayerAchievement(achievement);

                  ref
                      .read(screenNotifierProvider.notifier)
                      .changeFragment(ViewPlayerAchievementDetailScreen.id);
                },
              ),
              const SizedBox(height: 20),
            ],
        ],
      ),
    );
  }

  Map<AchievementCategory, List<PlayerAchievementApiModel>>
  _groupAchievementsByCategory(List<PlayerAchievementApiModel> achievements) {
    final result = <AchievementCategory, List<PlayerAchievementApiModel>>{
      for (final category in AchievementCategory.values) category: [],
    };

    for (final achievement in achievements) {
      result[achievement.achievement.category]!.add(achievement);
    }

    for (final categoryAchievements in result.values) {
      categoryAchievements.sort(_compareBySuccessRateAndName);
    }

    return result;
  }

  int _compareBySuccessRateAndName(
    PlayerAchievementApiModel first,
    PlayerAchievementApiModel second,
  ) {
    final successRateComparison = second.achievement.teamSuccessRate.compareTo(
      first.achievement.teamSuccessRate,
    );

    if (successRateComparison != 0) {
      return successRateComparison;
    }

    return first.achievement.name.toLowerCase().compareTo(
      second.achievement.name.toLowerCase(),
    );
  }
}

class _AchievementSection extends StatelessWidget {
  final AchievementCategory category;
  final List<PlayerAchievementApiModel> achievements;
  final ValueChanged<PlayerAchievementApiModel> onTap;

  const _AchievementSection({
    required this.category,
    required this.achievements,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final categoryStyle = AchievementCategoryStyle.fromCategory(category);

    final accomplishedCount = achievements
        .where((achievement) => achievement.isAccomplished)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: categoryStyle.color.withAlpha(
                  Theme.of(context).brightness == Brightness.dark ? 48 : 24,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                categoryStyle.icon,
                color: categoryStyle.color,
                size: 17,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category.title,
                style: textTheme.titleSmall?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              "$accomplishedCount/${achievements.length}",
              style: textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: achievements.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            final rarityStyle = AchievementRarityStyle.fromRarity(
              achievement.achievement.rarity,
            );

            return _AchievementTile(
              achievement: achievement,
              accomplished: achievement.isAccomplished,
              style: rarityStyle,
              onTap: () => onTap(achievement),
            );
          },
        ),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final PlayerAchievementApiModel achievement;
  final bool accomplished;
  final AchievementRarityStyle style;
  final VoidCallback onTap;

  const _AchievementTile({
    required this.achievement,
    required this.accomplished,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = accomplished
        ? style.color.withAlpha(isDark ? 55 : 28)
        : colors.backgroundSecondary;

    final iconColor = accomplished ? style.color : colors.textMuted;

    final textColor = accomplished ? colors.textPrimary : colors.textSecondary;

    final borderColor = accomplished
        ? style.color.withAlpha(isDark ? 130 : 90)
        : colors.disabled.withAlpha(50);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.emoji_events_rounded, size: 30, color: iconColor),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    achievement.achievement.name,
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11.5,
                      height: 1.2,
                      color: textColor,
                      fontWeight: accomplished
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
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

class _AchievementProgressBar extends StatelessWidget {
  final double progress;

  const _AchievementProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final safeProgress = progress.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: safeProgress,
        minHeight: 10,
        backgroundColor: colors.backgroundSecondary,
        valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
      ),
    );
  }
}
