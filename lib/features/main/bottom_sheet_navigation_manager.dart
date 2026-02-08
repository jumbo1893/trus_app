import 'package:flutter/material.dart';
import 'package:trus_app/features/achievement/screens/achievement_screen.dart';
import 'package:trus_app/features/beer/screens/beer_simple_screen.dart';
import 'package:trus_app/features/fine/screens/fine_screen.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/info/screens/info_screen.dart';
import 'package:trus_app/features/match/screens/add_match_screen.dart';
import 'package:trus_app/features/player/screens/add_player_screen.dart';
import 'package:trus_app/features/player/screens/player_screen.dart';
import 'package:trus_app/features/season/screens/season_screen.dart';
import 'package:trus_app/features/strava/screens/strava_football_match_screen.dart';
import 'package:trus_app/features/user/screens/view_user_screen.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';

import '../../colors.dart';
import '../fine/match/screens/fine_match_screen.dart';
import '../football/screens/football_fixtures_screen.dart';
import '../football/table/screens/football_table_screen.dart';
import '../match/screens/match_screen.dart';
import '../user/screens/user_screen.dart';
class BottomSheetNavigationManager {
  final BuildContext context;
  static const String deleteAccount = "DELETE_ACCOUNT";
  final AppTeamApiModel? appTeamApiModel;

  BottomSheetNavigationManager(this.context, this.appTeamApiModel);

  bool isTableTeamFromAppTeamUsable() {
    return appTeamApiModel != null && appTeamApiModel!.team.currentTableTeam != null;
  }

  void showBottomSheetNavigation(
      Function(String) onModalBottomSheetMenuTapped,
      String userName,
      VoidCallback signOut,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            //Ukotvená horní část
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              onLongPress: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.grey,
                height: 10,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(userName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: signOut,
                    key: const ValueKey('logout_button'),
                    child: const Text(
                      "Odhlásit",
                      style: TextStyle(color: orangeColor),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.black, height: 1),
            //Scrollovací část
            Expanded(
              child: ListView(
                key: const ValueKey('bottom_navigation'),
                children: [
                  ListTile(
                    key: const ValueKey('menu_home'),
                    leading: const Icon(Icons.home, color: Colors.orange),
                    title: const Text("Přehled"),
                    onTap: () => onModalBottomSheetMenuTapped(HomeScreen.id),
                  ),
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "ZÁPASY",
                          style:
                          TextStyle(color: Colors.black54, fontSize: 14),
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
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          isTableTeamFromAppTeamUsable() ? appTeamApiModel!.team.currentTableTeam!.league.organization : "LIGA",
                          textAlign: TextAlign.left,
                          style: const TextStyle(color: Colors.black54, fontSize: 14),
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
                    title: isTableTeamFromAppTeamUsable() ? Text("Program ${appTeamApiModel!.team.currentTableTeam!.league.organization} zápasů") : const Text("Program zápasů"),
                    onTap: () => onModalBottomSheetMenuTapped(FootballFixturesScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_football_table'),
                    leading: const Icon(
                      Icons.scoreboard_rounded,
                      color: Colors.orange,
                    ),
                    title: isTableTeamFromAppTeamUsable() ? Text("${appTeamApiModel!.team.currentTableTeam!.league.organization} tabulka") : const Text("Ligová tabulka"),
                    onTap: () => onModalBottomSheetMenuTapped(FootballTableScreen.id),
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
                  ListTile(
                    key: const ValueKey('strava'),
                    leading: const Icon(
                      Icons.run_circle_outlined,
                      color: Colors.orange,
                    ),
                    title: const Text("Strava"),
                    onTap: () => onModalBottomSheetMenuTapped(StravaFootballMatchScreen.id),

                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
