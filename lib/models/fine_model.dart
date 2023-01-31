import 'package:age_calculator/age_calculator.dart';
import 'package:trus_app/common/utils/calendar.dart';

class FineModel {
  final String id;
  final String name;
  final int amount;


  FineModel(
      {required this.name,
      required this.id,
      required this.amount,});

  FineModel.dummy()
      : id = "dummy",
        name = "dummy",
        amount = 0;

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "amount": amount,
    };
  }

  String toStringForFineList() {
    return 'Pokuta ve výši: $amount Kč';
  }


  @override
  String toString() {
    return 'FineModel{id: $id, name: $name, amount: $amount}';
  }

  factory FineModel.fromJson(Map<String, dynamic> json) {
    return FineModel(
      amount: json['amount'] ?? 0,
      name: json["name"] ?? "",
      id: json["id"] ?? "",
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FineModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;



//

}
