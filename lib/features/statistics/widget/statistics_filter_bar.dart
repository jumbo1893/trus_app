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
    return AppSearchFilterBar(
      query: state.filter ?? '',
      searchHint: statsArgs.matchOrPlayer
          ? 'Hledat zápas / soupeře'
          : 'Hledat hráče nebo fanouška',
      onQueryChanged: notifier.search,
      onClear: notifier.clearFilter,
      activeFilterCount: state.advancedFilter.activeCount,
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
