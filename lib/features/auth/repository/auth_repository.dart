import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/repository/exception/field_validation_exception.dart';
import 'package:trus_app/common/repository/exception/model/field_model.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/auth/registration/app_team_registration.dart';
import 'package:trus_app/models/api/auth/registration/registration_setup.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/helper/bool_and_string.dart';

import '../../../common/repository/exception/login_exception.dart';
import '../../../common/repository/exception/server_exception.dart';
import '../../../models/api/auth/user_api_model.dart';
import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../general/repository/crud_api_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    firestore: FirebaseFirestore.instance,
    ref: ref,
  );
});

class AuthRepository extends CrudApiService {
  final FirebaseFirestore firestore;

  AuthRepository({
    required this.firestore,
    required Ref ref,
  }) : super(ref);

  Future<UserApiModel?> fastLogin() async {
    UserApiModel userApiModel;
    try {
      userApiModel = await signInWithEmailToServer(
          auth.currentUser!.email!, auth.currentUser!.uid);
    } catch (e) {
      print("Je nutné se projednou přihlásit ručně");
      throw LoginException("Je nutné se projednou přihlásit ručně");

    }
    return userApiModel;
  }

  Future<UserApiModel?> getCurrentUserData() async {
    var url = Uri.parse("$serverUrl/$authApi/auth");
    final UserApiModel userApiModel = await executeGetRequest(
        url, (dynamic json) => UserApiModel.fromJson(json), null);
    return userApiModel;
  }

  String? getCurrentUserName() {
    return auth.currentUser?.displayName;
  }

  Future<List<UserApiModel>> getUsers(bool? appTeamTeamRolesOnly) async {
    Map<String, String?>? queryParameters;
    if(appTeamTeamRolesOnly != null) {
      queryParameters = {
        'appTeamTeamRolesOnly': appTeamTeamRolesOnly.toString(),
      };
    }
    final decodedBody = await getModels<JsonAndHttpConverter>(authApi, queryParameters);
    return decodedBody.map((model) => model as UserApiModel).toList();
  }

  Future<void> setUserWritePermissions(
      int userRoleId, String role) async {
    var url = Uri.parse("$serverUrl/$authApi/$userRoleId/role-change?role=$role");
    return await executePutRequest(url, (_) => null, jsonEncode(null));
  }

  Future<bool> deleteAccount() async {
    bool firstSignOut = await deleteAccountFromServer();
    bool secondSignOut = await deleteAccountFromFirebase();
    return firstSignOut && secondSignOut;
  }

  Future<bool> deleteAccountFromFirebase() async {
    try {
      await auth.currentUser!.delete();
      return true;
    }
    catch (e) {
    print(e);
    return false;
    }
  }

