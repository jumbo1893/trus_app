import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/auth/controller/auth_controller.dart';
import 'package:trus_app/features/auth/repository/auth_repository.dart';
import 'package:trus_app/features/general/crud_operations.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/mixin/achievement_controller_mixin.dart';
import 'package:trus_app/features/mixin/boolean_controller_mixin.dart';
import 'package:trus_app/features/mixin/date_controller_mixin.dart';
import 'package:trus_app/features/mixin/string_controller_mixin.dart';
import 'package:trus_app/features/mixin/view_controller_mixin.dart';
import 'package:trus_app/features/user/widget/i_user_key.dart';
import 'package:trus_app/models/api/auth/user_api_model.dart';
import 'package:trus_app/models/api/auth/user_team_role_api_model.dart';

import '../../../common/repository/exception/internal_snackbar_exception.dart';
import '../../../common/utils/field_validator.dart';
import '../../../models/api/player/player_api_model.dart';
import '../../general/read_operations.dart';
import '../../mixin/dropdown_controller_mixin.dart';

final userControllerProvider = Provider((ref) {
  final authApiService = ref.watch(authRepositoryProvider);
  return UserController(authApiService: authApiService, ref: ref);
});

class UserController
    with
        DropdownControllerMixin,
        StringControllerMixin,
        DateControllerMixin,
        BooleanControllerMixin,
        ViewControllerMixin,
        AchievementControllerMixin
    implements CrudOperations, ReadOperations, IUserKey {
  final AuthRepository authApiService;
  final Ref ref;
  late UserApiModel userApiModel;

  UserController({
    required this.authApiService,
    required this.ref,
  });

  void loadViewUser() {
    int appTeamId = ref.read(globalVariablesControllerProvider).appTeam!.id;
    initViewFields(userApiModel.mail ?? "", emailKey());
    initViewFields(userApiModel.name ?? "", nameKey());
    initViewFields(
        getPlayerFromUserTeamRole(
            userApiModel.getCurrentUserTeamRole(appTeamId)),
        playerKey());
    initViewFields(
        getRoleFromUserTeamRole(userApiModel.getCurrentUserTeamRole(appTeamId)),
        roleKey());
    initViewFields(
        userApiModel.getDescriptionOfOtherRoles(appTeamId), otherRolesKey());
  }

  String getPlayerFromUserTeamRole(UserTeamRoleApiModel? teamRole) {
    if (teamRole == null) {
      return "";
    }
    return teamRole.playerToString();
  }

  String getRoleFromUserTeamRole(UserTeamRoleApiModel? teamRole) {
    if (teamRole == null) {
      return "";
    }
    return teamRole.roleToString();
  }

  Future<void> setupUser() async {
    userApiModel = await _setupUser();
  }

  Future<void> viewUser() async {
    Future.delayed(Duration.zero, () => loadViewUser());
  }

  bool validateFields() {
    String errorText = validateEmptyField(stringValues[nameKey()]!.trim());
    stringErrorTextControllers[nameKey()]!.add(errorText);
    return errorText.isEmpty;
  }

  Future<UserApiModel> _setupUser() async {
    final user = await authApiService.getCurrentUserData();
    if (user == null) {
      throw Exception("Uživatel nebyl načten.");
    }
    return user;
  }

  @override
  Future<PlayerApiModel?> addModel() async {
    return null;
  }

  @override
  Future<String> deleteModel(int id) async {
    final bool = await authApiService.deleteAccount();
    if (bool) {
      return "Účet smazán";
    }
    return "Chyba při smazání účtu";
  }

  Future<void> changeWritePermissions(
    BuildContext context,
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
    await authApiService.setUserWritePermissions(user.teamRoles![0].id!, newRole);
  }

  @override
  Future<String?> editModel(int id) async {
    return null;
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
}
