import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

class PkflOpponentApiModel {
  int id;
  String name;

  PkflOpponentApiModel({
    required this.name,
    required this.id,
  });



  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
    };
  }

  factory PkflOpponentApiModel.fromJson(Map<String, dynamic> json) {
    return PkflOpponentApiModel(
      name: json["name"] ?? "",
      id: json["id"],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PkflOpponentApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

}