  Future<bool> deleteAccountFromServer() async {
    var url = Uri.parse("$serverUrl/$authApi/delete");
    try {
      return await executeDeleteRequest(url, (_) => true, jsonEncode(null));
    }
    catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> signOut() async {
    bool firstSignOut = await signOutFromServer();
    bool secondSignOut = await signOutFromFirebase();
    return firstSignOut && secondSignOut;
  }

  Future<bool> signOutFromFirebase() async {
    await auth.signOut();
    return true;
  }

  Future<bool> signOutFromServer() async {
    var url = Uri.parse("$serverUrl/$authApi/auth");
    return await executeDeleteRequest(url, (_) => true, jsonEncode(null));
  }

  Future<UserApiModel?> signInWithEmail(String email, String password) async {
    String userId = await signInWithEmailToFirebase(email, password);
    if (userId.isNotEmpty) {
      UserApiModel user =
          await signInWithEmailToServer(email, auth.currentUser!.uid);
      return user;
    }
    return null;
  }

  Future<String> signInWithEmailToFirebase(
      String email, String password) async {
    try {
      UserCredential credentials =
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return credentials.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw convertFireBaseExceptionToFieldValidationException(e);
    }
  }

  Future<UserApiModel> signInWithEmailToServer(
      String email, String password) async {
    var url = Uri.parse("$serverUrl/$authApi/auth");
    UserApiModel user = UserApiModel(password: password, mail: email);
    final UserApiModel userApiModel = await executePostRequest(
        url,
        (dynamic json) => UserApiModel.fromJson(json),
        jsonEncode(user.toJson()));
    return userApiModel;
  }

  Future<bool> signUpWithEmail(String email, String password, String name) async {
    String userId = await signUpWithEmailToFireBase(email, password);
    if (userId.isNotEmpty) {
      await auth.currentUser!.updateDisplayName(name);
      try {
        await signUpWithEmailToServer(
            email, auth.currentUser!.uid, name);
        await signInWithEmailToFirebase(email, password);
        await signInWithEmailToServer(email, auth.currentUser!.uid);
      }
      catch (e) {
        deleteAccount();
        rethrow;
      }
      return true;
    }
    return false;
  }

  Future<String> signUpWithEmailToFireBase(
      String email, String password) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw convertFireBaseExceptionToFieldValidationException(e);
    }
  }

  Future<UserApiModel> signUpWithEmailToServer(
      String email, String password, String name) async {
    var url = Uri.parse("$serverUrl/$authApi/create");
    UserApiModel user = UserApiModel(password: password, mail: email, name: name);
    final UserApiModel userApiModel = await executePostRequest(
        url,
        (dynamic json) => UserApiModel.fromJson(json),
        jsonEncode(user.toJson()));
    return userApiModel;
  }

  Future<UserApiModel> createNewAppTeam(
      String name, int footballTeamId) async {
    var url = Uri.parse("$serverUrl/$appTeamApi/create");
    AppTeamRegistration appTeamRegistration = AppTeamRegistration(name: name, footballTeamId: footballTeamId);
    final UserApiModel userApiModel = await executePostRequest(
        url,
            (dynamic json) => UserApiModel.fromJson(json),
        jsonEncode(appTeamRegistration.toJson()));
    return userApiModel;
  }

  Future<UserApiModel> addUserToAppTeam(
      int appTeamId) async {
    var url = Uri.parse("$serverUrl/$appTeamApi/add");
    final UserApiModel userApiModel = await executePostRequest(
        url,
            (dynamic json) => UserApiModel.fromJson(json),
        jsonEncode(appTeamId));
    return userApiModel;
  }

  Future<UserApiModel> editCurrentUser(bool? admin, String? name, int? playerId) async {
    if(name != null) {
      await auth.currentUser!.updateDisplayName(name);
    }
    UserApiModel user = UserApiModel();
    var url = Uri.parse("$serverUrl/$authApi/update");
    user.admin = admin;
    user.name = name;
    //user.playerId = playerId;
    final UserApiModel userApiModel = await executePostRequest(
        url,
        (dynamic json) => UserApiModel.fromJson(json),
        jsonEncode(user.toJson()));
    return userApiModel;
  }

  Future<void> setUserPlayerId(PlayerApiModel playerApiModel) async {
    var url = Uri.parse("$serverUrl/$authApi/player-add");
    await executePostRequest(
        url,
            (_) => null,
        jsonEncode(playerApiModel.toJson()));
  }

  Future<BoolAndString> sendForgottenPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return BoolAndString(true, "Na mail $email byl zaslán link pro reset hesla. Stojí tě to přesně jednu rundu");

    } on FirebaseAuthException catch (e) {
      return BoolAndString(false, convertFirebaseAuthExceptionToString(e));
    }
  }

  Future<RegistrationSetup> setupRegistration() async {
    const String url = "$serverUrl/$authApi/$registrationSetupApi";
    final RegistrationSetup registrationSetup = await executeGetRequest(
        Uri.parse(url), (dynamic json) => RegistrationSetup.fromJson(json), null);
    return registrationSetup;
  }

  FieldValidationException convertFireBaseExceptionToFieldValidationException(FirebaseAuthException e) {
    String emailField = "email";
    String passwordField = "password";
    List<FieldModel> fields = [];
    if (e.code == 'user-not-found') {
      FieldModel fieldModel = FieldModel(field: emailField, message: "Uživatel/email nebyl nalezen!");
      fields.add(fieldModel);
    } else if (e.code == 'wrong-password') {
      FieldModel fieldModel = FieldModel(field: passwordField, message: "Špatné heslo!");
      fields.add(fieldModel);
    } else if (e.code == 'invalid-email') {
      FieldModel fieldModel = FieldModel(field: emailField, message: "Email není ve správném formátu");
      fields.add(fieldModel);
    } else if (e.code == 'user-disabled') {
      FieldModel fieldModel = FieldModel(field: emailField, message: "Uživatel je blokovanej, asi sis čárkoval víc než si měl vole");
      fields.add(fieldModel);
    } else if (e.code == 'email-already-in-use') {
      FieldModel fieldModel = FieldModel(field: emailField, message: "Na tento mail se již někdo zaregistroval");
      fields.add(fieldModel);
    } else if (e.code == 'operation-not-allowed') {
      FieldModel fieldModel = FieldModel(field: emailField, message: "Operace není povolena! Řekni adminovi co to je za klauni, že se nedá registrovat");
      fields.add(fieldModel);
    } else if (e.code == 'weak-password') {
      FieldModel fieldModel = FieldModel(field: passwordField, message: "Moc slabý heslo, zadej takový aby vyhovovalo googlu");
      fields.add(fieldModel);
    } else {
      FieldModel fieldModel = FieldModel(field: emailField, message: e.message);
      fields.add(fieldModel);
    }
    return FieldValidationException(fields);
  }

  String convertFirebaseAuthExceptionToString(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      return "Uživatel/email nebyl nalezen!";
    } else if (e.code == 'wrong-password') {
      return "Zadal jsi špatné heslo!";
    } else if (e.code == 'invalid-email') {
      return "Email není ve správném formátu";
    } else if (e.code == 'user-disabled') {
      return "Uživatel je blokovanej, asi sis čárkoval víc než si měl vole";
    } else if (e.code == 'email-already-in-use') {
      return "Na tento mail se již někdo zaregistroval";
    } else if (e.code == 'operation-not-allowed') {
      return "Operace není povolena! Řekni adminovi co to je za klauni, že se nedá registrovat";
    } else if (e.code == 'weak-password') {
      return "Moc slabý heslo, zadej takový aby vyhovovalo googlu";
    } else {
      return e.message!;
    }
  }

  void showSnackBarError(BuildContext context, FirebaseAuthException e) {
    showSnackBarWithPostFrame(context: context, content: convertFirebaseAuthExceptionToString(e));
  }

  void showSnackBarServerError(BuildContext context, ServerException e) {
    showSnackBarWithPostFrame(context: context, content: e.cause);
  }

  String returnUserName() {
    return auth.currentUser?.displayName ?? "Neznámý uživatel";
  }

  String returnUserMail() {
    return auth.currentUser?.email ?? "unknown";
  }

  String returnUserId() {
    return auth.currentUser?.uid ?? "unknown";
  }
}
