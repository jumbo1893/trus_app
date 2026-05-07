import 'package:flutter/material.dart';
import 'package:trus_app/features/achievement/screens/achievement_screen.dart';
import 'package:trus_app/features/beer/screens/beer_simple_screen.dart';
import 'package:trus_app/features/fine/screens/fine_screen.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/main/menu/widget/animated_menu_extension.dart';
import 'package:trus_app/features/main/menu/widget/fade_slide_in.dart';
import 'package:trus_app/features/main/menu/widget/menu_section_label.dart';
import 'package:trus_app/features/main/menu/widget/menu_tile.dart';
import 'package:trus_app/features/match/screens/add_match_screen.dart';
import 'package:trus_app/features/player/screens/add_player_screen.dart';
import 'package:trus_app/features/player/screens/player_screen.dart';
import 'package:trus_app/features/season/screens/season_screen.dart';
import 'package:trus_app/features/strava/screens/strava_football_match_screen.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';

import '../../../theme/app_colors.dart';
import '../../fine/match/screens/fine_match_screen.dart';
import '../../football/screens/football_fixtures_screen.dart';
import '../../football/table/screens/football_table_screen.dart';
import '../../match/screens/match_screen.dart';
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
                              'Menu',
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
                        title: const Text("Seznam Zápasů"),
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
                        onTap: () => onModalBottomSheetMenuTapped(FootballFixturesScreen.id),
                      ),
                      MenuTile(
                        icon: Icons.scoreboard_rounded,
                        title: isTableTeamFromAppTeamUsable()
                            ? Text("${appTeamApiModel!.team.currentTableTeam!.league.organization} tabulka")
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
                        onTap: () => onModalBottomSheetMenuTapped(StravaFootballMatchScreen.id),
                      ),
                      const SizedBox(height: 30)
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
