import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

final globalVariablesControllerProvider = Provider((ref) {
  return GlobalVariablesController(
      ref: ref);
});

class GlobalVariablesController {
  final Ref ref;
  GlobalVariablesController({
    required this.ref,
  });


  AppTeamApiModel? _appTeam;
  PlayerApiModel? _playerApiModel;

  AppTeamApiModel? get appTeam => _appTeam;

  void setAppTeam(AppTeamApiModel appTeam) {
    _appTeam = appTeam;
  }

  PlayerApiModel? get playerApiModel => _playerApiModel;

  void setPlayerApiModel(PlayerApiModel? playerApiModel) {
    _playerApiModel = playerApiModel;
  }
}
