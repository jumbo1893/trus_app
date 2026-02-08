import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_state.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';

class MatchListState implements IListviewState {
  final AsyncValue<List<MatchApiModel>> matches;
  final MatchApiModel? selectedMatch;

  MatchListState({
    required this.matches,
    required this.selectedMatch,
  });

  factory MatchListState.initial() => MatchListState(
    matches: const AsyncValue.loading(),
    selectedMatch: null,
      );

  MatchListState copyWith({
    AsyncValue<List<MatchApiModel>>? matches,
    MatchApiModel? selectedMatch,
  }) {
    return MatchListState(
      matches: matches ?? this.matches,
      selectedMatch: selectedMatch ?? this.selectedMatch,
        );
  }

  @override
  AsyncValue<List<MatchApiModel>> getListViewItems() {
    return matches;
  }
}
