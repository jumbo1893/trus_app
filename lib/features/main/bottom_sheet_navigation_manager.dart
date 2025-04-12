import 'package:flutter/material.dart';
import 'package:trus_app/features/achievement/screens/achievement_screen.dart';
import 'package:trus_app/features/beer/screens/beer_simple_screen.dart';
import 'package:trus_app/features/fine/match/screens/fine_match_screen.dart';
import 'package:trus_app/features/fine/screens/fine_screen.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/info/screens/info_screen.dart';
import 'package:trus_app/features/match/screens/add_match_screen.dart';
import 'package:trus_app/features/player/screens/add_player_screen.dart';
import 'package:trus_app/features/player/screens/player_screen.dart';
import 'package:trus_app/features/season/screens/season_screen.dart';
import 'package:trus_app/features/statistics/screens/main_goal_statistics_screen.dart';
import 'package:trus_app/features/user/screens/view_user_screen.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';

import '../../colors.dart';
import '../football/screens/football_fixtures_screen.dart';
import '../football/screens/football_player_stats_screen.dart';
import '../football/screens/main_football_statistics_screen.dart';
import '../football/table/screens/football_table_screen.dart';
import '../match/screens/match_screen.dart';
import '../statistics/screens/double_dropdown_stats_screen.dart';
import '../statistics/screens/main_statistics_screen.dart';
import '../user/screens/user_screen.dart';
class BottomSheetNavigationManager {
  final BuildContext context;
  static const String deleteAccount = "DELETE_ACCOUNT";
  final AppTeamApiModel? appTeamApiModel;

  BottomSheetNavigationManager(this.context, this.appTeamApiModel);

  bool isTableTeamFromAppTeamUsable() {
    return appTeamApiModel != null && appTeamApiModel!.team.currentTableTeam != null;
  }

