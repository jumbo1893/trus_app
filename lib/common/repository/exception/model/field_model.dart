import 'package:age_calculator/age_calculator.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

class FieldModel {
  String? field;
  String? message;

  FieldModel({
    this.field,
    this.message
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      message: json["message"] ?? "",
      field: json["field"] ?? "",
    );
  }

  @override
  String toString() {
    return 'FieldModel{message: $message, field: $field}';
  }
}
