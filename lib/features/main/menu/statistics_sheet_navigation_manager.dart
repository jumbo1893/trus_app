import 'package:flutter/material.dart';
import 'package:trus_app/features/football/screens/football_player_stats_screen.dart';
import 'package:trus_app/features/football/screens/football_stats_screen.dart';
import 'package:trus_app/features/main/menu/widget/menu_section_label.dart';
import 'package:trus_app/features/main/menu/widget/menu_tile.dart';
import 'package:trus_app/features/statistics/screens/beer/beer_detail_stats_screen.dart';
import 'package:trus_app/features/statistics/screens/beer/beer_match_statistic_screen.dart';
import 'package:trus_app/features/statistics/screens/beer/beer_player_statistic_screen.dart';
import 'package:trus_app/features/statistics/screens/fine/fine_match_statistic_screen.dart';
import 'package:trus_app/features/statistics/screens/fine/fine_player_statistic_screen.dart';
import 'package:trus_app/features/statistics/screens/goal/goal_match_statistic_screen.dart';
import 'package:trus_app/features/statistics/screens/goal/goal_player_statistic_screen.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';

import '../../statistics/screens/attendance/attendance_match_statistic_screen.dart';
import '../../statistics/screens/attendance/attendance_player_statistic_screen.dart';
import 'app_menu_bottom_sheet.dart';

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
    AppMenuBottomSheet.show(
      context: context,
      title: 'Statistiky',
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
        MenuTile(
          icon: Icons.groups_rounded,
          title: const Text("Účast hráčů na zápasech"),
          onTap: () => onModalBottomSheetMenuTapped(
            AttendancePlayerStatisticScreen.id,
          ),
        ),
        MenuTile(
          icon: Icons.event_available_rounded,
          title: const Text("Počet hráčů v zápasech"),
          onTap: () => onModalBottomSheetMenuTapped(
            AttendanceMatchStatisticScreen.id,
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
              : const Text("Statistiky z ligy"),
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
      ],
    );
  }
}