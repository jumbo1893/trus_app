import 'package:firebase_auth/firebase_auth.dart';

import '../../../common/repository/exception/field_validation_exception.dart';
import '../../../common/repository/exception/internal_snackbar_exception.dart';
import '../../../common/repository/exception/login_exception.dart';
import '../../../common/repository/exception/server_exception.dart';
import 'api_result.dart';

mixin ApiExecutorMixin {

  Future<ApiResult<T>> executeApi<T>(
      Future<T> Function() function,
      ) async {
    try {
      final result = await function();
      return ApiSuccess(result);
    } on FieldValidationException catch (e) {
      final Map<String, String> errors = {};

      if (e.fields != null) {
        for (final field in e.fields!) {
          if (field.field != null && field.message != null) {
            errors[field.field!] = field.message!;
          }
        }
      }

      return ApiFieldError(errors);
    } on FirebaseAuthException catch (e) {
      return ApiError(_returnFirebaseSnackBarError(e));
    } on LoginException catch (e) {
      return ApiError(e.cause);
    } on ServerException catch (e) {
      return ApiError(e.cause);
    } on InternalSnackBarException catch (e) {
      return ApiError(e.cause);
    } catch (_) {
      return ApiError("Neočekávaná chyba");
    }
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
  }