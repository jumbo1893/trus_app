import 'package:flutter/material.dart';
import 'package:trus_app/common/widgets/filter/app_filter_bottom_sheet.dart';
import 'package:trus_app/common/widgets/filter/app_filter_multi_selection_field.dart';
import 'package:trus_app/features/achievement/filter/achievement_filter.dart';
import 'package:trus_app/features/achievement/filter/achievement_filter_options.dart';
import 'package:trus_app/models/api/achievement/achievement_category.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
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

class _AchievementFilterFields extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final selectedPlayers = _selectedPlayers(
      options.players,
      filter.accomplishedPlayerIds,
    );
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
          AppFilterMultiSelectionField<PlayerApiModel>(
            label: 'Splnil hráč nebo fanoušek',
            hint: options.players.isEmpty
                ? 'Hráče se nepodařilo načíst'
                : 'Všichni hráči a fanoušci',
            searchHint: 'Hledat hráče nebo fanouška',
            values: selectedPlayers,
            items: options.players,
            itemLabel: (player) =>
                '${player.name} · ${player.fan ? 'fanoušek' : 'hráč'}',
            onChanged: (players) => onChanged(
              filter.copyWith(
                accomplishedPlayerIds: players
                    .where((player) => player.id != null)
                    .map<int>((player) => player.id!)
                    .toSet(),
              ),
            ),
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

  Set<PlayerApiModel> _selectedPlayers(
    List<PlayerApiModel> players,
    Set<int> ids,
  ) => players.where((player) => ids.contains(player.id)).toSet();
}
