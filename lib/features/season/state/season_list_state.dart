import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_state.dart';
import 'package:trus_app/models/api/season_api_model.dart';

class SeasonListState implements IListviewState {
  final AsyncValue<List<SeasonApiModel>> seasons;
  final SeasonApiModel? selectedSeason;

  SeasonListState({
    required this.seasons,
    required this.selectedSeason,
  });

  factory SeasonListState.initial() => SeasonListState(
      seasons: const AsyncValue.loading(),
      selectedSeason: null,
      );

  SeasonListState copyWith({
    AsyncValue<List<SeasonApiModel>>? seasons,
    SeasonApiModel? selectedSeason,
  }) {
    return SeasonListState(
      seasons: seasons ?? this.seasons,
      selectedSeason: selectedSeason ?? this.selectedSeason,
        );
  }

  @override
  AsyncValue<List<SeasonApiModel>> getListViewItems() {
    return seasons;
  }
}
