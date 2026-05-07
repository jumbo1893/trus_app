import 'package:flutter/material.dart';
import 'package:trus_app/features/football/screens/football_stats_screen.dart';
import 'package:trus_app/features/main/menu/widget/animated_menu_extension.dart';
import 'package:trus_app/features/main/menu/widget/fade_slide_in.dart';
import 'package:trus_app/features/main/menu/widget/menu_section_label.dart';
import 'package:trus_app/features/main/menu/widget/menu_tile.dart';
import 'package:trus_app/features/statistics/screens/beer/beer_detail_stats_screen.dart';
import 'package:trus_app/features/statistics/screens/beer/beer_player_statistic_screen.dart';

import '../../../models/api/auth/app_team_api_model.dart';
import '../../../theme/app_colors.dart';
import '../../football/screens/football_player_stats_screen.dart';
import '../../statistics/screens/beer/beer_match_statistic_screen.dart';
import '../../statistics/screens/fine/fine_match_statistic_screen.dart';
import '../../statistics/screens/fine/fine_player_statistic_screen.dart';
import '../../statistics/screens/goal/goal_match_statistic_screen.dart';
import '../../statistics/screens/goal/goal_player_statistic_screen.dart';

class StatisticsSheetNavigationManager {
  final BuildContext context;
  final AppTeamApiModel? appTeamApiModel;

  StatisticsSheetNavigationManager(this.context, this.appTeamApiModel);

  bool isTableTeamFromAppTeamUsable() {
    return appTeamApiModel != null &&
        appTeamApiModel!.team.currentTableTeam != null;
  }

  void showBottomSheetNavigation(
    Function(String) onModalBottomSheetMenuTapped,
  ) {
    final appColors = context.appColors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: appColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.78,
          child: Column(
            children: [
              FadeSlideIn(
                duration: const Duration(milliseconds: 250),
                beginOffset: const Offset(0, 0.04),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),

              const FadeSlideIn(
                duration: Duration(milliseconds: 320),
                delay: Duration(milliseconds: 40),
                beginOffset: Offset(0, 0.05),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Statistiky',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20, top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MenuTile(
                        icon: Icons.sports_bar,
                        title: const Text("Statistiky piv hráče"),
                        onTap: () => onModalBottomSheetMenuTapped(
                          BeerPlayerStatisticScreen.id,
                        ),
                      ),
                      MenuTile(
                        icon: Icons.wine_bar,
                        title: const Text("Statistiky piv zápasu"),
                        onTap: () => onModalBottomSheetMenuTapped(
                          BeerMatchStatisticScreen.id,
                        ),
                      ),
                      MenuTile(
                        icon: Icons.attach_money,
                        title: const Text("Statistiky pokut hráče"),
                        onTap: () => onModalBottomSheetMenuTapped(
                          FinePlayerStatisticScreen.id,
                        ),
                      ),
                      MenuTile(
                        icon: Icons.savings,
                        title: const Text("Statistiky pokut v zápase"),
                        onTap: () => onModalBottomSheetMenuTapped(
                          FineMatchStatisticScreen.id,
                        ),
                      ),
                      MenuTile(
                        icon: Icons.sports,
                        title: const Text("Statistiky gólů hráče"),
                        onTap: () => onModalBottomSheetMenuTapped(
                          GoalPlayerStatisticScreen.id,
                        ),
                      ),
                      MenuTile(
                        icon: Icons.sports_soccer,
                        title: const Text("Statistiky gólů v zápase"),
                        onTap: () => onModalBottomSheetMenuTapped(
                          GoalMatchStatisticScreen.id,
                        ),
                      ),
                      const MenuSectionLabel(text: "ZBYTEČNÉ ZAJÍMAVOSTI"),
                      MenuTile(
                        icon: Icons.query_stats,
                        title: const Text("Detail piv"),
                        onTap: () => onModalBottomSheetMenuTapped(
                          BeerDetailStatsScreen.id,
                        ),
                      ),
                      MenuSectionLabel(
                        text:
                            "STATISTIKY Z ${isTableTeamFromAppTeamUsable() ? appTeamApiModel!.team.currentTableTeam!.league.organization : "LIGY"}",
                      ),
                      MenuTile(
                        icon: Icons.equalizer,
                        title: isTableTeamFromAppTeamUsable()
                            ? Text(
                                "Statistiky z ${appTeamApiModel!.team.currentTableTeam!.league.organization}",
                              )
                            : const Text("Statistiky z Ligy"),
                        onTap: () => onModalBottomSheetMenuTapped(
                          FootballStatsScreen.id,
                        ),
                      ),
                      MenuTile(
                        icon: Icons.stacked_bar_chart,
                        title: isTableTeamFromAppTeamUsable()
                            ? Text(
                                "Hráčské statistiky z ${appTeamApiModel!.team.currentTableTeam!.league.organization}",
                              )
                            : const Text("Hráčské statistiky z ligy"),
                        onTap: () => onModalBottomSheetMenuTapped(
                          FootballPlayerStatsScreen.id,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ].withStaggeredAnimation(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
