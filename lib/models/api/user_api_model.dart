import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

class UserApiModel implements ModelToString, JsonAndHttpConverter {
  int? id;
  String? name;
  String? mail;
  String? password;
  int? playerId;
  bool? admin;

  UserApiModel({
    this.name,
    this.mail,
    this.password,
    this.playerId,
    this.admin,
    this.id,
  });


  @override
  String toString() {
    return 'UserApiModel{id: $id, name: $name, mail: $mail, playerId: $playerId, admin: $admin}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "mail": mail,
      "playerId": playerId,
      "admin": admin,
      "id": id,
      "password": password,
    };
  }

  @override
  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    return UserApiModel(
      mail: json["mail"] ?? "",
      name: json["name"] ?? "",
      id: json["id"],
      playerId: json["playerId"],
      admin: json['admin'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toStringForListView() {
    return admin! ? "Uživatel s právami pro změny" : "Uživatel bez práva pro změny";
  }

  @override
  String listViewTitle() {
    return name ?? "";
  }

  @override
  String toStringForAdd() {
    return "Vítejte pane $name, přejeme příjemné pití";
  }

  @override
  String toStringForConfirmationDelete() {
    return "";
  }

  @override
  String toStringForEdit(String originName) {
    return "";
  }

  @override
  String httpRequestClass() {
    return authApi;
  }

  @override
  int getId() {
    return id ?? -1;
  }
}
