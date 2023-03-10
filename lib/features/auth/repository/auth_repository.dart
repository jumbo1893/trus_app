import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/user_model.dart';
import 'package:trus_app/config.dart';

import '../../../common/utils/firebase_exception.dart';

final authRepositoryProvider = Provider(
        (ref) => AuthRepository(
            auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance
        ),
);

class AuthRepository extends CustomFirebaseException {
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
    }
    return user;
  }

  String? getCurrentUserName() {
    return auth.currentUser?.displayName;
  }

  Stream<List<UserModel>> getUsers() {
    return firestore.collection(userTable).orderBy("name", descending: false).snapshots().map((event) {
      List<UserModel> users = [];
      for (var document in event.docs) {
        var user = UserModel.fromJson(document.data());
        users.add(user);
      }
      return users;
    });
  }

  Future<bool> setUserWritePermissions(BuildContext context, UserModel user, bool write) async {
    try {
      await firestore.collection(userTable).doc(user.id).update({"writePermission" : write});
      return true;
    } on FirebaseException catch(e) {
      if (!showSnackBarOnException(e.code, context)) {
        showSnackBar(
          context: context,
          content: e.message!,
        );
      }
    }
    return false;
  }

  Future<bool> signOut(BuildContext context) async {
    try {
      await auth.signOut();
      showSnackBar(context: context, content: "D??kujeme, p??ij??te zas");
      return true;
    } on FirebaseAuthException catch(e) {
      showSnackBarError(context, e);
    }
    return false;
  }

  Future<bool> signInWithEmail(BuildContext context, String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      showSnackBar(context: context, content: "v??tejte pane ${returnUserName()}, p??eji p????jemn?? pit??");
      return true;
    } on FirebaseAuthException catch(e) {
      showSnackBarError(context, e);
    }
    return false;
  }

  Future<bool> registerWithEmail(BuildContext context, String email, String password) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).whenComplete(() => auth.signInWithEmailAndPassword(email: email, password: password));
      return true;
    } on FirebaseAuthException catch (e) {
      showSnackBarError(context, e);
    }
    return false;
  }

  Future<bool> saveUserDataToFirebase(BuildContext context, String username) async {
    try {
      String id = auth.currentUser!.uid;
      var user = UserModel(name: username, id: id, writePermission: false, mail: returnUserMail(),);
      await auth.currentUser!.updateDisplayName(username);
      await firestore.collection(userTable).doc(id).set(user.toJson());
      showSnackBar(context: context, content: "v??tejte pane ${returnUserName()}, p??eji p????jemn?? pit??");
      return true;
    } on FirebaseAuthException catch (e) {
      showSnackBarError(context, e);
    }
    return false;
  }

  Future<bool> sendForgottenPassword(BuildContext context, String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      showSnackBar(context: context, content: "Na mail $email, zasl??n link pro reset hesla. Stoj?? t?? to p??esn?? jednu rundu");
    } on FirebaseAuthException catch(e) {
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
      showSnackBar(context: context, content: "u??ivatel nebyl nalezen!");
    } else if (e.code == 'wrong-password') {
      showSnackBar(context: context, content: "zadal jsi ??patn?? heslo!");
    }
    else if (e.code == 'invalid-email') {
      showSnackBar(context: context, content: "email nen?? ve spr??vn??m form??tu");
    }
    else if (e.code == 'user-disabled') {
      showSnackBar(context: context, content: "u??ivatel je blokovanej, asi sis ????rkoval v??c ne?? si m??l vole");
    }
    else if (e.code == 'email-already-in-use') {
      showSnackBar(context: context, content: "na tento mail se ji?? n??kdo zaregistroval");
    }
    else if (e.code == 'operation-not-allowed') {
      showSnackBar(context: context, content: "Operace nen?? povolena! ??ekni adminovi co to je za klauni, ??e se ned?? registrovat");
    }
    else if (e.code == 'weak-password') {
      showSnackBar(context: context, content: "Moc slab?? heslo, zadej takov?? aby vyhovovalo googlu");
    }
    else {
      showSnackBar(context: context, content: e.message!);
    }
  }

  String returnUserName() {
    return auth.currentUser?.displayName ?? "Nezn??m?? u??ivatel" ;
  }

  String returnUserMail() {
    return auth.currentUser?.email ?? "unknown" ;
  }

  String returnUserId() {
    return auth.currentUser?.uid ?? "unknown" ;
  }
}