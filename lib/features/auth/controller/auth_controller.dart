import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:trus_app/features/general/read_operations.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/user_model.dart';

import '../../../common/repository/exception/internal_snackbar_exception.dart';
import '../../../models/api/user_api_model.dart';
import '../../general/crud_operations.dart';
import '../repository/auth_repository.dart';

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
  });

final userDataAuthProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.fastLogin();
});

class AuthController implements ReadOperations {
  final AuthRepository authRepository;

  AuthController({
    required this.authRepository,
  });

  Future<List<UserApiModel>> users() async {
    return await authRepository.getUsers();
  }

  Future<void> changeWritePermissions(
      BuildContext context, UserApiModel user,
      ) async {
    UserApiModel? currentUser = await getUserData();
    print(user);
    print(currentUser);
    if(user == await getUserData()) {

      throw InternalSnackBarException("Nemůžeš změnit práva sám sobě");
    }
    bool write = !user.admin!;
    await authRepository.setUserWritePermissions(user, write);
  }

  Future<UserApiModel?> getUserData() async {
    UserApiModel? user = await authRepository.getCurrentUserData();
    return user;
  }

  Future<UserApiModel?> fastLogin() async {
    UserApiModel? user = await authRepository.fastLogin();
    return user;
  }

  String? getCurrentUserName() {
    return authRepository.getCurrentUserName();
  }

  String getCurrentUserId() {
    return authRepository.returnUserId();
  }

  Future<UserApiModel?> signInWithEmail(String email, String password) async {
    UserApiModel? result = await authRepository.signInWithEmail(email, password);
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

  Future<void> saveUserData(String username) async {
    await authRepository.editCurrentUser(false, username);

  }

  @override
  Future<List<ModelToString>> getModels() async {
    return await authRepository.getUsers();
  }
}