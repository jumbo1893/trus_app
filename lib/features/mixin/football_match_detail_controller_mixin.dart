import 'dart:async';

import 'package:trus_app/models/api/football/detail/football_match_detail.dart';
mixin FootballMatchDetailControllerMixin {

  final Map<String, FootballMatchDetail?> footballMatchDetailValues = {};
  final Map<String, bool> createdFootballMatchDetailChecker = {};
  final Map<String, StreamController<FootballMatchDetail?>> footballMatchDetailControllers = {};

  void _setAlreadyCreated(String key) {
    createdFootballMatchDetailChecker[key] = true;
  }

  void _createFootballMatchDetailStream(String key) {
    if(!(createdFootballMatchDetailChecker[key]?? false)) {
      _setAlreadyCreated(key);
      footballMatchDetailValues[key] = FootballMatchDetail.dummy();
      footballMatchDetailControllers[key] = StreamController<FootballMatchDetail?>.broadcast();
    }
  }

  Stream<FootballMatchDetail?> footballMatchDetailValue(String key) {
    _createFootballMatchDetailStream(key);
    return footballMatchDetailControllers[key]?.stream ?? const Stream.empty();
  }

  void setFootballMatchDetailValue(FootballMatchDetail? match, String key) {
    _createFootballMatchDetailStream(key);
    footballMatchDetailValues[key] = match;
    footballMatchDetailControllers[key]?.add(match);
  }

  void initFootballMatchDetailFields(FootballMatchDetail? match, String key) {
    _createFootballMatchDetailStream(key);
    setFootballMatchDetailValue(match, key);
  }
}
