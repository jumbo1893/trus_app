import 'package:age_calculator/age_calculator.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

class ErrorResponse {
  final String message;
  String? code;

  ErrorResponse({
    required this.message,
    this.code
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json["message"] ?? "",
      code: json["code"] ?? "",
    );
  }

  @override
  String toString() {
    return 'ErrorResponse{message: $message, code: $code}';
  }
}
