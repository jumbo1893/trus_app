import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

import '../state/global_variables_state.dart';


final globalVariablesProvider =
StateNotifierProvider<GlobalVariablesNotifier, GlobalVariablesState>((ref) {
  return GlobalVariablesNotifier();
});

class GlobalVariablesNotifier extends StateNotifier<GlobalVariablesState> {
  GlobalVariablesNotifier() : super(GlobalVariablesState.initial());

  void setAppTeam(AppTeamApiModel appTeam) {
    state = state.copyWith(appTeam: appTeam);
  }

  void setPlayer(PlayerApiModel? player) {
    state = state.copyWith(player: player);
  }
}
