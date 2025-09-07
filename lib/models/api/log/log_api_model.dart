import 'package:trus_app/config.dart';

import '../interfaces/json_and_http_converter.dart';
class LogApiModel implements JsonAndHttpConverter {
  final String logClass;
  final String message;

  LogApiModel({
    required this.logClass,
    required this.message,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "logClass": logClass,
      "message": message,
    };
  }

  @override
  factory LogApiModel.fromJson(Map<String, dynamic> json) {
    return LogApiModel(
      logClass: json["logClass"] ?? "",
      message: json["message"] ?? "",
    );
  }

  @override
  String httpRequestClass() {
    return tokenApi;
  }
}
