import 'package:age_calculator/age_calculator.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import 'field_model.dart';

class FieldValidationResponse {
  String? message;
  List<FieldModel>? fields;

  FieldValidationResponse({
    this.message,
    this.fields
  });

  factory FieldValidationResponse.fromJson(Map<String, dynamic> json) {
    return FieldValidationResponse(
      message: json["message"] ?? "",
      fields: List<FieldModel>.from((json['fields'] as List<dynamic>).map((field) => FieldModel.fromJson(field))),
    );
  }

  @override
  String toString() {
    return 'FieldValidationResponse{message: $message, fields: $fields}';
  }
}
