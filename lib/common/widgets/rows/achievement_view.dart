import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/achievement/screens/view_player_achievement_detail_screen.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/models/api/achievement/achievement_player_detail.dart';
import 'package:trus_app/models/api/achievement/player_achievement_api_model.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

import '../../utils/utils.dart';

class AchievementView extends ConsumerWidget {
  final AchievementPlayerDetail? achievementPlayerDetail;

  const AchievementView({
    Key? key,
    required this.achievementPlayerDetail,
  }) : super(key: key);

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
            style: textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _AchievementProgressBar(
            progress: detail.totalCount == null || detail.totalCount == 0
                ? 0
                : detail.accomplishedPlayerAchievements.length /
                detail.totalCount!,
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allAchievements.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final achievement = allAchievements[index];
              final accomplished = achievement.accomplished == true;

              return _AchievementTile(
                achievement: achievement,
                accomplished: accomplished,
                onTap: () {
                  ref
                      .read(screenVariablesNotifierProvider.notifier)
                      .setPlayerAchievement(achievement);
                  ref
                      .read(screenNotifierProvider.notifier)
                      .changeFragment(ViewPlayerAchievementDetailScreen.id);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AchievementProgressBar extends StatelessWidget {
  final double progress;

  const _AchievementProgressBar({
    required this.progress,
  });

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

class _AchievementTile extends StatelessWidget {
  final PlayerAchievementApiModel achievement;
  final bool accomplished;
  final VoidCallback onTap;

  const _AchievementTile({
    required this.achievement,
    required this.accomplished,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    final backgroundColor = accomplished
        ? colors.accentSoft
        : colors.backgroundSecondary;

    final iconColor =
    accomplished ? colors.accent : colors.textMuted;

    final textColor =
    accomplished ? colors.textPrimary : colors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accomplished
                  ? colors.accent.withAlpha(70)
                  : colors.disabled.withAlpha(50),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  size: 30,
                  color: iconColor,
                ),
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
                      fontWeight: accomplished ? FontWeight.w600 : FontWeight.w500,
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