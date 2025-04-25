import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/helper/shared_prefs_helper.dart';
import 'package:trus_app/features/mixin/string_controller_mixin.dart';
import 'package:trus_app/models/api/auth/registration/registration_setup.dart';

import '../../../../common/repository/exception/field_validation_exception.dart';
import '../../../../common/repository/exception/model/field_model.dart';
import '../../../../common/utils/field_validator.dart';
import '../../../../common/utils/utils.dart';
import '../../../../models/api/auth/user_api_model.dart';
import '../../repository/auth_repository.dart';
import '../widget/i_user_registration_key.dart';

final authRegistrationControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final globalVariablesController =
      ref.watch(globalVariablesControllerProvider);
  return AuthRegistrationController(
      authRepository: authRepository,
      globalVariablesController: globalVariablesController);
});

class AuthRegistrationController
    with StringControllerMixin
    implements IUserRegistrationKey {
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

  Future<bool> sendEmailAndPassword() async {
    String name = stringValues[nameKey()]!;
    String email = stringValues[emailKey()]!;
    String password = stringValues[passwordKey()]!;

    if (validateFields(email, password, name)) {
      try {
        bool result =
            await authRepository.signUpWithEmail(email, password, name);
        return result;
      } on FieldValidationException catch (e) {
        loadingController.add(false);
        setErrorFieldByFieldValidationException(e);
        return false;
      } catch (e, stack) {
        showGlobalErrorDialog(e, stack);
      }
    }
    return false;
  }

  Future<void> setErrorFieldByFieldValidationException(
      FieldValidationException e) async {
    await Future.delayed(Duration.zero, () {
      if (e.fields != null) {
        for (FieldModel fieldModel in e.fields!) {
          if (fieldModel.field != null) {
            if (fieldModel.field == "email") {
              print("nastavuju chybu");
              stringErrorTextControllers[emailKey()]!
                  .add(fieldModel.message ?? "test");
            }
            if (fieldModel.field == "password") {
              stringErrorTextControllers[passwordKey()]!
                  .add(fieldModel.message ?? "test");
            }
          }
        }
      }
    });
  }

  bool validateFields(String email, String password, String name) {
    String emailErrorText = validateEmptyField(email);
    String passwordErrorText = validateEmptyField(password);
    String nameErrorText = validateEmptyField(name);
    stringErrorTextControllers[emailKey()]!.add(emailErrorText);
    stringErrorTextControllers[passwordKey()]!.add(passwordErrorText);
    stringErrorTextControllers[nameKey()]!.add(nameErrorText);
    return emailErrorText.isEmpty &&
        passwordErrorText.isEmpty &&
        nameErrorText.isEmpty;
  }

  Future<bool> signUpWithEmail(
      String email, String password, String name) async {
    bool result = await authRepository.signUpWithEmail(email, password, name);
    return result;
  }

  Stream<bool> loading() {
    return loadingController.stream;
  }

  Stream<bool> loadingSuccess() {
    return loadingSuccessController.stream;
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
  String nameKey() {
    return "registration_name";
  }
}
