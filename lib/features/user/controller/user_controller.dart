import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/auth/controller/auth_controller.dart';
import 'package:trus_app/features/auth/repository/auth_repository.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/mixin/string_controller_mixin.dart';
import 'package:trus_app/features/mixin/view_controller_mixin.dart';
import 'package:trus_app/features/user/widget/i_user_key.dart';
import 'package:trus_app/models/api/auth/user_api_model.dart';
import 'package:trus_app/models/api/auth/user_setup.dart';
import 'package:trus_app/models/api/auth/user_team_role_api_model.dart';
import 'package:trus_app/models/api/interfaces/confirm_to_string.dart';
import 'package:trus_app/models/api/interfaces/impl/confirm_to_string_impl.dart';

import '../../../common/repository/exception/internal_snackbar_exception.dart';
import '../../../common/utils/field_validator.dart';
import '../../../models/api/player/player_api_model.dart';
import '../../general/confirm_operations.dart';
import '../../general/read_operations.dart';
import '../../mixin/dropdown_controller_mixin.dart';

final userControllerProvider = Provider((ref) {
  final authApiService = ref.watch(authRepositoryProvider);
  return UserController(authApiService: authApiService, ref: ref);
});

class UserController
    with DropdownControllerMixin, StringControllerMixin, ViewControllerMixin
    implements ReadOperations, IUserKey, ConfirmOperations {
  final AuthRepository authApiService;
  final Ref ref;
  late UserSetup userSetup;

  UserController({
    required this.authApiService,
    required this.ref,
  });

  void loadViewUser() {
    int appTeamId = ref.read(globalVariablesControllerProvider).appTeam!.id;
    initViewFields(userSetup.currentUser.mail ?? "", emailKey());
    initViewFields(userSetup.currentUser.name ?? "", nameKey());
    initDropdown(userSetup.primaryPlayer, userSetup.eligiblePlayersToPairWith,
        playerKey());
    initViewFields(
        getRoleFromUserTeamRole(
            userSetup.currentUser.getCurrentUserTeamRole(appTeamId)),
        roleKey());
    initViewFields(userSetup.currentUser.getDescriptionOfOtherRoles(appTeamId),
        otherRolesKey());
  }

  PlayerApiModel? getPlayerFromUserTeamRole(UserTeamRoleApiModel? teamRole) {
    if (teamRole == null) {
      return null;
    }
    return teamRole.player;
  }

  String getRoleFromUserTeamRole(UserTeamRoleApiModel? teamRole) {
    if (teamRole == null) {
      return "";
    }
    return teamRole.roleToString();
  }

  Future<void> setupUser() async {
    userSetup = await _setupUser();
  }

  Future<void> viewUser() async {
    Future.delayed(Duration.zero, () => loadViewUser());
  }

  bool validateFields() {
    String errorText = validateEmptyField(stringValues[nameKey()]!.trim());
    stringErrorTextControllers[nameKey()]!.add(errorText);
    return errorText.isEmpty;
  }

  Future<UserSetup> _setupUser() async {
    final user = await authApiService.getUserSetup();
    return user;
  }

  Future<void> changeWritePermissions(
    UserApiModel user,
  ) async {
    if (user.teamRoles == null || user.teamRoles!.isEmpty) {
      throw InternalSnackBarException(
          "Tomuto uživateli nelze zadat práva, obrať se na admina");
    }
    if (user == await ref.read(authControllerProvider).getUserData()) {
      throw InternalSnackBarException("Nemůžeš změnit práva sám sobě");
    }
    String newRole = user.teamRoles![0].getOppositeRole();
    await authApiService.setUserWritePermissions(
        user.teamRoles![0].id!, newRole);
  }

  @override
  Future<List<UserApiModel>> getModels() async {
    return await authApiService.getUsers(true);
  }

  @override
  String emailKey() {
    return "user_email";
  }

  @override
  String otherRolesKey() {
    return "user_other_roles";
  }

  @override
  String playerKey() {
    return "user_player";
  }

  @override
  String roleKey() {
    return "user_role";
  }

  @override
  String nameKey() {
    return "user_name";
  }

  @override
  Future<ConfirmToString> addModel(int id) async {
    PlayerApiModel playerApiModel = dropdownValues[playerKey()] as PlayerApiModel;
    await authApiService
        .setUserPlayerId(dropdownValues[playerKey()] as PlayerApiModel);
    if(playerApiModel.id == 0) {
      ref.read(globalVariablesControllerProvider).setPlayerApiModel(null);
      return ConfirmToStringImpl("Z profilu odebrán hráč");
    }
    ref.read(globalVariablesControllerProvider).setPlayerApiModel(playerApiModel);
    return ConfirmToStringImpl("Do profilu přidán hráč ${playerApiModel.name}");
  }
}
