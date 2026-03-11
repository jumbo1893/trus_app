import 'package:flutter/material.dart';
import 'package:trus_app/features/footbar/screens/footbar_compare_screen.dart';
import 'package:trus_app/features/footbar/screens/footbar_connect_screen.dart';
import 'package:trus_app/features/footbar/screens/footbar_sync_screen.dart';
import 'package:trus_app/features/info/screens/info_screen.dart';
import 'package:trus_app/features/notification/push/screen/enabled_notifications_screen.dart';
import 'package:trus_app/features/user/screens/view_user_screen.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

import '../../colors.dart';
import '../player/screens/view_player_screen.dart';
import '../user/screens/user_screen.dart';

class UpperSheetNavigationManager {
  final BuildContext context;
  static const String deleteAccount = "DELETE_ACCOUNT";
  final AppTeamApiModel? appTeamApiModel;

  UpperSheetNavigationManager(this.context, this.appTeamApiModel);

  bool isTableTeamFromAppTeamUsable() {
    return appTeamApiModel != null &&
        appTeamApiModel!.team.currentTableTeam != null;
  }

  void showBottomSheetNavigation(
      Function(String) onModalBottomSheetMenuTapped,
      String userName,
      PlayerApiModel? getPlayerSelectedInUserProfile,
      VoidCallback signOut,
      Function(PlayerApiModel) onPlayerSelected) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            // 🔹 Ukotvená horní část
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              onLongPress: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.grey,
                height: 10,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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

            // 🔹 Scrollovací část
            Expanded(
              child: ListView(
                key: const ValueKey('bottom_navigation'),
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 20.0),
                    child: Text(
                      "PROFIL",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ),
                  ListTile(
                    key: const ValueKey('menu_notifications'),
                    leading: const Icon(Icons.home, color: Colors.orange),
                    title: const Text("Oznámení"),
                    onTap: () => onModalBottomSheetMenuTapped(
                        EnabledNotificationsScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_user_settings'),
                    leading: Icon(
                      Icons.account_box,
                      color: getPlayerSelectedInUserProfile != null
                          ? Colors.orange
                          : Colors.red,
                    ),
                    title: getPlayerSelectedInUserProfile != null
                        ? const Text("Můj profil")
                        : const Column(
                            children: [
                              Row(
                                children: [
                                  Text("Můj profil"),
                                  SizedBox()
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.red),
                                  Text(
                                    "  Je třeba se spárovat",
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                    onTap: () =>
                        onModalBottomSheetMenuTapped(ViewUserScreen.id),
                  ),
                  getPlayerProfileWListFile(getPlayerSelectedInUserProfile,
                      onPlayerSelected, onModalBottomSheetMenuTapped),
                  ListTile(
                    key: const ValueKey('menu_footbar_connect'),
                    leading: const Icon(Icons.private_connectivity_sharp, color: Colors.orange),
                    title: const Text("Připojení k Footbar"),
                    onTap: () => onModalBottomSheetMenuTapped(
                        FootbarConnectScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_footbar_sync'),
                    leading: const Icon(Icons.sync, color: Colors.orange),
                    title: const Text("Načtení Footbar statistik"),
                    onTap: () => onModalBottomSheetMenuTapped(
                        FootbarSyncScreen.id),
                  ),
                  ListTile(
                    key: const ValueKey('menu_footbar_sync'),
                    leading: const Icon(Icons.sync, color: Colors.orange),
                    title: const Text("Porovnání Footbar stats"),
                    onTap: () => onModalBottomSheetMenuTapped(
                        FootbarCompareScreen.id),
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
                    onTap: () =>
                        onModalBottomSheetMenuTapped(ViewUserScreen.id),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getPlayerProfileWListFile(
      PlayerApiModel? player,
      Function(PlayerApiModel) onPlayerSelected,
      Function(String) onModalBottomSheetMenuTapped) {
    if (player != null) {
      bool needToShowWarning = player.footballPlayer != null && !player.fan;
      return ListTile(
          key: const ValueKey('menu_view_player'),
          leading: Icon(
            Icons.person_rounded,
            color: needToShowWarning ? Colors.orange : Colors.red,
          ),
          title: needToShowWarning
              ? const Text("Hráčský profil/moje achievementy")
              : const Column(
                  children: [
                    Row(
                      children: [
                        Text("Hráčský profil/moje achievementy   "),
                        SizedBox()
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        Text(
                          "  Je třeba se spárovat s pkfl hráčem",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
          onTap: () => {
                onPlayerSelected(player),
                onModalBottomSheetMenuTapped(ViewPlayerScreen.id)
              });
    } else {
      return Container();
    }
  }
}
