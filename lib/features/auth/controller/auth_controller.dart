import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/general/read_operations.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../models/api/auth/user_api_model.dart';
import '../repository/auth_repository.dart';

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final globalVariablesController = ref.watch(globalVariablesControllerProvider);
  return AuthController(authRepository: authRepository, globalVariablesController: globalVariablesController);
  });

final userDataAuthProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.fastLogin();
});

class AuthController implements ReadOperations {
  final AuthRepository authRepository;
  final GlobalVariablesController globalVariablesController;

  AuthController({
    required this.authRepository,
    required this.globalVariablesController,
  });

  Future<List<UserApiModel>> users() async {
    return await authRepository.getUsers(null);
  }

  Future<UserApiModel?> getUserData() async {
    UserApiModel? user = await authRepository.getCurrentUserData();
    return user;
  }

  Future<LoginRedirect> fastLogin() async {
    UserApiModel? user = await authRepository.fastLogin();
    return chooseLoginRedirect(user);
  }

  String? getCurrentUserName() {
    return authRepository.getCurrentUserName();
  }

  String getCurrentUserId() {
    return authRepository.returnUserId();
  }

  Future<UserApiModel?> signInWithEmail(String email, String password) async {
    UserApiModel? result = await authRepository.signInWithEmail(email, password);
    if(result != null) {
    }
     return result;
  }

  Future<bool> sendForgottenPassword(BuildContext context, String email) async {
    bool result = await authRepository.sendForgottenPassword(context, email);
    return result;
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    bool result = await authRepository.signUpWithEmail(email, password);
    return result;
  }

  Future<bool> signOut() async {
    bool result = await authRepository.signOut();
    return result;
  }

  Future<void> deleteAccount() async {
    bool result = await authRepository.deleteAccount();
  }

  Future<void> saveUserData(String username) async {
    await authRepository.editCurrentUser(false, username, null);
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
    ///TO_DO
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
  Future<List<ModelToString>> getModels() async {
    return await authRepository.getUsers(null);
  }
}

enum LoginRedirect {
  needToLogin,
  completeUserInformation,
  ok,
  chooseAppTeam,
  setAppTeam,
}