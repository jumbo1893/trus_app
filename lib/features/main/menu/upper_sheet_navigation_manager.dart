import 'package:flutter/material.dart';
import 'package:trus_app/features/footbar/screens/footbar_compare_screen.dart';
import 'package:trus_app/features/footbar/screens/footbar_connect_screen.dart';
import 'package:trus_app/features/info/screens/info_screen.dart';
import 'package:trus_app/features/main/menu/widget/animated_menu_extension.dart';
import 'package:trus_app/features/notification/push/screen/enabled_notifications_screen.dart';
import 'package:trus_app/features/user/screens/view_user_screen.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/theme/app_colors.dart';

import '../../../colors.dart';
import '../../player/screens/view_player_screen.dart';
import '../../user/screens/user_screen.dart';
import 'widget/fade_slide_in.dart';
import 'widget/menu_section_label.dart';
import 'widget/menu_tile.dart';

class UpperSheetNavigationManager {
  final BuildContext context;
  static const String deleteAccount = "DELETE_ACCOUNT";
  final AppTeamApiModel? appTeamApiModel;

  UpperSheetNavigationManager(this.context, this.appTeamApiModel);

  void showBottomSheetNavigation(
    Function(String) onModalBottomSheetMenuTapped,
    String userName,
    PlayerApiModel? player,
    VoidCallback signOut,
    Function(PlayerApiModel) onPlayerSelected,
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

              FadeSlideIn(
                duration: const Duration(milliseconds: 320),
                delay: const Duration(milliseconds: 40),
                beginOffset: const Offset(0, 0.05),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Nastavení a navigace',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: signOut,
                        icon: const Icon(Icons.logout, color: orangeColor),
                        label: const Text(
                          "Odhlásit",
                          style: TextStyle(color: orangeColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 20, top: 6),
                  children: [
                    const MenuSectionLabel(text: "PROFIL"),
                    MenuTile(
                      icon: Icons.notifications,
                      title: const Text("Oznámení"),
                      onTap: () => onModalBottomSheetMenuTapped(
                        EnabledNotificationsScreen.id,
                      ),
                    ),
                    MenuTile(
                      icon: Icons.account_box,
                      iconColor: player != null ? appColors.accent : Colors.red,
                      title: player != null
                          ? const Text("Můj profil")
                          : const _WarningText(
                              main: "Můj profil",
                              sub: "Je třeba se spárovat",
                            ),
                      onTap: () =>
                          onModalBottomSheetMenuTapped(ViewUserScreen.id),
                    ),
                    if (player != null)
                      MenuTile(
                        icon: Icons.person,
                        title: const Text("Hráčský profil"),
                        onTap: () {
                          onPlayerSelected(player);
                          onModalBottomSheetMenuTapped(ViewPlayerScreen.id);
                        },
                      ),
                    const MenuSectionLabel(text: "FOOTBAR"),
                    MenuTile(
                      icon: Icons.link,
                      title: const Text("Připojení k Footbar"),
                      onTap: () =>
                          onModalBottomSheetMenuTapped(FootbarConnectScreen.id),
                    ),
                    MenuTile(
                      icon: Icons.compare_arrows,
                      title: const Text("Porovnání statistik"),
                      onTap: () =>
                          onModalBottomSheetMenuTapped(FootbarCompareScreen.id),
                    ),
                    const MenuSectionLabel(text: "NASTAVENÍ"),
                    MenuTile(
                      icon: Icons.info,
                      title: const Text("Informace o appce"),
                      onTap: () => onModalBottomSheetMenuTapped(InfoScreen.id),
                    ),
                    MenuTile(
                      icon: Icons.manage_accounts,
                      title: const Text("Správa uživatelů"),
                      onTap: () => onModalBottomSheetMenuTapped(UserScreen.id),
                    ),
                    MenuTile(
                      icon: Icons.delete_outline,
                      iconColor: Colors.red,
                      title: const Text("Smazat účet"),
                      onTap: () => onModalBottomSheetMenuTapped(deleteAccount),
                    ),
                    const SizedBox(height: 30)
                  ].withStaggeredAnimation(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WarningText extends StatelessWidget {
  final String main;
  final String sub;

  const _WarningText({required this.main, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(main),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 14),
            const SizedBox(width: 4),
            Text(sub, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
