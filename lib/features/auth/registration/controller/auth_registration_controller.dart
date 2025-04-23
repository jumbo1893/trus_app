import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/helper/SharedPrefsHelper.dart';
import 'package:trus_app/features/mixin/boolean_controller_mixin.dart';
import 'package:trus_app/features/mixin/dropdown_controller_mixin.dart';
import 'package:trus_app/features/mixin/string_controller_mixin.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/auth/registration/league_with_teams.dart';
import 'package:trus_app/models/api/auth/registration/registration_setup.dart';
import 'package:trus_app/models/api/auth/registration/team_with_app_teams.dart';

import '../../../../common/utils/field_validator.dart';
import '../../../../models/api/auth/user_api_model.dart';
import '../../../../models/api/interfaces/dropdown_item.dart';
import '../../repository/auth_repository.dart';
import '../widget/i_user_registration_key.dart';


final authRegistrationControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final globalVariablesController = ref.watch(globalVariablesControllerProvider);
  return AuthRegistrationController(authRepository: authRepository, globalVariablesController: globalVariablesController);
  });

class AuthRegistrationController with StringControllerMixin, DropdownControllerMixin, BooleanControllerMixin implements IUserRegistrationKey {
  final AuthRepository authRepository;
  final GlobalVariablesController globalVariablesController;
  late UserApiModel loadedUser;
  late RegistrationSetup registrationSetup;
  final SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
  final loadingController = StreamController<bool>.broadcast();
  final loadingSuccessController = StreamController<bool>.broadcast();

  AuthRegistrationController({
    required this.authRepository,
    required this.globalVariablesController,
  });

  void loadRegistration() {
    initStringFields("", emailKey());
    initStringFields("", passwordKey());
    initStringFields("", nameKey());
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

  Future<void> saveUserData(String username) async {
    await authRepository.editCurrentUser(false, username, null);
  }

  bool validateFields(String email, String password) {
    String emailErrorText = validateEmptyField(email);
    String passwordErrorText = validateEmptyField(password);
    stringErrorTextControllers[emailKey()]!.add(emailErrorText);
    stringErrorTextControllers[passwordKey()]!.add(passwordErrorText);
    return emailErrorText.isEmpty && passwordErrorText.isEmpty;
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    bool result = await authRepository.signUpWithEmail(email, password);
    return result;
  }

  Stream<bool> loading() {
    return loadingController.stream;
  }

  Stream<bool> loadingSuccess() {
    return loadingSuccessController.stream;
  }

  Future<LoginRedirect> fastLogin() async {
    UserApiModel? user = await authRepository.fastLogin();
    return chooseLoginRedirect(user);
  }

  void saveAppTeam(AppTeamApiModel appTeam) {
    globalVariablesController.setAppTeam(appTeam);
  }

  LoginRedirect chooseLoginRedirect(UserApiModel? user) {
    if(user == null) {
      return LoginRedirect.needToLogin;
    }
    else if (user.name == null || user.name!.isEmpty) {
      return LoginRedirect.completeUserInformation;
    }
    else if (isNeededToSetAppTeam(user)) {
      return LoginRedirect.setAppTeam;
    }
    else if (isNeededToChooseAppTeam(user)) {
      return LoginRedirect.chooseAppTeam;
    }
    saveAppTeam(user.teamRoles![0].appTeam);
    return LoginRedirect.ok;
  }

  bool isNeededToSetAppTeam(UserApiModel user) {
    if(user.teamRoles == null || user.teamRoles!.isEmpty) {
      return true;
    }
    return false;
  }

  bool isNeededToChooseAppTeam(UserApiModel user) {
    if(user.teamRoles!.length > 1) {
      return true;
    }
    return false;
  }

  @override
  String emailKey() {
    return "registration_email";
  }

  @override
  String passwordKey() {
    return "registration_password";
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
  String nameKey() {
    return "registration_name";
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

enum LoginRedirect {
  needToLogin,
  completeUserInformation,
  ok,
  chooseAppTeam,
  setAppTeam,
}