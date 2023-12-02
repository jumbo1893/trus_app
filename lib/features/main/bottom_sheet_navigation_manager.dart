import 'package:flutter/material.dart';

import '../../colors.dart';

class BottomSheetNavigationManager {
  final BuildContext context;


  BottomSheetNavigationManager(this.context);

  void showBottomSheetNavigation(Function(int) onModalBottomSheetMenuTapped, String userName, VoidCallback signOut) {
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
                          ))
                    )
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
                onTap: () => onModalBottomSheetMenuTapped(0),
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
                onTap: () => onModalBottomSheetMenuTapped(10),
              ),
              ListTile(
                key: const ValueKey('menu_match_list'),
                leading: const Icon(
                  Icons.list_outlined,
                  color: Colors.orange,
                ),
                title: const Text("Seznam zápasů"),
                onTap: () => onModalBottomSheetMenuTapped(9),
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
                onTap: () => onModalBottomSheetMenuTapped(19),
              ),
              ListTile(
                key: const ValueKey('menu_pkfl_table'),
                leading: const Icon(
                  Icons.scoreboard_rounded,
                  color: Colors.orange,
                ),
                title: const Text("PKFL tabulka"),
                onTap: () => onModalBottomSheetMenuTapped(21),
              ),
              ListTile(
                key: const ValueKey('menu_pkfl_stats'),
                leading: const Icon(
                  Icons.equalizer,
                  color: Colors.orange,
                ),
                title: const Text("Statistiky z PKFL"),
                onTap: () => onModalBottomSheetMenuTapped(20),
              ),
              ListTile(
                key: const ValueKey('menu_pkfl_player_stats'),
                leading: const Icon(
                  Icons.stacked_bar_chart,
                  color: Colors.orange,
                ),
                title: const Text("Hráčské statistiky z PKFL"),
                onTap: () => onModalBottomSheetMenuTapped(11),
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
                onTap: () => onModalBottomSheetMenuTapped(4),
              ),
              ListTile(
                key: const ValueKey('menu_player_list'),
                leading: const Icon(
                  Icons.group,
                  color: Colors.orange,
                ),
                title: const Text("Seznam hráčů"),
                onTap: () => onModalBottomSheetMenuTapped(18),
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
                onTap: () => onModalBottomSheetMenuTapped(12),
              ),
              ListTile(
                key: const ValueKey('menu_add_fine'),
                leading: const Icon(
                  Icons.savings,
                  color: Colors.orange,
                ),
                title: const Text("Přidat pokutu v zápase"),
                onTap: () => onModalBottomSheetMenuTapped(1),
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
                onTap: () => onModalBottomSheetMenuTapped(17),
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
                onTap: () => onModalBottomSheetMenuTapped(3),
              ),
              ListTile(
                key: const ValueKey('menu_goal_stats'),
                leading: const Icon(
                  Icons.query_stats,
                  color: Colors.orange,
                ),
                title: const Text("Statistiky gólů/asistencí"),
                onTap: () => onModalBottomSheetMenuTapped(22),
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
                onTap: () => onModalBottomSheetMenuTapped(26),
              ),
              ListTile(
                key: const ValueKey('menu_user_settings'),
                leading: const Icon(
                  Icons.manage_accounts,
                  color: Colors.orange,
                ),
                title: const Text("Nastavení uživatele"),
                onTap: () => onModalBottomSheetMenuTapped(24),
              ),
              ListTile(
                key: const ValueKey('menu_delete_account'),
                leading: const Icon(
                  Icons.no_accounts,
                  color: Colors.orange,
                ),
                title: const Text("Smazat účet"),
                onTap: () => onModalBottomSheetMenuTapped(-1),
              ),
              ListTile(
                key: const ValueKey('menu_season'),
                leading: const Icon(
                  Icons.edit_calendar,
                  color: Colors.orange,
                ),
                title: const Text("Nastavení sezon"),
                onTap: () => onModalBottomSheetMenuTapped(6),
              ),
            ],
          ),
        ));
  }
}
