import 'package:flutter/material.dart';
import 'package:trus_app/features/auth/screens/user_screen.dart';
import 'package:trus_app/features/beer/screens/beer_simple_screen.dart';
import 'package:trus_app/features/fine/match/screens/fine_match_screen.dart';
import 'package:trus_app/features/fine/screens/fine_screen.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/info/screens/info_screen.dart';
import 'package:trus_app/features/match/screens/add_match_screen.dart';
import 'package:trus_app/features/pkfl/screens/pkfl_fixtures_screen.dart';
import 'package:trus_app/features/pkfl/screens/pkfl_player_stats_screen.dart';
import 'package:trus_app/features/player/screens/add_player_screen.dart';
import 'package:trus_app/features/player/screens/player_screen.dart';
import 'package:trus_app/features/season/screens/season_screen.dart';
import 'package:trus_app/features/statistics/screens/goal/main_goal_statistics_screen.dart';

import '../../colors.dart';
import '../match/screens/match_screen.dart';
import '../pkfl/screens/main_pkfl_statistics_screen.dart';
import '../pkfl/screens/pkfl_table_screen.dart';
import '../steps/screens/step_screen.dart';

class BottomSheetNavigationManager {
  final BuildContext context;
  static const String deleteAccount = "DELETE_ACCOUNT";

  BottomSheetNavigationManager(this.context);

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
                  Row(
                    children: const [
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
                  Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "PKFL",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    key: const ValueKey('menu_pkfl_match_list'),
                    leading: const Icon(
                      Icons.sports_soccer,
                      color: Colors.orange,
                    ),
                    title: const Text("Program zápasů"),
                    onTap: () => onModalBottomSheetMenuTapped(PkflFixturesScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_pkfl_table'),
                    leading: const Icon(
                      Icons.scoreboard_rounded,
                      color: Colors.orange,
                    ),
                    title: const Text("PKFL tabulka"),
                    onTap: () => onModalBottomSheetMenuTapped(PkflTableScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_pkfl_stats'),
                    leading: const Icon(
                      Icons.equalizer,
                      color: Colors.orange,
                    ),
                    title: const Text("Statistiky z PKFL"),
                    onTap: () => onModalBottomSheetMenuTapped(MainPkflStatisticsScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_pkfl_player_stats'),
                    leading: const Icon(
                      Icons.stacked_bar_chart,
                      color: Colors.orange,
                    ),
                    title: const Text("Hráčské statistiky z PKFL"),
                    onTap: () => onModalBottomSheetMenuTapped(PkflPlayerStatsScreen.id),
                  ),
                  Row(
                    children: const [
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
                  Row(
                    children: const [
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
                  Row(
                    children: const [
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
                  Row(
                    children: const [
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
                    key: const ValueKey('menu_stats'),
                    leading: const Icon(
                      Icons.equalizer,
                      color: Colors.orange,
                    ),
                    title: const Text("Statistiky piv/pokut"),
                    onTap: () => onModalBottomSheetMenuTapped(MainPkflStatisticsScreen.id),
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
                  Row(
                    children: const [
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
                    title: const Text("Nastavení uživatele"),
                    onTap: () => onModalBottomSheetMenuTapped(UserScreen.id),
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
                  ListTile(
                    key: const ValueKey('steps'),
                    leading: const Icon(
                      Icons.edit_calendar,
                      color: Colors.orange,
                    ),
                    title: const Text("Kroky"),
                    onTap: () => onModalBottomSheetMenuTapped(StepScreen.id),

                  ),
                ],
              ),
            ));
  }
}
