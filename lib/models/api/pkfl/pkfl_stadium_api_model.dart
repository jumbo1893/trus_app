import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

class PkflStadiumApiModel {
  int id;
  String name;

  PkflStadiumApiModel({
    required this.name,
    required this.id,
  });



  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
    };
  }

  factory PkflStadiumApiModel.fromJson(Map<String, dynamic> json) {
    return PkflStadiumApiModel(
      name: json["name"] ?? "",
      id: json["id"],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PkflStadiumApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

}
