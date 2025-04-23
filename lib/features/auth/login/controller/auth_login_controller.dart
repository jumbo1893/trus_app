import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/helper/shared_prefs_helper.dart';
import 'package:trus_app/features/mixin/string_controller_mixin.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/helper/bool_and_string.dart';

import '../../../../common/utils/field_validator.dart';
import '../../../../models/api/auth/user_api_model.dart';
import '../../repository/auth_repository.dart';
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

  Future<void> sendEmailAndPassword() async {
    String email = stringValues[emailKey()]!.trim();
    String password = stringValues[passwordKey()]!.trim();
    loadingController.add(true);
    if (validateFields(email, password)) {
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
    }
    else {
      loadingController.add(false);
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