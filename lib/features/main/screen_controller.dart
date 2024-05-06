import 'dart:async';
import 'package:trus_app/features/fine/match/screens/fine_match_screen.dart';
import 'package:trus_app/features/fine/match/screens/fine_player_screen.dart';
import 'package:trus_app/features/fine/screens/fine_screen.dart';
import 'package:trus_app/features/goal/screen/goal_screen.dart';
import 'package:trus_app/features/match/screens/add_match_screen.dart';
import 'package:trus_app/features/match/screens/match_screen.dart';
import 'package:trus_app/features/pkfl/screens/main_pkfl_statistics_screen.dart';
import 'package:trus_app/features/player/screens/add_player_screen.dart';
import 'package:trus_app/features/player/screens/edit_player_screen.dart';
import 'package:trus_app/features/player/screens/player_screen.dart';
import 'package:trus_app/features/season/screens/edit_season_screen.dart';
import 'package:trus_app/features/season/screens/season_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:trus_app/features/pkfl/screens/pkfl_table_screen.dart';
import 'package:trus_app/models/api/fine_api_model.dart';
import '../../../models/api/pkfl/pkfl_match_api_model.dart';
import '../../models/api/match/match_api_model.dart';
import '../../models/api/player_api_model.dart';
import '../../models/api/season_api_model.dart';
import '../../models/enum/match_detail_options.dart';
import '../auth/screens/user_screen.dart';
import '../beer/screens/beer_simple_screen.dart';
import '../fine/match/screens/multiple_fine_players_screen.dart';
import '../fine/screens/add_fine_screen.dart';
import '../fine/screens/edit_fine_screen.dart';
import '../general/screen_name.dart';
import '../home/screens/home_screen.dart';
import '../info/screens/info_screen.dart';
import '../notification/screen/notification_screen.dart';
import '../pkfl/screens/match_detail_screen.dart';
import '../pkfl/screens/pkfl_fixtures_screen.dart';
import '../pkfl/screens/pkfl_player_stats_screen.dart';
import '../season/screens/add_season_screen.dart';
import '../statistics/screens/double_dropdown_stats_screen.dart';
import '../statistics/screens/main_goal_statistics_screen.dart';
import '../statistics/screens/main_statistics_screen.dart';
import '../steps/screens/step_screen.dart';

final screenControllerProvider = Provider((ref) {
  return ScreenController(
      ref: ref);
});

class ScreenController {
  final ProviderRef ref;
  final screenController = StreamController<Widget>.broadcast();

  ScreenController({
    required this.ref,
  });


  int? _matchId;
  int? _pkflMatchId;
  PkflMatchApiModel? _pkflMatch;
  MatchApiModel _matchModel = MatchApiModel.dummy(); // používáme, pokud chceme na další screenu předat třeba i jméno, jinak stačí id
  PlayerApiModel _playerModel = PlayerApiModel.dummy();
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
    _pkflMatch = null;
    _commonMatchesOnly = false;
    _matchId = id;
  }

  int? get pkflMatchId => _pkflMatchId;

  void setPkflMatchIdOnlyForCommonMatches(int id) {
    _commonMatchesOnly = true;
    _pkflMatchId = id;
  }

  MatchApiModel get matchModel => _matchModel;

  void setMatch(MatchApiModel matchModel) {
    _matchModel = matchModel;
    _commonMatchesOnly = false;
    setMatchId(matchModel.id!);
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

  PkflMatchApiModel? get pkflMatch => _pkflMatch;

  void setPkflMatch(PkflMatchApiModel pkflMatch) {
    _commonMatchesOnly = false;
    _pkflMatch = pkflMatch;
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
    const PkflPlayerStatsScreen(
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
    const PkflFixturesScreen(
      //19
    ),
    const MainPkflStatisticsScreen(
      //20
    ),
    const PkflTableScreen(
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
    )
  ];

  List<Widget> get widgetList => _widgetList;
}
