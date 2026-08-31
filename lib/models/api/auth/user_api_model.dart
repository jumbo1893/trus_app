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

  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    return UserApiModel(
      mail: json["mail"] ?? "",
      name: json["name"] ?? "",
      id: json["id"],
      admin: json['admin'] ?? false,
      teamRoles: json['teamRoles'] != null
          ? List<UserTeamRoleApiModel>.from(
              (json['teamRoles'] as List<dynamic>).map(
                (role) => UserTeamRoleApiModel.fromJson(role),
              ),
            )
          : null,
    );
  }

  String getDescriptionOfOtherRoles(int? appTeamId) {
    List<UserTeamRoleApiModel> otherRoles = getAllOtherThanCurrentTeamRole(
      appTeamId,
    );
    String returnString = "";
    for (UserTeamRoleApiModel teamRole in otherRoles) {
      returnString +=
          "Tým: ${teamRole.appTeam.name}, role: ${teamRole.roleToString()}\n";
    }
    return returnString;
  }

  UserTeamRoleApiModel? getCurrentUserTeamRole(int? appTeamId) {
    final roles = teamRoles ?? const <UserTeamRoleApiModel>[];
    if (appTeamId != null) {
      for (UserTeamRoleApiModel userTeamRoleApiModel in roles) {
        if (userTeamRoleApiModel.appTeam.id == appTeamId) {
          return userTeamRoleApiModel;
        }
      }
    }
    if (roles.length == 1) {
      return roles.first;
    }
    return null;
  }

  List<UserTeamRoleApiModel> getAllOtherThanCurrentTeamRole(int? appTeamId) {
    if (appTeamId == null) {
      return [];
    }
    return (teamRoles ?? const <UserTeamRoleApiModel>[])
        .where((role) => role.appTeam.id != appTeamId)
        .toList();
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
    if (teamRoles != null && teamRoles!.isNotEmpty) {
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
    return "Vítej, $name!";
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
