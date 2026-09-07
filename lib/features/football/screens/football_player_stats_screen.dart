import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/search_text.dart';
import '../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../statistics/widget/statistics_dropdown_filter_bar.dart';
import '../controller/football_player_dropdown_notifier.dart';
import '../controller/football_player_stats_notifier.dart';

class FootballPlayerStatsScreen extends CustomConsumerStatefulWidget {
  static const String id = 'football-player-stats-screen';
  const FootballPlayerStatsScreen({super.key})
    : super(title: 'Ligové zajímavosti', name: id);
  @override
  ConsumerState<FootballPlayerStatsScreen> createState() =>
      _FootballPlayerStatsScreenState();
}

class _FootballPlayerStatsScreenState
    extends ConsumerState<FootballPlayerStatsScreen> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(footballPlayerStatsNotifierProvider);
    final query = normalizeSearchText(_query);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: StatisticsDropdownFilterBar(
              query: _query,
              searchHint: 'Hledat zajímavost',
              onQueryChanged: (value) => setState(() => _query = value),
              fields: (ref) {
                final players = ref.watch(
                  footballPlayerDropdownNotifierProvider,
                );
                return [
                  StatisticsDropdownFilter(
                    label: 'Hráč',
                    items: players.dropdownItems,
                    selected: players.selected,
                    onChanged: ref
                        .read(footballPlayerDropdownNotifierProvider.notifier)
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
