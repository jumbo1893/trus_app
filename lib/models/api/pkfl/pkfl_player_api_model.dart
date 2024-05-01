

import '../../../config.dart';
import '../interfaces/dropdown_item.dart';
import '../interfaces/json_and_http_converter.dart';

class PkflPlayerApiModel implements JsonAndHttpConverter, DropdownItem {
  int id;
  String name;

  PkflPlayerApiModel({
    required this.name,
    required this.id,
  });


  @override
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
    };
  }

  @override
  factory PkflPlayerApiModel.fromJson(Map<String, dynamic> json) {
    return PkflPlayerApiModel(
      name: json["name"] ?? "",
      id: json["id"],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PkflPlayerApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String httpRequestClass() {
    return pkflPlayerApi;
  }

  @override
  String dropdownText() {
    return name ?? "";
  }

}
