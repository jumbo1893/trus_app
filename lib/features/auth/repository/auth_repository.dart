import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';

import '../../../common/repository/exception/login_exception.dart';
import '../../../common/repository/exception/server_exception.dart';
import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../../models/api/user_api_model.dart';
import '../../general/repository/crud_api_service.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
      firestore: FirebaseFirestore.instance),
);

class AuthRepository extends CrudApiService {
  final FirebaseFirestore firestore;

  AuthRepository({required this.firestore});

  Future<UserApiModel?> fastLogin() async {
    UserApiModel userApiModel;
    try {
      userApiModel = await signInWithEmailToServer(
          auth.currentUser!.email!, auth.currentUser!.uid);
    } catch (e) {
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

  Future<List<UserApiModel>> getUsers() async {
    final decodedBody = await getModels<JsonAndHttpConverter>(authApi, null);
    return decodedBody.map((model) => model as UserApiModel).toList();
  }

  Future<UserApiModel> setUserWritePermissions(
      UserApiModel user, bool write) async {
    user.admin = write;
    final decodedBody = await editModel<JsonAndHttpConverter>(user, user.id!);
    return decodedBody as UserApiModel;
  }

  Future<bool> deleteAccount() async {
    bool firstSignOut = await deleteAccountFromServer();
    bool secondSignOut = await deleteAccountFromFirebase();
    return firstSignOut && secondSignOut;
  }

  Future<bool> deleteAccountFromFirebase() async {
    await auth.currentUser!.delete();
    return true;
  }

  Future<bool> deleteAccountFromServer() async {
    var url = Uri.parse("$serverUrl/$authApi/delete");
    return await executeDeleteRequest(url, (_) => true, jsonEncode(null));
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
    UserCredential credentials =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    return credentials.user!.uid;
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

  Future<bool> signUpWithEmail(String email, String password) async {
    String userId = await signUpWithEmailToFireBase(email, password);
    if (userId.isNotEmpty) {
      await signUpWithEmailToServer(
              email, auth.currentUser!.uid)
          .whenComplete(() async =>
              await signInWithEmailToFirebase(email, password).whenComplete(
                  () => signInWithEmailToServer(email, auth.currentUser!.uid)));
      return true;
    }
    return false;
  }

  Future<String> signUpWithEmailToFireBase(
      String email, String password) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!.uid;
  }

  Future<UserApiModel> signUpWithEmailToServer(
      String email, String password) async {
    var url = Uri.parse("$serverUrl/$authApi/create");
    UserApiModel user = UserApiModel(password: password, mail: email);
    final UserApiModel userApiModel = await executePostRequest(
        url,
        (dynamic json) => UserApiModel.fromJson(json),
        jsonEncode(user.toJson()));
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
    user.playerId = playerId;
    final UserApiModel userApiModel = await executePostRequest(
        url,
        (dynamic json) => UserApiModel.fromJson(json),
        jsonEncode(user.toJson()));
    return userApiModel;
  }

  Future<UserApiModel> setUserPlayerId(UserApiModel user, int playerId) async {
    user.playerId = playerId;
    final decodedBody = await editModel<JsonAndHttpConverter>(user, user.id!);
    return decodedBody as UserApiModel;
  }

  Future<bool> sendForgottenPassword(BuildContext context, String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      showSnackBarWithPostFrame(
          context: context,
          content:
              "Na mail $email, zaslán link pro reset hesla. Stojí tě to přesně jednu rundu");
    } on FirebaseAuthException catch (e) {
      showSnackBarError(context, e);
    }
    return false;
  }

  void signInAnonymously(BuildContext context) async {
    try {
      await auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      showSnackBarWithPostFrame(context: context, content: e.message!);
    }
  }

  void showSnackBarError(BuildContext context, FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      showSnackBarWithPostFrame(context: context, content: "uživatel nebyl nalezen!");
    } else if (e.code == 'wrong-password') {
      showSnackBarWithPostFrame(context: context, content: "zadal jsi špatné heslo!");
    } else if (e.code == 'invalid-email') {
      showSnackBarWithPostFrame(context: context, content: "email není ve správném formátu");
    } else if (e.code == 'user-disabled') {
      showSnackBarWithPostFrame(
          context: context,
          content:
              "uživatel je blokovanej, asi sis čárkoval víc než si měl vole");
    } else if (e.code == 'email-already-in-use') {
      showSnackBarWithPostFrame(
          context: context,
          content: "na tento mail se již někdo zaregistroval");
    } else if (e.code == 'operation-not-allowed') {
      showSnackBarWithPostFrame(
          context: context,
          content:
              "Operace není povolena! Řekni adminovi co to je za klauni, že se nedá registrovat");
    } else if (e.code == 'weak-password') {
      showSnackBarWithPostFrame(
          context: context,
          content: "Moc slabý heslo, zadej takový aby vyhovovalo googlu");
    } else {
      showSnackBarWithPostFrame(context: context, content: e.message!);
    }
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
