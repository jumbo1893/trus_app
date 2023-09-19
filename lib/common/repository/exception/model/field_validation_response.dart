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
