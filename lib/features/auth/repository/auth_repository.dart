import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/repository/exception/field_validation_exception.dart';
import 'package:trus_app/common/repository/exception/model/field_model.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/auth/registration/app_team_registration.dart';
import 'package:trus_app/models/api/auth/registration/registration_setup.dart';
import 'package:trus_app/models/api/auth/app_team_join_result.dart';
import 'package:trus_app/models/api/auth/user_setup.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/helper/bool_and_string.dart';

import '../../../common/repository/exception/login_exception.dart';
import '../../../common/repository/exception/server_exception.dart';
import '../../../models/api/auth/user_api_model.dart';
import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../general/repository/crud_api_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref: ref);
});

class AuthRepository extends CrudApiService {
  AuthRepository({required Ref ref}) : super(ref);

  Future<UserApiModel?> fastLogin() async {
    UserApiModel userApiModel;
    try {
      userApiModel = await getCurrentUserData();
    } catch (e) {
      debugPrint("Je nutné se znovu přihlásit ručně: $e");
      throw LoginException("Je nutné se projednou přihlásit ručně");
    }
    return userApiModel;
  }

  Future<UserApiModel> getCurrentUserData() async {
    var url = Uri.parse("$serverUrl/$authApi/auth");
    final UserApiModel userApiModel = await executeGetRequest(
      url,
      (dynamic json) => UserApiModel.fromJson(json),
      null,
    );
    return userApiModel;
  }

  Future<UserSetup> getUserSetup() async {
    var url = Uri.parse("$serverUrl/$authApi/setup");
    final UserSetup userSetup = await executeGetRequest(
      url,
      (dynamic json) => UserSetup.fromJson(json),
      null,
    );
    return userSetup;
  }

  String? getCurrentUserName() {
    return auth.currentUser?.displayName;
  }

  Future<List<UserApiModel>> getUsers(bool? appTeamTeamRolesOnly) async {
    Map<String, String?>? queryParameters;
    if (appTeamTeamRolesOnly != null) {
      queryParameters = {
        'appTeamTeamRolesOnly': appTeamTeamRolesOnly.toString(),
      };
    }
    final decodedBody = await getModels<JsonAndHttpConverter>(
      authApi,
      queryParameters,
    );
    return decodedBody.map((model) => model as UserApiModel).toList();
  }

  Future<void> setUserWritePermissions(int userRoleId, String role) async {
    var url = Uri.parse(
      "$serverUrl/$authApi/$userRoleId/role-change?role=$role",
    );
    return await executePutRequest(url, (_) {}, jsonEncode(null));
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
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> deleteAccountFromServer() async {
    var url = Uri.parse("$serverUrl/$authApi/delete");
    try {
      return await executeDeleteRequest(url, (_) => true, jsonEncode(null));
    } catch (e) {
      debugPrint(e.toString());
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
      UserApiModel user = await getCurrentUserData();
      return user;
    }
    return null;
  }

  Future<String> signInWithEmailToFirebase(
    String email,
    String password,
  ) async {
    try {
      UserCredential credentials = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credentials.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw convertFireBaseExceptionToFieldValidationException(e);
    }
  }

  Future<bool> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    User? firebaseUser = auth.currentUser;
    if (firebaseUser == null ||
        firebaseUser.email?.toLowerCase() != email.toLowerCase()) {
      String userId = await signUpWithEmailToFireBase(email, password);
      if (userId.isEmpty) {
        return false;
      }
      firebaseUser = auth.currentUser;
    }
    await firebaseUser!.updateDisplayName(name);
    await signUpWithEmailToServer(name);
    await getCurrentUserData();
    return true;
  }