  void showBottomSheetNavigation(Function(String) onModalBottomSheetMenuTapped,
      String userName, VoidCallback signOut) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        builder: (context) => SizedBox(
              height: MediaQuery.of(context).copyWith().size.height * (3 / 4),
              child: ListView(
                key: const ValueKey('bottom_navigation'),
                children: <Widget>[
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    onLongPress: () => Navigator.of(context).pop(),
                    child: Container(
                      color: Colors.grey,
                      height: 10,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(userName),
                        TextButton(
                            onPressed: () => signOut(),
                            key: const ValueKey('logout_button'),
                            child: const Text("Odhlásit",
                                style: TextStyle(
                                  color: orangeColor,
                                )))
                      ],
                    ),
                  ),
                  Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                    color: Colors.black,
                  )))),
                  ListTile(
                    key: const ValueKey('menu_home'),
                    leading: const Icon(
                      Icons.home,
                      color: Colors.orange,
                    ),
                    title: const Text("Přehled"),
                    onTap: () => onModalBottomSheetMenuTapped(HomeScreen.id),
                  ),
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "ZÁPASY",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    key: const ValueKey('menu_add_match'),
                    leading: const Icon(
                      Icons.add,
                      color: Colors.orange,
                    ),
                    title: const Text("Přidat zápas"),
                    onTap: () => onModalBottomSheetMenuTapped(AddMatchScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_match_list'),
                    leading: const Icon(
                      Icons.list_outlined,
                      color: Colors.orange,
                    ),
                    title: const Text("Seznam zápasů"),
                    onTap: () => onModalBottomSheetMenuTapped(MatchScreen.id),
                  ),
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "LIGA",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    key: const ValueKey('menu_football_match_list'),
                    leading: const Icon(
                      Icons.sports_soccer,
                      color: Colors.orange,
                    ),
                    title: const Text("Program zápasů"),
                    onTap: () => onModalBottomSheetMenuTapped(FootballFixturesScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_football_table'),
                    leading: const Icon(
                      Icons.scoreboard_rounded,
                      color: Colors.orange,
                    ),
                    title: const Text("Ligová tabulka"),
                    onTap: () => onModalBottomSheetMenuTapped(FootballTableScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_football_stats'),
                    leading: const Icon(
                      Icons.equalizer,
                      color: Colors.orange,
                    ),
                    title: isTableTeamFromAppTeamUsable() ? Text("Statistiky z ${appTeamApiModel!.team.currentTableTeam!.league.organization}") : const Text("Statistiky z Ligy"),
                    onTap: () => onModalBottomSheetMenuTapped(MainFootballStatisticsScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_football_player_stats'),
                    leading: const Icon(
                      Icons.stacked_bar_chart,
                      color: Colors.orange,
                    ),
                    title: isTableTeamFromAppTeamUsable() ? Text("Hráčské statistiky z ${appTeamApiModel!.team.currentTableTeam!.league.organization}") : const Text("Hráčské statistiky z ligy"),
                    onTap: () => onModalBottomSheetMenuTapped(FootballPlayerStatsScreen.id),
                  ),
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "HRÁČI",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    key: const ValueKey('menu_add_player'),
                    leading: const Icon(
                      Icons.person_add,
                      color: Colors.orange,
                    ),
                    title: const Text("Přidat hráče"),
                    onTap: () => onModalBottomSheetMenuTapped(AddPlayerScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_player_list'),
                    leading: const Icon(
                      Icons.group,
                      color: Colors.orange,
                    ),
                    title: const Text("Seznam hráčů"),
                    onTap: () => onModalBottomSheetMenuTapped(PlayerScreen.id),
                  ),
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "POKUTY",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    key: const ValueKey('menu_fine_settings'),
                    leading: const Icon(
                      Icons.attach_money,
                      color: Colors.orange,
                    ),
                    title: const Text("Přidat/upravit pokutu"),
                    onTap: () => onModalBottomSheetMenuTapped(FineScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_add_fine'),
                    leading: const Icon(
                      Icons.savings,
                      color: Colors.orange,
                    ),
                    title: const Text("Přidat pokutu v zápase"),
                    onTap: () => onModalBottomSheetMenuTapped(FineMatchScreen.id),
                  ),
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "PIVA",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    key: const ValueKey('menu_beer'),
                    leading: const Icon(
                      Icons.sports_bar,
                      color: Colors.orange,
                    ),
                    title: const Text("Přidat pivo v zápase"),
                    onTap: () => onModalBottomSheetMenuTapped(BeerSimpleScreen.id),
                  ),
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "STATISTIKY",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    key: const ValueKey('menu_achievements'),
                    leading: const Icon(
                      Icons.star,
                      color: Colors.orange,
                    ),
                    title: const Text("Seznam achievementů"),
                    onTap: () => onModalBottomSheetMenuTapped(AchievementScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_stats'),
                    leading: const Icon(
                      Icons.equalizer,
                      color: Colors.orange,
                    ),
                    title: const Text("Statistiky piv/pokut"),
                    onTap: () => onModalBottomSheetMenuTapped(MainStatisticsScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('beer_detail'),
                    leading: const Icon(
                      Icons.query_stats,
                      color: Colors.orange,
                    ),
                    title: const Text("Detail piv"),
                    onTap: () => onModalBottomSheetMenuTapped(DoubleDropdownStatsScreen.id),

                  ),
                  ListTile(
                    key: const ValueKey('menu_goal_stats'),
                    leading: const Icon(
                      Icons.query_stats,
                      color: Colors.orange,
                    ),
                    title: const Text("Statistiky gólů/asistencí"),
                    onTap: () => onModalBottomSheetMenuTapped(MainGoalStatisticsScreen.id),
                  ),
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "NASTAVENÍ",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    key: const ValueKey('menu_app_info'),
                    leading: const Icon(
                      Icons.info,
                      color: Colors.orange,
                    ),
                    title: const Text("Informace o appce"),
                    onTap: () => onModalBottomSheetMenuTapped(InfoScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_user_settings'),
                    leading: const Icon(
                      Icons.manage_accounts,
                      color: Colors.orange,
                    ),
                    title: const Text("Změnit pravomoce uživatelů"),
                    onTap: () => onModalBottomSheetMenuTapped(UserScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_user_settings'),
                    leading: const Icon(
                      Icons.account_box,
                      color: Colors.orange,
                    ),
                    title: const Text("Nastavení uživatele"),
                    onTap: () => onModalBottomSheetMenuTapped(ViewUserScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_delete_account'),
                    leading: const Icon(
                      Icons.no_accounts,
                      color: Colors.orange,
                    ),
                    title: const Text("Smazat účet"),
                    onTap: () => onModalBottomSheetMenuTapped(deleteAccount),
                  ),
                  ListTile(
                    key: const ValueKey('menu_season'),
                    leading: const Icon(
                      Icons.edit_calendar,
                      color: Colors.orange,
                    ),
                    title: const Text("Nastavení sezon"),
                    onTap: () => onModalBottomSheetMenuTapped(SeasonScreen.id),
                  ),
                  /*ListTile(
                    key: const ValueKey('steps'),
                    leading: const Icon(
                      Icons.edit_calendar,
                      color: Colors.orange,
                    ),
                    title: const Text("Kroky"),
                    onTap: () => onModalBottomSheetMenuTapped(StepScreen.id),

                  ),*/
                ],
              ),
            ));
  }
}
