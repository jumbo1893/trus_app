import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/common/widgets/filter/app_search_filter_bar.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/achievement/controller/achievement_filter_notifier.dart';
import 'package:trus_app/features/achievement/controller/achievement_filter_options_provider.dart';
import 'package:trus_app/features/achievement/controller/achievement_notifier.dart';
import 'package:trus_app/features/achievement/filter/achievement_filter.dart';
import 'package:trus_app/features/achievement/filter/achievement_filter_options.dart';
import 'package:trus_app/features/achievement/widget/achievement_category_style.dart';
import 'package:trus_app/features/achievement/widget/achievement_filter_sheet.dart';
import 'package:trus_app/features/achievement/widget/achievement_list_tile.dart';
import 'package:trus_app/models/api/achievement/achievement_category.dart';
import 'package:trus_app/models/api/achievement/achievement_detail.dart';
import 'package:trus_app/theme/app_colors.dart';

class AchievementScreen extends CustomConsumerStatefulWidget {
  static const String id = "achievement-screen";

  const AchievementScreen({super.key}) : super(title: "Achievementy", name: id);

  @override
  ConsumerState<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends ConsumerState<AchievementScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(achievementNotifierProvider);
    final notifier = ref.read(achievementNotifierProvider.notifier);
    final filter = ref.watch(
      achievementFilterNotifierProvider.select((state) => state.listFilter),
    );
    final filterNotifier = ref.read(achievementFilterNotifierProvider.notifier);

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

            final filteredAchievements = achievements
                .where(
                  (detail) => filter.matches(
                    detail.achievement,
                    accomplishedPlayerIds: detail.accomplishedPlayerIds,
                    successRate: detail.successRate,
                  ),
                )
                .toList();
            final groupedAchievements = _groupAchievements(
              filteredAchievements,
            );
            final options = ref
                .watch(achievementFilterOptionsProvider)
                .maybeWhen(
                  data: (value) => value,
                  orElse: () => const AchievementFilterOptions.empty(),
                );

            return ListView(
              key: const PageStorageKey(AchievementScreen.id),
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                  child: AppSearchFilterBar(
                    query: filter.query,
                    searchHint: 'Hledat podle názvu nebo podmínky',
                    activeFilterCount: filter.activeAdvancedFilterCount,
                    onQueryChanged: (query) => filterNotifier.setListFilter(
                      filter.copyWith(query: query),
                    ),
                    onFilterPressed: () => _openFilters(options, filter),
                    onClear: filterNotifier.clearListFilter,
                  ),
                ),
                if (filteredAchievements.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 42,
                    ),
                    child: Text(
                      'Žádné achievementy neodpovídají zvoleným filtrům.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.appColors.textSecondary),
                    ),
                  ),
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

  Future<void> _openFilters(
    AchievementFilterOptions options,
    AchievementFilter filter,
  ) async {
    final selected = await showAchievementFilterSheet(
      context,
      filter: filter,
      options: options,
      showPlayerFilter: true,
    );
    if (selected != null && mounted) {
      ref
          .read(achievementFilterNotifierProvider.notifier)
          .setListFilter(selected);
    }
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
