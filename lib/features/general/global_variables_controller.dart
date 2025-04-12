import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';

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

  AppTeamApiModel? get appTeam => _appTeam;

  void setAppTeam(AppTeamApiModel appTeam) {
    _appTeam = appTeam;
  }
}
