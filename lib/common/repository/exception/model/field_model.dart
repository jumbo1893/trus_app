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
