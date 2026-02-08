import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:riverpod/riverpod.dart';
import 'package:trus_app/common/repository/exception/field_validation_exception.dart';
import 'package:trus_app/common/repository/exception/model/field_model.dart';
import 'package:trus_app/features/auth/app_team/screens/app_team_registration_screen.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/helper/shared_prefs_helper.dart';
import 'package:trus_app/features/mixin/string_controller_mixin.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/helper/bool_and_string.dart';

import '../../../../common/utils/field_validator.dart';
import '../../../../common/utils/utils.dart';
import '../../../../models/api/auth/user_api_model.dart';
import '../../../main/main_screen.dart';
import '../../repository/auth_repository.dart';
import '../../screens/user_information_screen.dart';
import '../screens/login_screen.dart';
import '../widget/i_user_login_key.dart';


final authLoginControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final globalVariablesController = ref.watch(globalVariablesControllerProvider);
  return AuthLoginController(authRepository: authRepository, globalVariablesController: globalVariablesController);
  });

final userDataAuthProvider = FutureProvider((ref) {
  final authController = ref.watch(authLoginControllerProvider);
  return authController.fastLogin();
});

class AuthLoginController with StringControllerMixin implements IUserLoginKey {
  final AuthRepository authRepository;
  final GlobalVariablesController globalVariablesController;
  late UserApiModel savedPrefUser;
  late UserApiModel loadedUser;
  final SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
  final loadingController = StreamController<bool>.broadcast();
  final loadingSuccessController = StreamController<bool>.broadcast();

  AuthLoginController({
    required this.authRepository,
    required this.globalVariablesController,
  });

  void loadUser() {
    initStringFields(savedPrefUser.mail!, emailKey());
    initStringFields(savedPrefUser.password!, passwordKey());
  }

  Future<void> loadLoginUser() async {
    await Future.delayed(Duration.zero, () => loadUser());
  }

  Future<void> setupUser() async {
    savedPrefUser = await _setupUser();
  }

  Future<UserApiModel> _setupUser() async {
    return await sharedPrefsHelper.getUserWithEmailAndPasswordOnly();
  }

  Future<LoginRedirect> sendEmailAndPassword() async {
    String email = stringValues[emailKey()]!.trim();
    String password = stringValues[passwordKey()]!.trim();
    loadingController.add(true);
    if (validateFields(email, password)) {
      try {
        UserApiModel? user = await signInWithEmail(email, password);

        if (user != null) {
          sharedPrefsHelper.setEmailAndPassword(email, password);
          loadedUser = user;
          loadingSuccessController.add(true);
        }
        else {
          loadingController.add(false);
          loadingSuccessController.add(false);
        }
        return chooseLoginRedirect(user);
      } on FieldValidationException catch (e) {
        loadingController.add(false);
        setErrorFieldByFieldValidationException(e);
        return LoginRedirect.needToLogin;
      } catch (e, stack) {
        loadingController.add(false);
        showGlobalErrorDialog(e, stack);
        return LoginRedirect.needToLogin;
      }

    }
    else {
      loadingController.add(false);
      return LoginRedirect.needToLogin;
    }
  }

  Future<void> setErrorFieldByFieldValidationException(FieldValidationException e) async {
    await Future.delayed(const Duration(milliseconds: 200), ()
    {
      if (e.fields != null) {
        for (FieldModel fieldModel in e.fields!) {
          if (fieldModel.field != null) {
            if (fieldModel.field == "email") {
              print("nastavuju chybu");
              stringErrorTextControllers[emailKey()]!.add(
                  fieldModel.message ?? "test");
            }
            if (fieldModel.field == "password") {
              stringErrorTextControllers[passwordKey()]!.add(
                  fieldModel.message ?? "test");
            }
          }
        }
      }
    });
  }

  Widget chooseScreenByLoginRedirect(LoginRedirect redirect) {
    switch(redirect) {
      case LoginRedirect.needToLogin:
        return const LoginScreen();
      case LoginRedirect.completeUserInformation:
        return const UserInformationScreen();
      case LoginRedirect.setAppTeam:
        return const AppTeamRegistrationScreen();
      case LoginRedirect.chooseAppTeam:
        return const LoginScreen();
      case LoginRedirect.ok:
        return const MainScreen();
      default:
        return const LoginScreen();
    }
  }

  Future<String> sendForgottenPassword() async {
    String email = stringValues[emailKey()]!.trim();
    if (validateFields(email, "password")) {
      BoolAndString successAndText = await getForgottenPassword(email);
      if(successAndText.boolean) {
        return successAndText.text;
      }
      stringErrorTextControllers[emailKey()]!.add(successAndText.text);
    }
    return "";
  }

  bool validateFields(String email, String password) {
    String emailErrorText = validateEmptyField(email);
    String passwordErrorText = validateEmptyField(password);
    stringErrorTextControllers[emailKey()]!.add(emailErrorText);
    stringErrorTextControllers[passwordKey()]!.add(passwordErrorText);
    return emailErrorText.isEmpty && passwordErrorText.isEmpty;
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

  Future<UserApiModel?> signInWithEmail(String email, String password) async {
    UserApiModel? result = await authRepository.signInWithEmail(email, password);
    if(result != null) {
    }
     return result;
  }

  Future<BoolAndString> getForgottenPassword(String email) async {
    BoolAndString result = await authRepository.sendForgottenPassword(email);
    return result;
  }

  void saveAppTeam(AppTeamApiModel appTeam) {
    globalVariablesController.setAppTeam(appTeam);
  }

  void saveSelectedPlayerApiModel(PlayerApiModel? playerApiModel) {
    globalVariablesController.setPlayerApiModel(playerApiModel);
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
    _savePreferencesBeforeLogin(user);
    return LoginRedirect.ok;
  }

  void _savePreferencesBeforeLogin(UserApiModel user) {
    saveAppTeam(user.teamRoles![0].appTeam); //TODO vybrat jaký tým
    saveSelectedPlayerApiModel(user.teamRoles![0].player);
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
    return "login_email";
  }

  @override
  String passwordKey() {
    return "login_password";
  }
}

enum LoginRedirect {
  needToLogin,
  completeUserInformation,
  ok,
  chooseAppTeam,
  setAppTeam,
}