import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/widgets/notifier/listview/model_to_string_listview.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../../common/utils/search_text.dart';
import '../../../../config.dart';
import '../../../../models/api/season_api_model.dart';
import '../../controller/beer_detail_stats_notifier.dart';
import '../../filter/shared_statistics_season.dart';
import '../../filter/statistics_filter_options.dart';
import '../../widget/statistics_dropdown_filter_bar.dart';

class BeerDetailStatsScreen extends CustomConsumerStatefulWidget {
  static const String id = 'beer-detail-stats-screen';
  const BeerDetailStatsScreen({super.key})
    : super(title: 'Podrobné statistiky piv', name: id);
  @override
  ConsumerState<BeerDetailStatsScreen> createState() =>
      _BeerDetailStatsScreenState();
}

class _BeerDetailStatsScreenState extends ConsumerState<BeerDetailStatsScreen> {
  String _query = '';
  final _scrollController = ScrollController();
  bool _showFilters = true;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final offset = _scrollController.offset;
    if (_showFilters && offset > 40)
      setState(() => _showFilters = false);
    else if (!_showFilters && offset <= 12)
      setState(() => _showFilters = true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(beerDetailStatsNotifierProvider);
    final query = normalizeSearchText(_query);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: StatisticsDropdownFilterBar(
              compact: !_showFilters,
              helpText:
                  'Zde lze vybrat jednu sezonu nebo všechny sezony. Při přechodu z více sezon se zobrazí nejnovější ze zvolených.',
              onRefresh: ref
                  .read(beerDetailStatsNotifierProvider.notifier)
                  .refresh,
              query: _query,
              searchHint: 'Hledat hráče',
              onQueryChanged: (value) => setState(() => _query = value),
              fields: (ref) {
                final seasonId = ref.watch(beerDetailSeasonProvider);
                final options = ref
                    .watch(statisticsSeasonsProvider)
                    .whenData(
                      (seasons) => [
                        SeasonApiModel(
                          name: 'Všechny sezony',
                          fromDate: DateTime(0),
                          toDate: DateTime(0),
                          id: allSeasonId,
                        ),
                        ...seasons,
                      ],
                    );
                final detail = ref.watch(beerDetailStatsNotifierProvider);
                return [
                  StatisticsDropdownFilter(
                    label: 'Sezona',
                    items: options,
                    selected: options.asData?.value
                        .where((s) => s.id == seasonId)
                        .firstOrNull,
                    onChanged: (item) {
                      final id = (item as SeasonApiModel).id!;
                      ref
                          .read(statisticsSeasonSelectionProvider.notifier)
                          .state = id == allSeasonId
                          ? {}
                          : {id};
                    },
                  ),
                  StatisticsDropdownFilter(
                    label: 'Statistika',
                    items: detail.dropdownTexts,
                    selected: detail.selectedText,
                    onChanged: ref
                        .read(beerDetailStatsNotifierProvider.notifier)
                        .selectDropdown,
                  ),
                ];
              },
            ),
          ),
          Expanded(
            child: ModelToStringListview(
              scrollController: _scrollController,
              bottomPadding: 16,
              onRefresh: ref
                  .read(beerDetailStatsNotifierProvider.notifier)
                  .refresh,
              emptyListTitle: query.isNotEmpty
                  ? 'Hledání neodpovídají žádné výsledky'
                  : 'Pro toto období nejsou data',
              emptyListText: query.isNotEmpty
                  ? 'Zkus jiné jméno nebo vymaž hledání.'
                  : 'Zkus změnit období nebo obnovit přehled.',

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
              onRetry: () => ref.invalidate(beerDetailStatsNotifierProvider),
            ),
          ),
        ],
      ),
    );
  }
}
