import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/beer/repository/beer_api_service.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';
import '../../../common/utils/season_util.dart';
import '../../../config.dart';
import '../filter/shared_statistics_season.dart';
import '../filter/statistics_filter_options.dart';
import 'package:trus_app/models/api/interfaces/dropdown_item.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import '../../../common/widgets/notifier/dropdown/i_dropdown_notifier.dart';
import '../../../models/api/interfaces/model_to_string.dart';
import '../../../models/api/stats/stats.dart';
import '../state/beer_detail_stats_state.dart';

final beerDetailStatsNotifierProvider =
    StateNotifierProvider<BeerDetailStatsNotifier, BeerDetailStatsState>((ref) {
      return BeerDetailStatsNotifier(
        ref: ref,
        beerApiService: ref.read(beerApiServiceProvider),
      );
    });

class BeerDetailStatsNotifier extends AppNotifier<BeerDetailStatsState>
    implements IDropdownNotifier {
  final BeerApiService beerApiService;
  int? _lastSeason;
  int _generation = 0;

  BeerDetailStatsNotifier({required Ref ref, required this.beerApiService})
    : super(ref, BeerDetailStatsState.initial()) {
    ref.listen<Set<int>?>(statisticsSeasonSelectionProvider, (_, next) {
      Future.microtask(_loadSelectedSeason);
    });
    ref.listen<AsyncValue<List<SeasonApiModel>>>(statisticsSeasonsProvider, (
      _,
      next,
    ) {
      next.whenData((seasons) {
        Future.microtask(() {
          if (!mounted) return;
          if (ref.read(statisticsSeasonSelectionProvider) == null) {
            final id = seasons.isEmpty ? null : returnCurrentSeason(seasons).id;
            ref.read(statisticsSeasonSelectionProvider.notifier).state = {
              if (id != null) id,
            };
          }
          _loadSelectedSeason();
        });
      });
    }, fireImmediately: true);
  }

  void _loadSelectedSeason() {
    if (!mounted) return;
    final ids = ref.read(statisticsSeasonSelectionProvider);
    if (ids == null || ids.length > 1) {
      _generation++;
      _lastSeason = null;
      return;
    }
    final seasonId = ids.isEmpty ? allSeasonId : ids.single;
    if (_lastSeason == seasonId) return;
    _lastSeason = seasonId;
    _loadBeerStats(seasonId);
  }

  Future<void> _loadBeerStats(int seasonId) async {
    final generation = ++_generation;
    state = state.copyWith(stats: const AsyncValue.loading());
    try {
      final response = await beerApiService.getBeerStats(seasonId);
      if (!mounted || generation != _generation) return;
      final selected =
          response
              .where(
                (item) =>
                    item.dropdownItem() == state.selectedText?.dropdownItem(),
              )
              .firstOrNull ??
          response.firstOrNull;
      state = state.copyWith(
        dropdownTexts: AsyncValue.data(response),
        selectedText: selected,
        stats: AsyncValue.data(
          selected == null ? [] : _getStatsBySelectedText(response, selected),
        ),
      );
    } catch (error, stack) {
      if (!mounted || generation != _generation) return;
      _lastSeason = null;
      state = state.copyWith(
        dropdownTexts: AsyncValue.error(error, stack),
        stats: AsyncValue.error(error, stack),
      );
    }
  }

  List<ModelToString> _getStatsBySelectedText(
    List<Stats> stats,
    DropdownItem selectedText,
  ) {
    return stats
        .firstWhere(
          (stat) => stat.dropdownText == selectedText.dropdownItem(),
          orElse: () => Stats(dropdownText: "", playerStats: []),
        )
        .playerStats;
  }

  @override
  selectDropdown(DropdownItem item) {
    state = state.copyWith(
      selectedText: item,
      stats: AsyncValue.data((item as Stats).playerStats),
    );
  }
}
