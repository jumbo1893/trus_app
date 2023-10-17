import 'package:firebase_auth/firebase_auth.dart';

import '../login_exception.dart';
import '../server_exception.dart';


  String returnExceptionError(Object e) {
    if(e is FirebaseAuthException) {
      return returnFirebaseSnackBarError(e);
    }
    else if(e is LoginException) {
      return e.cause;
    }
    else if(e is ServerException) {
      return e.cause;
    }
    return "Neznámá chyba";
  }

  String returnFirebaseSnackBarError(FirebaseAuthException e) {
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
    else if (e.code == 'invalid-credential') {
      return "Zadal jsi špatné jméno nebo heslo!";
    }
    else {
      return e.message!;
    }
}