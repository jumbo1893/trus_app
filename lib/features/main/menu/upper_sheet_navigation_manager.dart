import 'package:flutter/material.dart';
import 'package:trus_app/features/appearance/screens/appearance_screen.dart';
import 'package:trus_app/features/footbar/screens/footbar_compare_screen.dart';
import 'package:trus_app/features/footbar/screens/footbar_connect_screen.dart';
import 'package:trus_app/features/info/screens/info_screen.dart';
import 'package:trus_app/features/main/menu/widget/menu_section_label.dart';
import 'package:trus_app/features/main/menu/widget/menu_tile.dart';
import 'package:trus_app/features/membership/widgets/membership_tier_badge.dart';
import 'package:trus_app/features/notification/push/screen/enabled_notifications_screen.dart';
import 'package:trus_app/features/player/screens/view_player_screen.dart';
import 'package:trus_app/features/user/screens/view_user_screen.dart';
import 'package:trus_app/features/team_administration/screens/team_administration_screen.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/theme/app_colors.dart';

import 'app_menu_bottom_sheet.dart';

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
    bool isTeamAdministrator,
  ) {
    final appColors = context.appColors;

    AppMenuBottomSheet.show(
      context: context,
      title: userName,
      titleBadge: const MembershipTierBadge(),
      subtitle: 'Nastavení a navigace',
      useListView: true,
      trailing: TextButton.icon(
        onPressed: signOut,
        icon: Icon(Icons.logout, color: appColors.legacyAccent),
        label: Text(
          "Odhlásit",
          style: TextStyle(color: appColors.legacyAccent),
        ),
      ),
      children: [
        const MenuSectionLabel(text: "PROFIL"),
        MenuTile(
          icon: Icons.notifications,
          title: const Text("Oznámení"),
          onTap: () =>
              onModalBottomSheetMenuTapped(EnabledNotificationsScreen.id),
        ),
        MenuTile(
          icon: Icons.account_box,
          iconColor: player != null ? appColors.accent : appColors.errorSolid,
          title: player != null
              ? const Text("Nastavení uživatele")
              : const _WarningText(
                  main: "Nastavení uživatele",
                  sub: "Je třeba se spárovat",
                ),
          onTap: () => onModalBottomSheetMenuTapped(ViewUserScreen.id),
        ),
        if (player != null)
          MenuTile(
            icon: Icons.person,
            title: const Text("Můj profil/seznam achievementů"),
            onTap: () {
              onPlayerSelected(player);
              onModalBottomSheetMenuTapped(ViewPlayerScreen.id);
            },
          ),
        const MenuSectionLabel(text: "FOOTBAR"),
        MenuTile(
          icon: Icons.link,
          title: const Text("Připojení k Footbar"),
          onTap: () => onModalBottomSheetMenuTapped(FootbarConnectScreen.id),
        ),
        MenuTile(
          icon: Icons.compare_arrows,
          title: const Text("Porovnání statistik"),
          onTap: () => onModalBottomSheetMenuTapped(FootbarCompareScreen.id),
        ),
        const MenuSectionLabel(text: "NASTAVENÍ"),
        MenuTile(
          icon: Icons.palette_outlined,
          title: const Text("Vzhled"),
          onTap: () => onModalBottomSheetMenuTapped(AppearanceScreen.id),
        ),
        MenuTile(
          icon: Icons.info,
          title: const Text("Informace o appce"),
          onTap: () => onModalBottomSheetMenuTapped(InfoScreen.id),
        ),
        if (isTeamAdministrator)
          MenuTile(
            icon: Icons.admin_panel_settings_outlined,
            title: const Text("Administrace týmu"),
            onTap: () =>
                onModalBottomSheetMenuTapped(TeamAdministrationScreen.id),
          ),
        MenuTile(
          icon: Icons.delete_outline,
          iconColor: appColors.errorSolid,
          title: const Text("Smazat účet"),
          onTap: () => onModalBottomSheetMenuTapped(deleteAccount),
        ),
      ],
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
            Icon(Icons.warning, color: context.appColors.errorSolid, size: 14),
            const SizedBox(width: 4),
            Text(
              sub,
              style: TextStyle(
                color: context.appColors.errorSolid,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
