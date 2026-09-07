import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/search_text.dart';
import '../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../statistics/widget/statistics_dropdown_filter_bar.dart';
import '../controller/current_season_notifier.dart';
import '../controller/footbal_stats_notifier.dart';
import '../../../models/enum/spinner_options.dart';

class FootballStatsScreen extends CustomConsumerStatefulWidget {
  static const String id = 'football-stats-screen';
  const FootballStatsScreen({super.key})
    : super(title: 'Ligové statistiky hráčů', name: id);
  @override
  ConsumerState<FootballStatsScreen> createState() =>
      _FootballStatsScreenState();
}

class _FootballStatsScreenState extends ConsumerState<FootballStatsScreen> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(footballStatsNotifierProvider);
    final query = normalizeSearchText(_query);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: StatisticsDropdownFilterBar(
              query: _query,
              searchHint: 'Hledat hráče',
              onQueryChanged: (value) => setState(() => _query = value),
              fields: (ref) {
                final seasons = ref.watch(currentSeasonNotifierProvider);
                final stats = ref.watch(footballStatsNotifierProvider);
                return [
                  StatisticsDropdownFilter(
                    label: 'Sezona',
                    items: seasons.dropdownItems,
                    selected: seasons.selected,
                    onChanged: ref
                        .read(currentSeasonNotifierProvider.notifier)
                        .selectDropdown,
                  ),
                  StatisticsDropdownFilter(
                    label: 'Statistika',
                    items: const AsyncValue.data(SpinnerOption.values),
                    selected: stats.selectedText ?? SpinnerOption.values.first,
                    onChanged: ref
                        .read(footballStatsNotifierProvider.notifier)
                        .selectDropdown,
                  ),
                ];
              },
            ),
          ),
          Expanded(
            child: ModelToStringListview(
              state: state.copyWith(
                stats: state.stats.whenData(
                  (items) => items
                      .where(
                        (item) => normalizeSearchText(
                          '${item.listViewTitle()} ${item.toStringForListView()}',
                        ).contains(query),
                      )
                      .toList(),
                ),
              ),
              notifier: null,
            ),
          ),
        ],
      ),
    );
  }
}
