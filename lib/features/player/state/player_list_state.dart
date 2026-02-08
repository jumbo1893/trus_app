import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_state.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class PlayerListState implements IListviewState {
  final AsyncValue<List<PlayerApiModel>> players;
  final PlayerApiModel? selectedPlayer;

  PlayerListState({
    required this.players,
    required this.selectedPlayer,
  });

  factory PlayerListState.initial() => PlayerListState(
    players: const AsyncValue.loading(),
    selectedPlayer: null,
      );

  PlayerListState copyWith({
    AsyncValue<List<PlayerApiModel>>? players,
    PlayerApiModel? selectedPlayer,
  }) {
    return PlayerListState(
      players: players ?? this.players,
      selectedPlayer: selectedPlayer ?? this.selectedPlayer,
        );
  }

  @override
  AsyncValue<List<PlayerApiModel>> getListViewItems() {
    return players;
  }
}
