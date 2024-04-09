import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../interfaces/json_and_http_converter.dart';

class StepApiModel implements JsonAndHttpConverter, ModelToString {
  final int stepNumber;

  StepApiModel({
    required this.stepNumber,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "stepNumber": stepNumber,
    };
  }

  @override
  factory StepApiModel.fromJson(Map<String, dynamic> json) {
    return StepApiModel(
      stepNumber: json["stepNumber"] ?? 0,
    );
  }

  @override
  String httpRequestClass() {
    return stepApi;
  }

  @override
  int getId() {
    return 0;
  }

  @override
  String listViewTitle() {
    return stepNumber.toString();
  }

  @override
  String toStringForAdd() {
    return stepNumber.toString();
  }

  @override
  String toStringForConfirmationDelete() {
    return stepNumber.toString();
  }

  @override
  String toStringForEdit(String originName) {
    return stepNumber.toString();
  }

  @override
  String toStringForListView() {
    return stepNumber.toString();
  }
}
