import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/beer/repository/beer_api_service.dart';
import 'package:trus_app/features/season/controller/season_dropdown_notifier.dart';
import 'package:trus_app/models/api/interfaces/dropdown_item.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import '../../../common/widgets/notifier/dropdown/dropdown_state.dart';
import '../../../common/widgets/notifier/dropdown/i_dropdown_notifier.dart';
import '../../../models/api/interfaces/model_to_string.dart';
import '../../../models/api/stats/stats.dart';
import '../../season/season_args.dart';
import '../state/beer_detail_stats_state.dart';

final beerDetailStatsNotifierProvider =
StateNotifierProvider<BeerDetailStatsNotifier, BeerDetailStatsState>((ref) {
  return BeerDetailStatsNotifier(
    ref: ref,
    beerApiService: ref.read(beerApiServiceProvider),
  );
});

class BeerDetailStatsNotifier extends StateNotifier<BeerDetailStatsState> implements IDropdownNotifier {
  final Ref ref;
  final BeerApiService beerApiService;

  BeerDetailStatsNotifier({
    required this.ref,
    required this.beerApiService,
  }) : super(BeerDetailStatsState.initial()) {
    ref.listen<DropdownState>(seasonDropdownNotifierProvider(const SeasonArgs(false, false, true)), (_, next) {
      SeasonApiModel? season = next.selected as SeasonApiModel?;
      if (season != null) {
        _loadBeerStats(season.id!);
      }
    }, fireImmediately: true);
  }

  Future<void> _loadBeerStats(int seasonId) async {
    state = state.copyWith(
      dropdownTexts: const AsyncValue.loading(),
      stats: const AsyncValue.loading(),
    );
    final response = await beerApiService.getBeerStats(
      seasonId,
    );
    state = state.copyWith(
      dropdownTexts: AsyncValue.data(response),
      selectedText: state.selectedText?? response.first,
      stats: AsyncValue.data(_getStatsBySelectedText(response, state.selectedText?? response.first)),
    );
  }

  List<ModelToString> _getStatsBySelectedText(List<Stats> stats, DropdownItem selectedText) {
    return stats.firstWhere((stat) => stat.dropdownText == selectedText.dropdownItem(), orElse: () => Stats(dropdownText: "", playerStats: [])).playerStats;
  }

  @override
  selectDropdown(DropdownItem item) {
    state = state.copyWith(
      selectedText: item,
      stats: AsyncValue.data((item as Stats).playerStats),
    );
  }
}
