import 'package:flutter/material.dart';
import 'package:trus_app/features/achievement/screens/achievement_screen.dart';
import 'package:trus_app/features/achievement/screens/view_achievement_detail_screen.dart';
import 'package:trus_app/features/achievement/screens/view_player_achievement_detail_screen.dart';
import 'package:trus_app/features/fine/match/screens/fine_player_screen.dart';
import 'package:trus_app/features/fine/screens/fine_screen.dart';
import 'package:trus_app/features/football/table/screens/main_table_team_screen.dart';
import 'package:trus_app/features/footbar/screens/footbar_sync_screen.dart';
import 'package:trus_app/features/goal/screen/goal_screen.dart';
import 'package:trus_app/features/match/screens/add_match_screen.dart';
import 'package:trus_app/features/match/screens/match_screen.dart';
import 'package:trus_app/features/player/screens/add_player_screen.dart';
import 'package:trus_app/features/player/screens/edit_player_screen.dart';
import 'package:trus_app/features/player/screens/player_screen.dart';
import 'package:trus_app/features/season/screens/edit_season_screen.dart';
import 'package:trus_app/features/season/screens/season_screen.dart';
import 'package:trus_app/features/user/screens/view_user_screen.dart';

import '../beer/screens/beer_simple_screen.dart';
import '../fine/match/screens/fine_match_screen.dart';
import '../fine/match/screens/multiple_fine_players_screen.dart';
import '../fine/screens/add_fine_screen.dart';
import '../fine/screens/edit_fine_screen.dart';
import '../football/screens/football_fixtures_screen.dart';
import '../football/screens/football_player_stats_screen.dart';
import '../football/screens/football_stats_screen.dart';
import '../football/table/screens/football_table_screen.dart';
import '../footbar/screens/footbar_compare_screen.dart';
import '../footbar/screens/footbar_connect_screen.dart';
import '../home/screens/home_screen.dart';
import '../info/screens/info_screen.dart';
import '../match/screens/match_detail_screen.dart';
import '../notification/push/screen/enabled_notifications_screen.dart';
import '../notification/screen/notification_screen.dart';
import '../player/screens/view_player_screen.dart';
import '../season/screens/add_season_screen.dart';
import '../statistics/screens/beer/beer_detail_stats_screen.dart';
import '../statistics/screens/beer/beer_match_statistic_screen.dart';
import '../statistics/screens/beer/beer_player_statistic_screen.dart';
import '../statistics/screens/fine/fine_match_statistic_screen.dart';
import '../statistics/screens/fine/fine_player_statistic_screen.dart';
import '../statistics/screens/goal/goal_match_statistic_screen.dart';
import '../statistics/screens/goal/goal_player_statistic_screen.dart';
import '../steps/screens/step_screen.dart';
import '../strava/screens/strava_football_match_screen.dart';
import '../user/screens/user_screen.dart';

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
  const BeerSimpleScreen(
    //17
  ),
  const PlayerScreen(
    //18
  ),
  const FootballFixturesScreen(
    //19
  ),
  const FootballStatsScreen(
    //20
  ),
  const FootballTableScreen(
    //21
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
  const EnabledNotificationsScreen(
    //37
  ),
  const FootbarConnectScreen(
    //38
  ),
  const FootbarSyncScreen(
    //39
  ),
  const FootbarCompareScreen(
    //40
  ),
  const BeerPlayerStatisticScreen(
    //41
  ),
  const BeerMatchStatisticScreen(
    //42
  ),
  const FinePlayerStatisticScreen(
    //43
  ),
  const FineMatchStatisticScreen(
    //44
  ),
  const GoalPlayerStatisticScreen(
    //45
  ),
  const GoalMatchStatisticScreen(
    //46
  ),
  const BeerDetailStatsScreen(
    //47
  ),
];

List<Widget> get widgetList => _widgetList;

final List<String> _statisticScreens = [
  BeerMatchStatisticScreen.id,
  BeerPlayerStatisticScreen.id,
  FinePlayerStatisticScreen.id,
  FineMatchStatisticScreen.id,
  GoalMatchStatisticScreen.id,
  GoalPlayerStatisticScreen.id,
];

List<String> get statisticScreenList => _statisticScreens;