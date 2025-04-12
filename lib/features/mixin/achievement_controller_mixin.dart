import 'dart:async';

import '../../models/api/achievement/achievement_player_detail.dart';

mixin AchievementControllerMixin {

  final Map<String, bool> createdAchievementChecker = {};
  final Map<String, AchievementPlayerDetail> achievementPlayerDetailValues = {};
  final Map<String, StreamController<AchievementPlayerDetail>> achievementPlayerDetailControllers = {};

  void _setAlreadyCreated(String key) {
    createdAchievementChecker[key] = true;
  }

  void _createViewCheckedList(String key) {
    if(!(createdAchievementChecker[key]?? false)) {
      _setAlreadyCreated(key);
      achievementPlayerDetailValues[key] = AchievementPlayerDetail.dummy();
      achievementPlayerDetailControllers[key] = StreamController<AchievementPlayerDetail>.broadcast();
    }
  }

  Stream<AchievementPlayerDetail> achievementPlayerValue(String key) {
    _createViewCheckedList(key);
    return achievementPlayerDetailControllers[key]?.stream ?? const Stream.empty();
  }

  void setAchievementPlayerValue(AchievementPlayerDetail achievement, String key) {
    _createViewCheckedList(key);
    achievementPlayerDetailValues[key] = achievement;
    achievementPlayerDetailControllers[key]?.add(achievement);
  }

  void initAchievementFields(AchievementPlayerDetail achievement, String key) {
    _createViewCheckedList(key);
    setAchievementPlayerValue(achievement, key);
  }
}