import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:trus_app/models/user_model.dart';

import '../repository/auth_repository.dart';

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
  });

final userDataAuthProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.getUserData();
});

class AuthController {
  final AuthRepository authRepository;

  AuthController({
    required this.authRepository,
  });

  Stream<List<UserModel>> users() {
    return authRepository.getUsers();
  }

  Future<bool> setWritePermissions(
      BuildContext context, UserModel user, bool write
      ) async {
    bool result = await authRepository.setUserWritePermissions(
        context, user, write);
    return result;
  }

  Future<UserModel?> getUserData() async {
    UserModel? user = await authRepository.getCurrentUserData();
    return user;
  }

  String? getCurrentUserName() {
    return authRepository.getCurrentUserName();
  }

  String getCurrentUserId() {
    return authRepository.returnUserId();
  }

  Future<bool> signInWithEmail(BuildContext context, String email, String password) async {
    bool result = await authRepository.signInWithEmail(context, email, password);
     return result;
  }

  Future<bool> sendForgottenPassword(BuildContext context, String email) async {
    bool result = await authRepository.sendForgottenPassword(context, email);
    return result;
  }

  Future<bool> registerWithEmail(BuildContext context, String email, String password) async {
    bool result = await authRepository.registerWithEmail(context, email, password);
    return result;
  }

  Future<bool> signOut(BuildContext context) async {
    bool result = await authRepository.signOut(context);
    return result;
  }

  Future<bool> saveUserDataToFirebase(BuildContext context, String username) async {
    bool result = await authRepository.saveUserDataToFirebase(context, username);
    return result;
  }
}