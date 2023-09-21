import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trus_app/common/repository/exception/model/field_validation_response.dart';


import '../field_validation_exception.dart';
import '../internal_snackbar_exception.dart';
import '../login_exception.dart';
import '../model/error_response.dart';
import '../model/login_expired_exception.dart';
import '../server_exception.dart';
import 'error_statutes.dart';

class ResponseValidator {

  void validateStatusCode(http.Response response) {
    int value = response.statusCode;
    if (value == 404) {
      throw ServerException(" $value: Chybná url na server");
    } else if (value == 401) {
      final decodedBody = json.decode(utf8.decode(response.bodyBytes));
      ErrorResponse errorResponse = ErrorResponse.fromJson(decodedBody);
      if(errorResponse.code == notLoggedIn) {
        throw LoginExpiredException();
      }
      else {
        throw LoginException(errorResponse.message);
      }
    } else if (value == 403) {
      throw ServerException('Nedostačující práva na úpravu');
    } else if (value == 400) {
      try {
        final decodedBody = json.decode(utf8.decode(response.bodyBytes));
        FieldValidationResponse fieldValidationResponse = FieldValidationResponse.fromJson(decodedBody);
        throw FieldValidationException(fieldValidationResponse.fields);
      } catch (e) {
        if(e is! FieldValidationException) {
          throw ServerException(
              'Nelze načíst data z neznámých důvodů. Status: $value');
        }
        else {
          rethrow;
        }
      }
    } else if (value == 409) {
      final decodedBody = json.decode(utf8.decode(response.bodyBytes));
      ErrorResponse errorResponse = ErrorResponse.fromJson(decodedBody);
      throw LoginException(errorResponse.message);
    } else if (value == 422) {
      final decodedBody = json.decode(utf8.decode(response.bodyBytes));
      ErrorResponse errorResponse = ErrorResponse.fromJson(decodedBody);
      throw InternalSnackBarException(errorResponse.message);
    } else if (value > 200 || value < 200) {
      throw ServerException(
          'Nelze načíst data z neznámých důvodů. Status: $value');
    }
  }


}