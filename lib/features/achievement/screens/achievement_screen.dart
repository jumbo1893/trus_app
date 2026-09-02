import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/achievement/controller/achievement_notifier.dart';
import 'package:trus_app/features/achievement/widget/achievement_category_style.dart';
import 'package:trus_app/features/achievement/widget/achievement_list_tile.dart';
import 'package:trus_app/models/api/achievement/achievement_category.dart';
import 'package:trus_app/models/api/achievement/achievement_detail.dart';
import 'package:trus_app/theme/app_colors.dart';

import '../../../common/widgets/screen/custom_consumer_widget.dart';

class AchievementScreen extends CustomConsumerWidget {
  static const String id = "achievement-screen";

  const AchievementScreen({super.key}) : super(title: "Achievementy", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(achievementNotifierProvider);
    final notifier = ref.read(achievementNotifierProvider.notifier);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: state.achievements.when(
          loading: () => const Center(child: Loader()),
          error: (_, __) => const SizedBox.shrink(),
          data: (achievements) {
            if (achievements.isEmpty) {
              return Center(
                child: Text(
                  'Zatím tu nejsou žádné achievementy',
                  style: TextStyle(color: context.appColors.textSecondary),
                ),
              );
            }

            final groupedAchievements = _groupAchievements(achievements);

            return ListView(
              key: const PageStorageKey(id),
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                for (final category in AchievementCategory.values)
                  if (groupedAchievements[category]!.isNotEmpty) ...[
                    _AchievementCategoryHeader(
                      category: category,
                      count: groupedAchievements[category]!.length,
                    ),
                    for (final achievement
                        in groupedAchievements[category]!) ...[
                      AchievementListTile(
                        detail: achievement,
                        onTap: () => notifier.selectListviewItem(achievement),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 10),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }

  Map<AchievementCategory, List<AchievementDetail>> _groupAchievements(
    List<AchievementDetail> achievements,
  ) {
    final result = <AchievementCategory, List<AchievementDetail>>{
      for (final category in AchievementCategory.values) category: [],
    };

    for (final achievement in achievements) {
      result[achievement.achievement.category]!.add(achievement);
    }

    return result;
  }
}

class _AchievementCategoryHeader extends StatelessWidget {
  final AchievementCategory category;
  final int count;

  const _AchievementCategoryHeader({
    required this.category,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final categoryStyle = AchievementCategoryStyle.fromCategory(category);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: categoryStyle.color.withAlpha(
                Theme.of(context).brightness == Brightness.dark ? 48 : 24,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              categoryStyle.icon,
              color: categoryStyle.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              category.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context.appColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '$count',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.appColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
