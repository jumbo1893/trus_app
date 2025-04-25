import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:riverpod/riverpod.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/helper/shared_prefs_helper.dart';
import 'package:trus_app/features/mixin/boolean_controller_mixin.dart';
import 'package:trus_app/features/mixin/dropdown_controller_mixin.dart';
import 'package:trus_app/features/mixin/string_controller_mixin.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/auth/registration/league_with_teams.dart';
import 'package:trus_app/models/api/auth/registration/registration_setup.dart';
import 'package:trus_app/models/api/auth/registration/team_with_app_teams.dart';

import '../../../../models/api/auth/user_api_model.dart';
import '../../../../models/api/interfaces/dropdown_item.dart';
import '../../repository/auth_repository.dart';
import '../widget/i_user_app_team_registration_key.dart';


final authAppTeamRegistrationControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final globalVariablesController = ref.watch(globalVariablesControllerProvider);
  return AuthAppTeamRegistrationController(authRepository: authRepository, globalVariablesController: globalVariablesController);
  });

class AuthAppTeamRegistrationController with StringControllerMixin, DropdownControllerMixin, BooleanControllerMixin implements IUserAppTeamRegistrationKey {
  final AuthRepository authRepository;
  final GlobalVariablesController globalVariablesController;
  late UserApiModel loadedUser;
  late RegistrationSetup registrationSetup;
  final SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
  final loadingController = StreamController<bool>.broadcast();
  final loadingSuccessController = StreamController<bool>.broadcast();

  AuthAppTeamRegistrationController({
    required this.authRepository,
    required this.globalVariablesController,
  });

  void loadRegistration() {
    initBooleanFields(true, primaryTeamKey());
    initBooleanFields(false, newAppTeamKeyPicked());
    initStringFields("", newAppTeamKey());
    initDropdown(
        registrationSetup.primaryLeague, registrationSetup.leagueWithTeamsList, leagueKey());
    initDropdown(
        registrationSetup.primaryTeam, getTeams(registrationSetup.primaryLeague.id), teamKey());
    initDropdown(
        registrationSetup.primaryAppTeam, getAppTeams(registrationSetup.primaryTeam.id, dropdownLists[teamKey()] as List<TeamWithAppTeams>), appTeamKey());
  }

  @override
  void setDropdownItem(DropdownItem dropdownItem, String key) {
    dropdownControllers[key]!.add(dropdownItem);
    dropdownValues[key] = dropdownItem;
    if (key == leagueKey()) {
      final teams = getTeams((dropdownItem as LeagueWithTeams).id);
      setDropdownItemList(teams, teamKey());
      if (teams.isNotEmpty) {
        setDropdownItem(teams.first, teamKey());
      }
    }
    if (key == teamKey()) {
      final appTeams = getAppTeams((dropdownItem as TeamWithAppTeams).id, dropdownLists[teamKey()] as List<TeamWithAppTeams>);
      setDropdownItemList(appTeams, appTeamKey());
      if (appTeams.isNotEmpty) {
        setDropdownItem(appTeams.first, appTeamKey());
      }
    }
  }

  List<TeamWithAppTeams> getTeams(int leagueId) =>
      registrationSetup.leagueWithTeamsList
          .firstWhere((l) => l.id == leagueId)
          .teamWithAppTeamsList;

  List<AppTeamApiModel> getAppTeams(int teamId, List<TeamWithAppTeams> teams) =>
      teams.firstWhere((t) => t.id == teamId).appTeamList;

  bool isNeededToShowDropdownFields() {
    return boolValues[primaryTeamKey()] ?? false;
  }

  Future<void> loadRegistrationSetup() async {
    await Future.delayed(Duration.zero, () => loadRegistration());
  }

  Future<void> setupRegistration() async {
    registrationSetup = await _setupRegistration();
  }

  Future<RegistrationSetup> _setupRegistration() async {
    return await authRepository.setupRegistration();
  }

  Stream<bool> loading() {
    return loadingController.stream;
  }

  Stream<bool> loadingSuccess() {
    return loadingSuccessController.stream;
  }

  void saveAppTeam(AppTeamApiModel appTeam) {
    globalVariablesController.setAppTeam(appTeam);
  }

  Future<bool> setNewAppTeam() async {
    try {
      UserApiModel userApiModel;
      if (boolValues[primaryTeamKey()]!) {
        userApiModel = await authRepository.addUserToAppTeam(
            registrationSetup.primaryAppTeam.id);
      }
      else if (!boolValues[newAppTeamKeyPicked()]!) {
        userApiModel = await authRepository.addUserToAppTeam(
            (dropdownValues[appTeamKey()]! as AppTeamApiModel).id);
      }
      else {
        userApiModel = await authRepository.createNewAppTeam(
            (stringValues[newAppTeamKey()]!),
            (dropdownValues[teamKey()]! as TeamWithAppTeams).id);
      }
      saveAppTeam(userApiModel.teamRoles![0].appTeam);
      return true;
    }
    catch (e) {
      debugPrint(e.toString());
      return false;
    }

  }

  @override
  String appTeamKey() {
    return "registration_app_team";
  }

  @override
  String leagueKey() {
    return "registration_league";
  }

  @override
  String newAppTeamKey() {
    return "registration_new_app_team";
  }

  @override
  String teamKey() {
    return "registration_team";
  }

  @override
  String primaryTeamKey() {
    return "registration_primary_team";
  }

  @override
  String newAppTeamKeyPicked() {
    return "registration_new_app_team_picked";
  }
}