

import 'package:firebase_auth/firebase_auth.dart';

import '../../../common/repository/exception/internal_snackbar_exception.dart';
import '../../../common/repository/exception/login_exception.dart';
import '../../../common/repository/exception/server_exception.dart';
import '../../../common/utils/utils.dart';
import 'package:flutter/material.dart';

Future<T?> executeApi<T> (Future<T> Function() function, VoidCallback onDialogCancel, BuildContext context, bool loader) async {
  try {
    if(loader) {
      showLoaderSnackBar(context: context);
    }
    var returnValue = await function().whenComplete(() => hideSnackBar(context));
    return returnValue;
  } on FirebaseAuthException catch (e) {
    hideSnackBar(context);
    Future.delayed(Duration.zero, () =>  showSnackBarWithPostFrame(context: context, content: _returnFirebaseSnackBarError(e)));
  } on LoginException catch (e) {
    hideSnackBar(context);
    Future.delayed(Duration.zero, () =>  showSnackBarWithPostFrame(context: context, content: e.cause));
  } on ServerException catch (e) {
    hideSnackBar(context);
    Future.delayed(Duration.zero, () =>  showErrorDialog(e.cause, onDialogCancel, context,));
  } on InternalSnackBarException catch (e) {
    hideSnackBar(context);
    Future.delayed(
        Duration.zero, () => showSnackBarWithPostFrame(context: context, content: e.cause));
  }
  return null;
}

String _returnFirebaseSnackBarError(FirebaseAuthException e) {
  if (e.code == 'user-not-found') {
    return "uživatel nebyl nalezen!";
  } else if (e.code == 'wrong-password') {
    return "Zadal jsi špatné heslo!";
  }
  else if (e.code == 'invalid-email') {
    return "Email není ve správném formátu";
  }
  else if (e.code == 'user-disabled') {
    return "Uživatel je blokovanej, asi sis čárkoval víc než si měl vole";
  }
  else if (e.code == 'email-already-in-use') {
    return "Na tento mail se již někdo zaregistroval";
  }
  else if (e.code == 'operation-not-allowed') {
    return "Operace není povolena! Řekni adminovi co to je za klauni, že se nedá registrovat";
  }
  else if (e.code == 'weak-password') {
    return "Moc slabý heslo, zadej takový aby vyhovovalo googlu";
  }
  else {
    return e.message!;
  }
}