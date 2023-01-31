import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/user_model.dart';
import 'package:trus_app/config.dart';

final authRepositoryProvider = Provider(
        (ref) => AuthRepository(
            auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance
        ),
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({
      required this.auth,
      required this.firestore
  });

  Future<UserModel?> getCurrentUserData() async {
    var userData = await firestore.collection(userTable).doc(auth.currentUser?.uid).get();
    UserModel? user;
    if(userData.data() != null) {
      user = UserModel.fromJson(userData.data()!);
      print(user);
    }
    return user;
  }

  Future<bool> signInWithEmail(BuildContext context, String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      showSnackBar(context: context, content: "vítejte pane ${returnUserName()}, přeji příjemné pití");
    } on FirebaseAuthException catch(e) {
      showSnackBarError(context, e);
    }
    return false;
  }

  Future<bool> registerWithEmail(BuildContext context, String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      showSnackBarError(context, e);
    }
    return false;
  }

  Future<bool> saveUserDataToFirebase(BuildContext context, String username) async {
    try {
      String id = auth.currentUser!.uid;
      var user = UserModel(name: username, id: id, isOnline: true, mail: returnUserMail());
      await auth.currentUser!.updateDisplayName(username);
      await firestore.collection(userTable).doc(id).set(user.toJson());
      return true;
    } on FirebaseAuthException catch (e) {
      showSnackBarError(context, e);
    }
    return false;
  }


  /*void signWithPhoneNumber(BuildContext context, String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(phoneNumber: phoneNumber, verificationCompleted: (PhoneAuthCredential credential) async {
        auth.signInWithCredential(credential);
      },
          verificationFailed: (e) {
        throw Exception(e);
          }, codeSent: ((String verificationId, int? resendToken) async {

          }), codeAutoRetrievalTimeout: codeAutoRetrievalTimeout)
    } on FirebaseAuthException catch(e) {
      showSnackBar(context: context, content: e.message!);
    }
  }*/

  void signInAnonymously(BuildContext context) async {
    try {
      await auth.signInAnonymously();
    } on FirebaseAuthException catch(e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  void showSnackBarError(BuildContext context, FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      showSnackBar(context: context, content: "uživatel nebyl nalezen!");
    } else if (e.code == 'wrong-password') {
      showSnackBar(context: context, content: "zadal jsi špatné heslo!");
    }
    else if (e.code == 'invalid-email') {
      showSnackBar(context: context, content: "email není ve správném formátu");
    }
    else if (e.code == 'user-disabled') {
      showSnackBar(context: context, content: "uživatel je blokovanej, asi sis čárkoval víc než si měl vole");
    }
    else if (e.code == 'email-already-in-use') {
      showSnackBar(context: context, content: "na tento mail se již někdo zaregistroval");
    }
    else if (e.code == 'operation-not-allowed') {
      showSnackBar(context: context, content: "Operace není povolena! Řekni adminovi co to je za klauni, že se nedá registrovat");
    }
    else if (e.code == 'weak-password') {
      showSnackBar(context: context, content: "Moc slabý heslo, zadej takový aby vyhovovalo googlu");
    }
    else {
      showSnackBar(context: context, content: e.message!);
    }
  }

  String returnUserName() {
    return auth.currentUser?.displayName ?? "Neznámý uživatel" ;
  }

  String returnUserMail() {
    return auth.currentUser?.email ?? "unknown" ;
  }
}