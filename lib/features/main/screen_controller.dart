import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/achievement/screens/achievement_screen.dart';
import 'package:trus_app/features/achievement/screens/view_achievement_detail_screen.dart';
import 'package:trus_app/features/achievement/screens/view_player_achievement_detail_screen.dart';
import 'package:trus_app/features/fine/match/screens/fine_match_screen.dart';
import 'package:trus_app/features/fine/match/screens/fine_player_screen.dart';
import 'package:trus_app/features/fine/screens/fine_screen.dart';
import 'package:trus_app/features/football/table/screens/main_table_team_screen.dart';
import 'package:trus_app/features/goal/screen/goal_screen.dart';
import 'package:trus_app/features/match/screens/add_match_screen.dart';
import 'package:trus_app/features/match/screens/match_screen.dart';
import 'package:trus_app/features/player/screens/add_player_screen.dart';
import 'package:trus_app/features/player/screens/edit_player_screen.dart';
import 'package:trus_app/features/player/screens/player_screen.dart';
import 'package:trus_app/features/season/screens/edit_season_screen.dart';
import 'package:trus_app/features/season/screens/season_screen.dart';
import 'package:trus_app/features/user/screens/view_user_screen.dart';
import 'package:trus_app/models/api/achievement/achievement_detail.dart';
import 'package:trus_app/models/api/achievement/player_achievement_api_model.dart';
import 'package:trus_app/models/api/fine_api_model.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/football/table_team_api_model.dart';

import '../../models/api/match/match_api_model.dart';
import '../../models/api/player/player_api_model.dart';
import '../../models/api/season_api_model.dart';
import '../../models/enum/match_detail_options.dart';
import '../beer/screens/beer_simple_screen.dart';
import '../fine/match/screens/multiple_fine_players_screen.dart';
import '../fine/screens/add_fine_screen.dart';
import '../fine/screens/edit_fine_screen.dart';
import '../football/screens/football_fixtures_screen.dart';
import '../football/screens/football_player_stats_screen.dart';
import '../football/screens/main_football_statistics_screen.dart';
import '../football/screens/match_detail_screen.dart';
import '../football/table/screens/football_table_screen.dart';
import '../general/screen_name.dart';
import '../home/screens/home_screen.dart';
import '../info/screens/info_screen.dart';
import '../notification/screen/notification_screen.dart';
import '../player/screens/view_player_screen.dart';
import '../season/screens/add_season_screen.dart';
import '../statistics/screens/double_dropdown_stats_screen.dart';
import '../statistics/screens/main_goal_statistics_screen.dart';
import '../statistics/screens/main_statistics_screen.dart';
import '../steps/screens/step_screen.dart';
import '../strava/screens/strava_football_match_screen.dart';
import '../user/screens/user_screen.dart';

final screenControllerProvider = Provider((ref) {
  return ScreenController(
      ref: ref);
});

class ScreenController {
  final Ref ref;
  final screenController = StreamController<Widget>.broadcast();

  ScreenController({
    required this.ref,
  });


  int? _matchId;
  int? _footballTeamId;
  FootballMatchApiModel? _footballMatch;
  TableTeamApiModel _tableTeamApiModel = TableTeamApiModel.dummy();
  MatchApiModel _matchModel = MatchApiModel.dummy(); // používáme, pokud chceme na další screenu předat třeba i jméno, jinak stačí id
  PlayerApiModel _playerModel = PlayerApiModel.dummy();
  PlayerAchievementApiModel _playerAchievementApiModel = PlayerAchievementApiModel.dummy();
  AchievementDetail _achievementDetail = AchievementDetail.dummy();
  SeasonApiModel _seasonModel = SeasonApiModel.dummy();
  FineApiModel _fineModel = FineApiModel.dummy();
  List<int> _playerIdList = [];
  MatchDetailOptions _preferredScreen = MatchDetailOptions.editMatch;
  bool _changedMatch = false;
  String _currentScreenId = HomeScreen.id;
  bool _commonMatchesOnly = false;

  Stream<Widget> screen() {
    return screenController.stream;
  }

  int? get matchId => _matchId;

  void setMatchId(int id) {
    _footballMatch = null;
    _commonMatchesOnly = false;
    _matchId = id;
  }

  int? get footballTeamId => _footballTeamId;

  void setFootballTeamIdOnlyForCommonMatches(int id) {
    _commonMatchesOnly = true;
    _footballTeamId = id;
  }

  MatchApiModel get matchModel => _matchModel;

  void setMatch(MatchApiModel matchModel) {
    _matchModel = matchModel;
    _commonMatchesOnly = false;
    setMatchId(matchModel.id!);
  }

  TableTeamApiModel get tableTeamApiModel => _tableTeamApiModel;

