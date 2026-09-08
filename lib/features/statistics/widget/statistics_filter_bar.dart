import '../filter/statistics_filter_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/filter/app_search_filter_bar.dart';
import '../controller/stats_notifier.dart';
import '../stat_args.dart';
import 'statistics_filter_sheet.dart';

class StatisticsFilterBar extends ConsumerWidget {
  final bool compact;
  final StatsArgs statsArgs;
  const StatisticsFilterBar({
    super.key,
    required this.statsArgs,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statsNotifierProvider(statsArgs));
    final notifier = ref.read(statsNotifierProvider(statsArgs).notifier);
    final filter = state.advancedFilter;
    final seasons = ref.watch(statisticsSeasonsProvider).asData?.value;
    final playerLabels = ref.watch(statisticsPlayerLabelsProvider);
    final fineLabels = ref.watch(statisticsFineLabelsProvider);
    String names(Set<int> ids, Map<int, String> labels, String fallback) =>
        ids.take(2).map((id) => labels[id] ?? '$fallback $id').join(', ') +
        (ids.length > 2 ? ' +${ids.length - 2} další' : '');
    Future<void> openFilters() async {
      FocusManager.instance.primaryFocus?.unfocus();
      final result = await showStatisticsFilterSheet(
        context,
        args: statsArgs,
        filter: filter,
      );
      if (context.mounted && result != null) notifier.applyFilters(result);
    }

    if (compact)
      return Row(
        children: [
          Expanded(
            child: Text(
              filter.seasonIds.isEmpty
                  ? 'Všechny sezony'
                  : filter.seasonIds
                        .map(
                          (id) =>
                              seasons
                                  ?.where((s) => s.id == id)
                                  .firstOrNull
                                  ?.name ??
                              'Sezona $id',
                        )
                        .join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton.icon(
            onPressed: openFilters,
            icon: const Icon(Icons.tune, size: 18),
            label: Text('Filtry (${filter.activeCount})'),
          ),
          IconButton(
            tooltip: 'Obnovit statistiky',
            onPressed: notifier.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      );
    Widget chip(String label, VoidCallback remove) => InputChip(
      label: Text(label),
      onDeleted: remove,
      deleteButtonTooltipMessage: 'Zrušit: $label',
    );
    return AppSearchFilterBar(
      dense: true,
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
            names(filter.playerIds, playerLabels, 'Hráč'),
            () => notifier.applyFilters(filter.copyWith(playerIds: {})),
          ),
        if (filter.fineIds.isNotEmpty)
          chip(
            names(filter.fineIds, fineLabels, 'Pokuta'),
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
