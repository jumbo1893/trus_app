import 'package:flutter/material.dart';
import 'package:trus_app/features/achievement/screens/achievement_screen.dart';
import 'package:trus_app/features/beer/screens/beer_simple_screen.dart';
import 'package:trus_app/features/fine/screens/fine_screen.dart';
import 'package:trus_app/features/football/screens/football_fixtures_screen.dart';
import 'package:trus_app/features/football/table/screens/football_table_screen.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/main/menu/widget/menu_section_label.dart';
import 'package:trus_app/features/main/menu/widget/menu_tile.dart';
import 'package:trus_app/features/match/screens/add_match_screen.dart';
import 'package:trus_app/features/match/screens/match_screen.dart';
import 'package:trus_app/features/player/screens/add_player_screen.dart';
import 'package:trus_app/features/player/screens/player_screen.dart';
import 'package:trus_app/features/season/screens/season_screen.dart';
import 'package:trus_app/features/strava/screens/strava_football_match_screen.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';

import '../../fine/match/screens/fine_match_screen.dart';
import 'app_menu_bottom_sheet.dart';

class BottomSheetNavigationManager {
  final BuildContext context;
  static const String deleteAccount = "DELETE_ACCOUNT";
  final AppTeamApiModel? appTeamApiModel;

  BottomSheetNavigationManager(this.context, this.appTeamApiModel);

  bool isTableTeamFromAppTeamUsable() {
    return appTeamApiModel != null &&
        appTeamApiModel!.team.currentTableTeam != null;
  }

  void showBottomSheetNavigation(
      Function(String) onModalBottomSheetMenuTapped,
      String userName,
      VoidCallback signOut,
      ) {
    AppMenuBottomSheet.show(
      context: context,
      title: 'Menu',
      children: [
        MenuTile(
          icon: Icons.home,
          title: const Text("Přehled"),
          onTap: () => onModalBottomSheetMenuTapped(HomeScreen.id),
        ),
        const MenuSectionLabel(text: "ZÁPASY"),
        MenuTile(
          icon: Icons.add,
          title: const Text("Přidat zápas"),
          onTap: () => onModalBottomSheetMenuTapped(AddMatchScreen.id),
        ),
        MenuTile(
          icon: Icons.list_outlined,
          title: const Text("Seznam zápasů"),
          onTap: () => onModalBottomSheetMenuTapped(MatchScreen.id),
        ),
        MenuSectionLabel(
          text: isTableTeamFromAppTeamUsable()
              ? appTeamApiModel!.team.currentTableTeam!.league.organization
              : "LIGA",
        ),
        MenuTile(
          icon: Icons.sports_soccer,
          title: isTableTeamFromAppTeamUsable()
              ? Text(
            "Program ${appTeamApiModel!.team.currentTableTeam!.league.organization} zápasů",
          )
              : const Text("Program zápasů"),
          onTap: () => onModalBottomSheetMenuTapped(
            FootballFixturesScreen.id,
          ),
        ),
        MenuTile(
          icon: Icons.scoreboard_rounded,
          title: isTableTeamFromAppTeamUsable()
              ? Text(
            "${appTeamApiModel!.team.currentTableTeam!.league.organization} tabulka",
          )
              : const Text("Ligová tabulka"),
          onTap: () => onModalBottomSheetMenuTapped(
            FootballTableScreen.id,
          ),
        ),
        const MenuSectionLabel(text: "HRÁČI"),
        MenuTile(
          icon: Icons.person_add,
          title: const Text("Přidat hráče"),
          onTap: () => onModalBottomSheetMenuTapped(AddPlayerScreen.id),
        ),
        MenuTile(
          icon: Icons.group,
          title: const Text("Seznam hráčů"),
          onTap: () => onModalBottomSheetMenuTapped(PlayerScreen.id),
        ),
        const MenuSectionLabel(text: "POKUTY"),
        MenuTile(
          icon: Icons.attach_money,
          title: const Text("Přidat/upravit pokutu"),
          onTap: () => onModalBottomSheetMenuTapped(FineScreen.id),
        ),
        MenuTile(
          icon: Icons.savings,
          title: const Text("Přidat pokutu v zápase"),
          onTap: () => onModalBottomSheetMenuTapped(FineMatchScreen.id),
        ),
        const MenuSectionLabel(text: "PIVA"),
        MenuTile(
          icon: Icons.sports_bar,
          title: const Text("Přidat pivo v zápase"),
          onTap: () => onModalBottomSheetMenuTapped(BeerSimpleScreen.id),
        ),
        const MenuSectionLabel(text: "STATISTIKY"),
        MenuTile(
          icon: Icons.star,
          title: const Text("Seznam achievementů"),
          onTap: () => onModalBottomSheetMenuTapped(AchievementScreen.id),
        ),
        const MenuSectionLabel(text: "NASTAVENÍ"),
        MenuTile(
          icon: Icons.edit_calendar,
          title: const Text("Nastavení sezon"),
          onTap: () => onModalBottomSheetMenuTapped(SeasonScreen.id),
        ),
        MenuTile(
          icon: Icons.run_circle_outlined,
          title: const Text("Strava"),
          onTap: () => onModalBottomSheetMenuTapped(
            StravaFootballMatchScreen.id,
          ),
        ),
      ],
    );
  }
}