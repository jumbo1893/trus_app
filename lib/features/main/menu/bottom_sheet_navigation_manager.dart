import 'package:flutter/material.dart';
import 'package:trus_app/features/ai/screens/ai_assistant_screen.dart';
import 'package:trus_app/features/achievement/screens/achievement_screen.dart';
import 'package:trus_app/features/beer/screens/beer_simple_screen.dart';
import 'package:trus_app/features/fine/screens/fine_screen.dart';
import 'package:trus_app/features/football/screens/football_fixtures_screen.dart';
import 'package:trus_app/features/football/table/screens/football_table_screen.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/main/menu/widget/menu_section_label.dart';
import 'package:trus_app/features/main/menu/widget/menu_tile.dart';

import 'package:trus_app/features/match/screens/match_screen.dart';
import 'package:trus_app/features/player/screens/add_player_screen.dart';
import 'package:trus_app/features/player/screens/player_screen.dart';
import 'package:trus_app/features/season/screens/season_screen.dart';
import 'package:trus_app/features/steps/screens/step_screen.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';

import '../../fine/match/screens/fine_match_screen.dart';
import 'app_menu_bottom_sheet.dart';

class BottomSheetNavigationManager {
  final BuildContext context;
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
      children: buildItems(onModalBottomSheetMenuTapped),
    );
  }

  List<Widget> buildItems(Function(String) onModalBottomSheetMenuTapped) => [
    MenuTile(
      icon: Icons.home,
      title: const Text("Přehled"),
      onTap: () => onModalBottomSheetMenuTapped(HomeScreen.id),
    ),
    MenuTile(
      icon: Icons.auto_awesome_rounded,
      iconWidget: const Text('💩', style: TextStyle(fontSize: 20)),
      title: const Text("TrusBot"),
      onTap: () => onModalBottomSheetMenuTapped(AiAssistantScreen.id),
    ),
    const MenuSectionLabel(text: "ZÁPASY"),
    MenuTile(
      icon: Icons.list_outlined,
      title: const Text("Týmové zápasy"),
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
              "Ligový program ${appTeamApiModel!.team.currentTableTeam!.league.organization} zápasů",
            )
          : const Text("Ligový program"),
      onTap: () => onModalBottomSheetMenuTapped(FootballFixturesScreen.id),
    ),
    MenuTile(
      icon: Icons.scoreboard_rounded,
      title: isTableTeamFromAppTeamUsable()
          ? Text(
              "${appTeamApiModel!.team.currentTableTeam!.league.organization} tabulka",
            )
          : const Text("Ligová tabulka"),
      onTap: () => onModalBottomSheetMenuTapped(FootballTableScreen.id),
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
      title: const Text("Sazebník pokut"),
      onTap: () => onModalBottomSheetMenuTapped(FineScreen.id),
    ),
    MenuTile(
      icon: Icons.savings,
      title: const Text("Zapsat pokuty"),
      onTap: () => onModalBottomSheetMenuTapped(FineMatchScreen.id),
    ),
    const MenuSectionLabel(text: "PIVA"),
    MenuTile(
      icon: Icons.sports_bar,
      title: const Text("Zapsat piva"),
      onTap: () => onModalBottomSheetMenuTapped(BeerSimpleScreen.id),
    ),
    const MenuSectionLabel(text: "STATISTIKY"),
    MenuTile(
      icon: Icons.star,
      title: const Text("Týmové úspěchy"),
      onTap: () => onModalBottomSheetMenuTapped(AchievementScreen.id),
    ),
    MenuTile(
      icon: Icons.directions_walk_rounded,
      title: const Text("Kroky"),
      onTap: () => onModalBottomSheetMenuTapped(StepScreen.id),
    ),
    const MenuSectionLabel(text: "NASTAVENÍ"),
    MenuTile(
      icon: Icons.edit_calendar,
      title: const Text("Nastavení sezon"),
      onTap: () => onModalBottomSheetMenuTapped(SeasonScreen.id),
    ),
  ];
}
