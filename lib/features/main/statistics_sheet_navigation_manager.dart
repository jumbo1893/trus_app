import 'package:flutter/material.dart';
import 'package:trus_app/features/football/screens/football_stats_screen.dart';
import 'package:trus_app/features/statistics/screens/beer/beer_detail_stats_screen.dart';
import 'package:trus_app/features/statistics/screens/beer/beer_player_statistic_screen.dart';

import '../../models/api/auth/app_team_api_model.dart';
import '../football/screens/football_player_stats_screen.dart';
import '../statistics/screens/beer/beer_match_statistic_screen.dart';
import '../statistics/screens/fine/fine_match_statistic_screen.dart';
import '../statistics/screens/fine/fine_player_statistic_screen.dart';
import '../statistics/screens/goal/goal_match_statistic_screen.dart';
import '../statistics/screens/goal/goal_player_statistic_screen.dart';

class StatisticsSheetNavigationManager {
  final BuildContext context;
  final AppTeamApiModel? appTeamApiModel;

  StatisticsSheetNavigationManager(
    this.context,
    this.appTeamApiModel,
  );

  bool isTableTeamFromAppTeamUsable() {
    return appTeamApiModel != null &&
        appTeamApiModel!.team.currentTableTeam != null;
  }

  void showBottomSheetNavigation(
    Function(String) onModalBottomSheetMenuTapped,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              onLongPress: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.grey,
                height: 10,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text("Statistiky",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const Divider(color: Colors.black, height: 1),

            // 🔹 Scrollovací část
            Expanded(
              child: ListView(
                key: const ValueKey('bottom_navigation'),
                children: [
                  /*const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "STATISTIKY Z APPKY",
                          style:
                          TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),*/
                  ListTile(
                    key: const ValueKey('beer_player_stats'),
                    leading: const Icon(Icons.sports_bar, color: Colors.orange),
                    title: const Text("Statistiky piv hráče"),
                    onTap: () => onModalBottomSheetMenuTapped(
                        BeerPlayerStatisticScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('beer_match_stats'),
                    leading: const Icon(Icons.wine_bar, color: Colors.orange),
                    title: const Text("Statistiky piv zápasu"),
                    onTap: () => onModalBottomSheetMenuTapped(
                        BeerMatchStatisticScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('fine_player_stats'),
                    leading:
                        const Icon(Icons.attach_money, color: Colors.orange),
                    title: const Text("Statistiky pokut hráče"),
                    onTap: () => onModalBottomSheetMenuTapped(
                        FinePlayerStatisticScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('fine_match_stats'),
                    leading: const Icon(Icons.savings, color: Colors.orange),
                    title: const Text("Statistiky pokut v zápase"),
                    onTap: () => onModalBottomSheetMenuTapped(
                        FineMatchStatisticScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('goal_player_stats'),
                    leading: const Icon(Icons.sports, color: Colors.orange),
                    title: const Text("Statistiky gólů hráče"),
                    onTap: () => onModalBottomSheetMenuTapped(
                        GoalPlayerStatisticScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('goal_match_stats'),
                    leading:
                        const Icon(Icons.sports_soccer, color: Colors.orange),
                    title: const Text("Statistiky gólů v zápase"),
                    onTap: () => onModalBottomSheetMenuTapped(
                        GoalMatchStatisticScreen.id),
                  ),
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "ZBYTEČNÉ ZAJÍMAVOSTI",
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    key: const ValueKey('beer_detail'),
                    leading: const Icon(
                      Icons.query_stats,
                      color: Colors.orange,
                    ),
                    title: const Text("Detail piv"),
                    onTap: () =>
                        onModalBottomSheetMenuTapped(BeerDetailStatsScreen.id),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          "STATISTIKY Z ${isTableTeamFromAppTeamUsable() ? appTeamApiModel!.team.currentTableTeam!.league.organization : "LIGY"}",
                          style: const TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    key: const ValueKey('menu_football_stats'),
                    leading: const Icon(
                      Icons.equalizer,
                      color: Colors.orange,
                    ),
                    title: isTableTeamFromAppTeamUsable()
                        ? Text(
                            "Statistiky z ${appTeamApiModel!.team.currentTableTeam!.league.organization}")
                        : const Text("Statistiky z Ligy"),
                    onTap: () => onModalBottomSheetMenuTapped(
                        FootballStatsScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_football_player_stats'),
                    leading: const Icon(
                      Icons.stacked_bar_chart,
                      color: Colors.orange,
                    ),
                    title: isTableTeamFromAppTeamUsable()
                        ? Text(
                            "Hráčské statistiky z ${appTeamApiModel!.team.currentTableTeam!.league.organization}")
                        : const Text("Hráčské statistiky z ligy"),
                    onTap: () => onModalBottomSheetMenuTapped(
                        FootballPlayerStatsScreen.id),
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