  Future<String> signUpWithEmailToFireBase(
    String email,
    String password,
  ) async {
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

  Future<UserApiModel> signUpWithEmailToServer(String name) async {
    var url = Uri.parse("$serverUrl/$authApi/create");
    UserApiModel user = UserApiModel(name: name);
    final UserApiModel userApiModel = await executePostRequest(
      url,
      (dynamic json) => UserApiModel.fromJson(json),
      jsonEncode(user.toJson()),
    );
    return userApiModel;
  }

  Future<UserApiModel> createNewAppTeam(
    String name,
    int? footballTeamId,
  ) async {
    var url = Uri.parse("$serverUrl/$appTeamApi/create");
    AppTeamRegistration appTeamRegistration = AppTeamRegistration(
      name: name,
      footballTeamId: footballTeamId,
    );
    final UserApiModel userApiModel = await executePostRequest(
      url,
      (dynamic json) => UserApiModel.fromJson(json),
      jsonEncode(appTeamRegistration.toJson()),
    );
    return userApiModel;
  }

  Future<UserApiModel> joinPublicAppTeam() async {
    final url = Uri.parse("$serverUrl/$appTeamApi/join-public");
    return executePostRequest(
      url,
      (dynamic json) => UserApiModel.fromJson(json),
      jsonEncode(null),
    );
  }

  Future<AppTeamJoinResult> joinAppTeamByCode(String code) async {
    final url = Uri.parse("$serverUrl/$appTeamApi/join");
    return executePostRequest(
      url,
      (dynamic json) => AppTeamJoinResult.fromJson(json),
      jsonEncode({'code': code}),
    );
  }

  Future<UserApiModel> editCurrentUser(
    bool? admin,
    String? name,
    int? playerId,
  ) async {
    if (name != null) {
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
      jsonEncode(user.toJson()),
    );
    return userApiModel;
  }

  Future<void> setUserPlayerId(PlayerApiModel playerApiModel) async {
    var url = Uri.parse("$serverUrl/$authApi/player-add");
    await executePostRequest(url, (_) {}, jsonEncode(playerApiModel.toJson()));
  }

  Future<BoolAndString> sendForgottenPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return BoolAndString(
        true,
        "Na e-mail $email jsme poslali odkaz pro obnovení hesla.",
      );
    } on FirebaseAuthException catch (e) {
      return BoolAndString(false, convertFirebaseAuthExceptionToString(e));
    }
  }

  Future<RegistrationSetup> setupRegistration() async {
    const String url = "$serverUrl/$authApi/$registrationSetupApi/v2";
    final RegistrationSetup registrationSetup = await executeGetRequest(
      Uri.parse(url),
      (dynamic json) => RegistrationSetup.fromJson(json),
      null,
    );
    return registrationSetup;
  }

  FieldValidationException convertFireBaseExceptionToFieldValidationException(
    FirebaseAuthException e,
  ) {
    String emailField = "email";
    String passwordField = "password";
    List<FieldModel> fields = [];
    if (e.code == 'user-not-found') {
      FieldModel fieldModel = FieldModel(
        field: emailField,
        message: "Uživatel/email nebyl nalezen!",
      );
      fields.add(fieldModel);
    } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
      FieldModel fieldModel = FieldModel(
        field: passwordField,
        message: "E-mail nebo heslo není správně",
      );
      fields.add(fieldModel);
    } else if (e.code == 'invalid-email') {
      FieldModel fieldModel = FieldModel(
        field: emailField,
        message: "Email není ve správném formátu",
      );
      fields.add(fieldModel);
    } else if (e.code == 'user-disabled') {
      FieldModel fieldModel = FieldModel(
        field: emailField,
        message: "Účet je zablokovaný. Kontaktuj správce.",
      );
      fields.add(fieldModel);
    } else if (e.code == 'email-already-in-use') {
      FieldModel fieldModel = FieldModel(
        field: emailField,
        message: "Na tento mail se již někdo zaregistroval",
      );
      fields.add(fieldModel);
    } else if (e.code == 'operation-not-allowed') {
      FieldModel fieldModel = FieldModel(
        field: emailField,
        message: "Registrace nyní není dostupná. Kontaktuj správce.",
      );
      fields.add(fieldModel);
    } else if (e.code == 'weak-password') {
      FieldModel fieldModel = FieldModel(
        field: passwordField,
        message: "Heslo je příliš slabé",
      );
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
    } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
      return "E-mail nebo heslo není správně";
    } else if (e.code == 'invalid-email') {
      return "Email není ve správném formátu";
    } else if (e.code == 'user-disabled') {
      return "Účet je zablokovaný. Kontaktuj správce.";
    } else if (e.code == 'email-already-in-use') {
      return "Na tento mail se již někdo zaregistroval";
    } else if (e.code == 'operation-not-allowed') {
      return "Operace nyní není dostupná. Kontaktuj správce.";
    } else if (e.code == 'weak-password') {
      return "Heslo je příliš slabé";
    } else {
      return e.message!;
    }
  }

  void showSnackBarError(BuildContext context, FirebaseAuthException e) {
    showSnackBarWithPostFrame(
      context: context,
      content: convertFirebaseAuthExceptionToString(e),
    );
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
