import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:trus_app/common/repository/exception/field_validation_exception.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/general/notifier/global_variables_notifier.dart';
import 'package:trus_app/features/mixin/boolean_controller_mixin.dart';
import 'package:trus_app/features/mixin/dropdown_controller_mixin.dart';
import 'package:trus_app/features/mixin/string_controller_mixin.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/auth/app_team_join_result.dart';
import 'package:trus_app/models/api/auth/registration/league_with_teams.dart';
import 'package:trus_app/models/api/auth/registration/registration_setup.dart';
import 'package:trus_app/models/api/auth/registration/team_with_app_teams.dart';
import 'package:trus_app/models/api/auth/user_api_model.dart';
import 'package:trus_app/models/api/interfaces/dropdown_item.dart';

import '../../repository/auth_repository.dart';
import '../widget/i_user_app_team_registration_key.dart';

final authAppTeamRegistrationControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final globalVariablesController = ref.watch(
    globalVariablesControllerProvider,
  );
  return AuthAppTeamRegistrationController(
    authRepository: authRepository,
    globalVariablesController: globalVariablesController,
    globalVariablesNotifier: ref.read(globalVariablesProvider.notifier),
  );
});

enum TeamOnboardingChoice { lisciTrus, joinExisting, createNew }

class AuthAppTeamRegistrationController
    with StringControllerMixin, DropdownControllerMixin, BooleanControllerMixin
    implements IUserAppTeamRegistrationKey {
  final AuthRepository authRepository;
  final GlobalVariablesController globalVariablesController;
  final GlobalVariablesNotifier globalVariablesNotifier;
  late RegistrationSetup registrationSetup;

  final loadingController = StreamController<bool>.broadcast();
  final loadingSuccessController = StreamController<bool>.broadcast();
  final _choiceController = StreamController<TeamOnboardingChoice>.broadcast();
  bool _initialized = false;

  TeamOnboardingChoice selectedChoice = TeamOnboardingChoice.lisciTrus;

  AuthAppTeamRegistrationController({
    required this.authRepository,
    required this.globalVariablesController,
    required this.globalVariablesNotifier,
  });

  void loadRegistration() {
    if (_initialized) {
      return;
    }
    initBooleanFields(false, linkFootballTeamKey());
    initStringFields('', newAppTeamKey());
    initStringFields('', joinCodeKey());

    final leagues = registrationSetup.leagueWithTeamsList
        .where((league) => league.teamWithAppTeamsList.isNotEmpty)
        .toList();
    final primaryLeagueId = registrationSetup.primaryLeague?.id;
    final LeagueWithTeams? initialLeague = leagues.isEmpty
        ? null
        : leagues.firstWhere(
            (league) => league.id == primaryLeagueId,
            orElse: () => leagues.first,
          );
    initDropdown(initialLeague, leagues, leagueKey());

    final teams = initialLeague?.teamWithAppTeamsList ?? <TeamWithAppTeams>[];
    final TeamWithAppTeams? initialTeam = teams.isEmpty
        ? null
        : teams.any((team) => team.id == registrationSetup.primaryTeam?.id)
        ? teams.firstWhere(
            (team) => team.id == registrationSetup.primaryTeam!.id,
          )
        : teams.first;
    initDropdown(initialTeam, teams, teamKey());

    final appTeams = registrationSetup.appTeamList;
    final AppTeamApiModel initialAppTeam = appTeams.firstWhere(
      (team) => team.id == registrationSetup.primaryAppTeam.id,
      orElse: () => appTeams.first,
    );
    initDropdown(initialAppTeam, appTeams, appTeamKey());
    _initialized = true;
  }

  Stream<TeamOnboardingChoice> choice() => _choiceController.stream;

  void setChoice(TeamOnboardingChoice choice) {
    selectedChoice = choice;
    _choiceController.add(choice);
  }

  bool get canLinkFootballTeam => registrationSetup.leagueWithTeamsList.any(
    (league) => league.teamWithAppTeamsList.isNotEmpty,
  );

  @override
  void setDropdownItem(DropdownItem dropdownItem, String key) {
    dropdownControllers[key]!.add(dropdownItem);
    dropdownValues[key] = dropdownItem;
    if (key == leagueKey()) {
      final teams = (dropdownItem as LeagueWithTeams).teamWithAppTeamsList;
      setDropdownItemList(teams, teamKey());
      if (teams.isNotEmpty) {
        setDropdownItem(teams.first, teamKey());
      }
    }
  }

  Future<void> loadRegistrationSetup() async {
    await Future.delayed(Duration.zero, loadRegistration);
  }

  Future<void> setupRegistration() async {
    registrationSetup = await authRepository.setupRegistration();
  }

  Stream<bool> loading() => loadingController.stream;

  Stream<bool> loadingSuccess() => loadingSuccessController.stream;

  Future<bool> completeRegistration() async {
    if (!_validateChoice()) {
      return false;
    }
    loadingController.add(true);
    try {
      late UserApiModel user;
      late int selectedAppTeamId;

      switch (selectedChoice) {
        case TeamOnboardingChoice.lisciTrus:
          selectedAppTeamId = registrationSetup.primaryAppTeam.id;
          user = await authRepository.joinPublicAppTeam();
          break;
        case TeamOnboardingChoice.joinExisting:
          final code = (stringValues[joinCodeKey()] ?? '').trim();
          final AppTeamJoinResult result = await authRepository
              .joinAppTeamByCode(code);
          selectedAppTeamId = result.appTeamId;
          user = result.user;
          break;
        case TeamOnboardingChoice.createNew:
          final name = (stringValues[newAppTeamKey()] ?? '').trim();
          final shouldLink = boolValues[linkFootballTeamKey()] ?? false;
          final selectedFootballTeam =
              dropdownValues[teamKey()] as TeamWithAppTeams?;
          user = await authRepository.createNewAppTeam(
            name,
            shouldLink ? selectedFootballTeam!.id : null,
          );
          selectedAppTeamId = user.teamRoles!
              .firstWhere((role) => role.appTeam.name == name)
              .appTeam
              .id;
          break;
      }

      final selectedRole = user.teamRoles!.firstWhere(
        (role) => role.appTeam.id == selectedAppTeamId,
      );
      globalVariablesController.setAppTeam(selectedRole.appTeam);
      globalVariablesNotifier.setAppTeam(selectedRole.appTeam);
      loadingSuccessController.add(true);
      return true;
    } on FieldValidationException catch (error) {
      for (final field in error.fields ?? const []) {
        if (field.field == 'appTeamName') {
          stringErrorTextControllers[newAppTeamKey()]!.add(
            field.message ?? 'Tento název nelze použít',
          );
        } else if (field.field == 'joinCode') {
          stringErrorTextControllers[joinCodeKey()]!.add(
            field.message ?? 'Tento kód není platný',
          );
        }
      }
      loadingController.add(false);
      return false;
    } catch (error, stackTrace) {
      debugPrint('$error\n$stackTrace');
      loadingController.add(false);
      return false;
    }
  }

  bool _validateChoice() {
    if (selectedChoice == TeamOnboardingChoice.joinExisting) {
      final code = (stringValues[joinCodeKey()] ?? '').trim();
      if (code.isEmpty) {
        stringErrorTextControllers[joinCodeKey()]!.add(
          'Zadej kód, který ti poslal administrátor týmu',
        );
        return false;
      }
    }
    if (selectedChoice != TeamOnboardingChoice.createNew) {
      return true;
    }

    final name = (stringValues[newAppTeamKey()] ?? '').trim();
    if (name.isEmpty) {
      stringErrorTextControllers[newAppTeamKey()]!.add('Vyplň název týmu');
      return false;
    }
    final shouldLink = boolValues[linkFootballTeamKey()] ?? false;
    if (shouldLink && dropdownValues[teamKey()] == null) {
      stringErrorTextControllers[newAppTeamKey()]!.add(
        'Vyber tým z ligy, nebo propojení vypni',
      );
      return false;
    }
    return true;
  }

  @override
  String appTeamKey() => 'registration_app_team';

  @override
  String joinCodeKey() => 'registration_join_code';

  @override
  String leagueKey() => 'registration_league';

  @override
  String newAppTeamKey() => 'registration_new_app_team';

  @override
  String teamKey() => 'registration_team';

  @override
  String linkFootballTeamKey() => 'registration_link_football_team';
}
