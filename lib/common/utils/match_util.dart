

import '../../models/player_model.dart';

List<String> convertPlayerListToIdList(List<PlayerModel?> players) {
  List<String> ids = [];
  for(PlayerModel? playerModel in players) {
    if(playerModel != null) {
      ids.add(playerModel.id);
    }
  }
  return ids;
}

List<String> convertPlayerListToNameList(List<PlayerModel> players) {
  List<String> names = [];
  for(PlayerModel playerModel in players) {
    names.add(playerModel.name);
  }
  return names;
}