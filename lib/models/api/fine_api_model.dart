import 'package:age_calculator/age_calculator.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

class FineApiModel implements ModelToString, JsonAndHttpConverter {
  int? id;
  final String name;
  final int amount;

  FineApiModel({
    required this.name,
    required this.amount,
    this.id,
  });

  FineApiModel.dummy()
      : id = 0,
        name = "neznámá pokuta",
        amount = 0;


  @override
  String toString() {
    return 'FineApiModel{id: $id, name: $name, amount: $amount}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "amount": amount,
    };
  }

  @override
  factory FineApiModel.fromJson(Map<String, dynamic> json) {
    return FineApiModel(
      amount: json['amount'] ?? 0,
      name: json["name"] ?? "",
      id: json["id"] ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FineApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toStringForListView() {
    return "Pokuta ve výši $amount Kč";
  }

  @override
  String listViewTitle() {
    return name;
  }

  @override
  String toStringForAdd() {
    return "Přidána pokuta $name ve výši $amount";
  }

  @override
  String toStringForConfirmationDelete() {
    return "Opravdu chcete smazat tuto pokutu?";
  }

  @override
  String toStringForEdit(String originName) {
    return "Pokuta $originName upravena na $name, s výší $amount";
  }

  @override
  String httpRequestClass() {
    return fineApi;
  }

  @override
  int getId() {
    return id ?? -1;
  }
}
