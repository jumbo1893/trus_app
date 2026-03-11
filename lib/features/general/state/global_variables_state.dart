import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class GlobalVariablesState {
  final AppTeamApiModel? appTeam;
  final PlayerApiModel? player;

  const GlobalVariablesState({
    required this.appTeam,
    required this.player,
  });

  factory GlobalVariablesState.initial() => const GlobalVariablesState(
    appTeam: null,
    player: null,
  );

  GlobalVariablesState copyWith({
    AppTeamApiModel? appTeam,
    PlayerApiModel? player,
  }) {
    return GlobalVariablesState(
      appTeam: appTeam ?? this.appTeam,
      player: player ?? this.player,
    );
  }
}
