import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/auth/user_team_role_api_model.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

class UserApiModel implements ModelToString, JsonAndHttpConverter {
  int? id;
  String? name;
  String? mail;
  String? password;
  bool? admin;
  List<UserTeamRoleApiModel>? teamRoles;

  UserApiModel({
    this.name,
    this.mail,
    this.password,
    this.admin,
    this.id,
    this.teamRoles,
  });

  @override
  String toString() {
    return 'UserApiModel{id: $id, name: $name, mail: $mail, admin: $admin}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "mail": mail,
      "admin": admin,
      "id": id,
      "password": password,
      "teamRoles": teamRoles,
    };
  }

  @override
  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    return UserApiModel(
      mail: json["mail"] ?? "",
      name: json["name"] ?? "",
      id: json["id"],
      admin: json['admin'] ?? false,
      teamRoles: json['teamRoles'] != null
          ? List<UserTeamRoleApiModel>.from(
          (json['teamRoles'] as List<dynamic>)
              .map((role) => UserTeamRoleApiModel.fromJson(role)))
          : null,
    );
  }

  String getDescriptionOfOtherRoles(int appTeamId) {
    List<UserTeamRoleApiModel> otherRoles = getAllOtherThanCurrentTeamRole(appTeamId);
    String returnString = "";
    for (UserTeamRoleApiModel teamRole in otherRoles) {
      returnString += "Tým: ${teamRole.appTeam.name}, role: ${teamRole.roleToString()}\n";
    }
    return returnString;
  }

  UserTeamRoleApiModel? getCurrentUserTeamRole(int appTeamId) {
    if (teamRoles != null && teamRoles!.isNotEmpty) {
      for (UserTeamRoleApiModel userTeamRoleApiModel in teamRoles!) {
        if(userTeamRoleApiModel.appTeam.id == appTeamId) {
          return userTeamRoleApiModel;
        }
      }
    }
    return null;
  }

  List<UserTeamRoleApiModel> getAllOtherThanCurrentTeamRole(int appTeamId) {
    if (teamRoles != null) {
      for (UserTeamRoleApiModel userTeamRoleApiModel in teamRoles!) {
        List<UserTeamRoleApiModel> otherTeamRoles = [];
        if(userTeamRoleApiModel.appTeam.id != appTeamId) {
          otherTeamRoles.add(userTeamRoleApiModel);
          return otherTeamRoles;
        }
      }
    }
    return [];
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
    if(teamRoles != null && teamRoles!.isNotEmpty) {
      return "Uživatel s právy ${teamRoles![0].roleToString()}";
    }
    return "Uživatel s neznámými právy";
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
