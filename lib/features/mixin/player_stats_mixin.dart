import 'dart:async';

import 'package:trus_app/models/api/player/stats/player_stats.dart';

mixin PlayerStatsMixin {

  final Map<String, bool> createdPlayerStatsChecker = {};
  final Map<String, PlayerStats?> playerStatsValues = {};
  final Map<String, StreamController<PlayerStats?>> playerStatsControllers = {};

  void _setAlreadyCreated(String key) {
    createdPlayerStatsChecker[key] = true;
  }

  void _createPlayerStatsChecker(String key) {
    if(!(createdPlayerStatsChecker[key]?? false)) {
      _setAlreadyCreated(key);
      playerStatsValues[key] = null;
      playerStatsControllers[key] = StreamController<PlayerStats?>.broadcast();
    }
  }

  Stream<PlayerStats?> playerStatsValue(String key) {
    _createPlayerStatsChecker(key);
    return playerStatsControllers[key]?.stream ?? const Stream.empty();
  }

  void setPlayerStatsValue(PlayerStats? stats, String key) {
    _createPlayerStatsChecker(key);
    playerStatsValues[key] = stats;
    playerStatsControllers[key]?.add(stats);
  }

  void initPlayerStatsFields(PlayerStats? stats, String key) {
    _createPlayerStatsChecker(key);
    setPlayerStatsValue(stats, key);
  }
}