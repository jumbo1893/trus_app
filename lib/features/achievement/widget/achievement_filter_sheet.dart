import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/achievement_filter_options_provider.dart';
import 'package:flutter/material.dart';
import 'package:trus_app/common/widgets/filter/app_filter_bottom_sheet.dart';
import 'package:trus_app/common/widgets/filter/app_filter_multi_selection_field.dart';
import 'package:trus_app/features/achievement/filter/achievement_filter.dart';
import 'package:trus_app/features/achievement/filter/achievement_filter_options.dart';
import 'package:trus_app/models/api/achievement/achievement_category.dart';
import 'package:trus_app/theme/app_colors.dart';

Future<AchievementFilter?> showAchievementFilterSheet(
  BuildContext context, {
  required AchievementFilter filter,
  required AchievementFilterOptions options,
  required bool showPlayerFilter,
}) {
  return AppFilterBottomSheet.show<AchievementFilter>(
    context,
    title: 'Filtrovat achievementy',
    initialValue: filter,
    resetValue: AchievementFilter(query: filter.query),
    builder: (context, draft, onChanged) => _AchievementFilterFields(
      filter: draft,
      options: options,
      showPlayerFilter: showPlayerFilter,
      onChanged: onChanged,
    ),
  );
}

class _AchievementFilterFields extends ConsumerWidget {
  final AchievementFilter filter;
  final AchievementFilterOptions options;
  final bool showPlayerFilter;
  final ValueChanged<AchievementFilter> onChanged;

  const _AchievementFilterFields({
    required this.filter,
    required this.options,
    required this.showPlayerFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var players = options.players;
    final minimumPercent = (filter.minimumSuccessRate * 100).round();
    final maximumPercent = (filter.maximumSuccessRate * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFilterMultiSelectionField<AchievementCategory>(
          label: 'Kategorie',
          hint: 'Všechny kategorie',
          searchHint: 'Hledat kategorii',
          values: filter.categories,
          items: AchievementCategory.values,
          itemLabel: (category) => category.title,
          onChanged: (categories) =>
              onChanged(filter.copyWith(categories: categories)),
        ),
        if (showPlayerFilter) ...[
          const SizedBox(height: 20),
          AppFilterMultiSelectionField<int>(
            label: 'Splnil hráč nebo fanoušek',
            hint: 'Všichni hráči a fanoušci',
            searchHint: 'Hledat hráče nebo fanouška',
            values: filter.accomplishedPlayerIds,
            items: players.map((p) => p.id).whereType<int>().toList(),
            loadItems: () async {
              if (players.isEmpty) {
                ref.invalidate(achievementFilterOptionsProvider);
                players = (await ref.read(
                  achievementFilterOptionsProvider.future,
                )).players;
              }
              return players.map((p) => p.id).whereType<int>().toList();
            },
            itemLabel: (id) =>
                players.where((p) => p.id == id).firstOrNull?.name ??
                ref.read(achievementPlayerLabelsProvider)[id] ??
                'Hráč $id',
            onChanged: (ids) =>
                onChanged(filter.copyWith(accomplishedPlayerIds: ids)),
          ),
        ],
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                'Úspěšnost achievementu',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.appColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$minimumPercent–$maximumPercent %',
              style: TextStyle(
                color: context.appColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(
            filter.minimumSuccessRate,
            filter.maximumSuccessRate,
          ),
          min: 0,
          max: 1,
          divisions: 100,
          labels: RangeLabels('$minimumPercent %', '$maximumPercent %'),
          onChanged: (values) => onChanged(
            filter.copyWith(
              minimumSuccessRate: values.start,
              maximumSuccessRate: values.end,
            ),
          ),
        ),
      ],
    );
  }
}
