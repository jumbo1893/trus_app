import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_state.dart';

import '../../../models/api/football/football_match_api_model.dart';

class FootballFixturesListState implements IListviewState {
  final AsyncValue<List<FootballMatchApiModel>> footballMatches;
  final FootballMatchApiModel? selectedFootballMatch;

  FootballFixturesListState({
    required this.footballMatches,
    required this.selectedFootballMatch,
  });

  factory FootballFixturesListState.initial() => FootballFixturesListState(
    footballMatches: const AsyncValue.loading(),
    selectedFootballMatch: null,
      );

  FootballFixturesListState copyWith({
    AsyncValue<List<FootballMatchApiModel>>? footballMatches,
    FootballMatchApiModel? selectedFootballMatch,
  }) {
    return FootballFixturesListState(
      footballMatches: footballMatches ?? this.footballMatches,
      selectedFootballMatch: selectedFootballMatch ?? this.selectedFootballMatch,
    );
  }

  @override
  AsyncValue<List<FootballMatchApiModel>> getListViewItems() {
    return footballMatches;
  }
}