  void setTableTeamApiModel(TableTeamApiModel tableTeamApiModel) {
    _tableTeamApiModel = tableTeamApiModel;
  }

  PlayerAchievementApiModel get playerAchievementApiModel => _playerAchievementApiModel;

  void setPlayerAchievement(PlayerAchievementApiModel playerAchievementApiModel) {
    _playerAchievementApiModel = playerAchievementApiModel;
  }

  AchievementDetail get achievementDetail => _achievementDetail;

  void setAchievementDetail(AchievementDetail achievementDetail) {
    _achievementDetail = achievementDetail;
  }

  PlayerApiModel get playerModel => _playerModel;

  void setPlayer(PlayerApiModel playerModel) {
    _playerModel = playerModel;
  }

  SeasonApiModel get seasonModel => _seasonModel;

  void setSeason(SeasonApiModel seasonModel) {
    _seasonModel = seasonModel;
  }

  FineApiModel get fineModel => _fineModel;

  void setFine(FineApiModel fineModel) {
    _fineModel = fineModel;
  }

  List<int> get playerIdList => _playerIdList;

  void setPlayerIdList(List<int> playerIdList) {
    _playerIdList = playerIdList;
  }

  MatchDetailOptions get preferredScreen => _preferredScreen;

  void setPreferredScreen(MatchDetailOptions preferredScreen) {
    _preferredScreen = preferredScreen;
  }

  FootballMatchApiModel? get footballMatch => _footballMatch;

  void setFootballMatch(FootballMatchApiModel footballMatch) {
    _commonMatchesOnly = false;
    _footballMatch = footballMatch;
  }

  bool isChangedMatch() {
    if (_changedMatch) {
      _changedMatch = false;
      return true;
    }
    return false;
  }

  void setChangedMatch(bool changedMatch) {
    _changedMatch = changedMatch;
  }

  bool get isCommonMatchesOnly => _commonMatchesOnly;

  bool isScreenFocused(String screenId) {
    return _currentScreenId == screenId;
  }

  void changeFragment(String fragmentId) {
    Widget screen = _widgetList.firstWhere((element) => ((element as ScreenName).screenName() == fragmentId), orElse: () => _widgetList[0]);
    _currentScreenId = (screen as ScreenName).screenName();
    screenController.add(screen);
  }

  Widget getFragmentByFragmentId(String fragmentId) {
    return _widgetList.firstWhere((element) => ((element as ScreenName).screenName() == fragmentId), orElse: () => _widgetList[0]);
  }

  int getFragmentNumberByFragmentId(String fragmentId) {
    Widget screen =  _widgetList.firstWhere((element) => ((element as ScreenName).screenName() == fragmentId), orElse: () => _widgetList[0]);
    return _widgetList.indexOf(screen);
  }

  final List<Widget> _widgetList = [
    const HomeScreen(
      //0
    ),
    const FineMatchScreen(
      //1
    ),
    const HomeScreen(
      //2
    ),
    const MainStatisticsScreen(
      //3
    ),
    const AddPlayerScreen(
      //4
    ),
    const EditPlayerScreen(
      //5
    ),
    const SeasonScreen(
      //6
    ),
    const AddSeasonScreen(
      //7
    ),
    const EditSeasonScreen(
      //8
    ),
    const MatchScreen(
      //9
    ),
    const AddMatchScreen(
      //10
    ),
    const FootballPlayerStatsScreen(
      //11
    ),
    const FineScreen(
      //12
    ),
    const AddFineScreen(
      //13
    ),
    const EditFineScreen(
      //14
    ),
    const FinePlayerScreen(
      //15
    ),
    const MultipleFinePlayersScreen(
      //16
    ),
    const BeerSimpleScreen(
      //17
    ),
    const PlayerScreen(
      //18
    ),
    const FootballFixturesScreen(
      //19
    ),
    const MainFootballStatisticsScreen(
      //20
    ),
    const FootballTableScreen(
      //21
    ),
    const MainGoalStatisticsScreen(
      //22
    ),
    const NotificationScreen(
      //23
    ),
    const UserScreen(
      //24
    ),
    const GoalScreen(
      //25
    ),
    const InfoScreen(
      //26
    ),
    const MatchDetailScreen(
      //27
    ),
    const StepScreen(
      //28
    ),
    const DoubleDropdownStatsScreen(
      //29
    ),
    const ViewPlayerScreen(
      //30
    ),
    const ViewPlayerAchievementDetailScreen(
      //31
    ),
    const ViewAchievementDetailScreen(
      //32
    ),
    const AchievementScreen(
      //33
    ),
    const MainTableTeamScreen(
      //34
    ),
    const ViewUserScreen(
      //35
    ),
    StravaFootballMatchScreen(
      //36
    ),
  ];

  List<Widget> get widgetList => _widgetList;
}
