import '../filter/statistics_filter_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/filter/app_search_filter_bar.dart';
import '../controller/stats_notifier.dart';
import '../stat_args.dart';
import 'statistics_filter_sheet.dart';

class StatisticsFilterBar extends ConsumerWidget {
  final StatsArgs statsArgs;
  const StatisticsFilterBar({super.key, required this.statsArgs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statsNotifierProvider(statsArgs));
    final notifier = ref.read(statsNotifierProvider(statsArgs).notifier);
    final filter = state.advancedFilter;
    final seasons = ref.watch(statisticsSeasonsProvider).asData?.value;
    Widget chip(String label, VoidCallback remove) => InputChip(
      label: Text(label),
      onDeleted: remove,
      deleteButtonTooltipMessage: 'Zrušit: $label',
    );
    return AppSearchFilterBar(
      query: state.filter ?? '',
      searchHint: statsArgs.matchOrPlayer
          ? 'Hledat zápas / soupeře'
          : 'Hledat hráče nebo fanouška',
      onQueryChanged: notifier.search,
      onClear: notifier.clearFilter,
      activeFilterCount: filter.activeCount,
      activeFilters: [
        for (final id in filter.seasonIds)
          chip(
            seasons?.where((s) => s.id == id).firstOrNull?.name ?? 'Sezona $id',
            () => notifier.applyFilters(
              filter.copyWith(seasonIds: {...filter.seasonIds}..remove(id)),
            ),
          ),
        for (final opponent in filter.opponentNames)
          chip(
            opponent,
            () => notifier.applyFilters(
              filter.copyWith(
                opponentNames: {...filter.opponentNames}..remove(opponent),
              ),
            ),
          ),
        if (filter.playerIds.isNotEmpty)
          chip(
            'Hráči: ${filter.playerIds.length}',
            () => notifier.applyFilters(filter.copyWith(playerIds: {})),
          ),
        if (filter.fineIds.isNotEmpty)
          chip(
            'Pokuty: ${filter.fineIds.length}',
            () => notifier.applyFilters(filter.copyWith(fineIds: {})),
          ),
      ],
      onFilterPressed: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        final filter = await showStatisticsFilterSheet(
          context,
          args: statsArgs,
          filter: state.advancedFilter,
        );
        if (context.mounted && filter != null) notifier.applyFilters(filter);
      },
    );
  }
}
