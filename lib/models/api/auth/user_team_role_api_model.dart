import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class UserTeamRoleApiModel {
  int? id;
  final int userId;
  final AppTeamApiModel appTeam;
  String? role;
  PlayerApiModel? player;

  UserTeamRoleApiModel({
    required this.userId,
    required this.appTeam,
    this.id,
    this.role,
    this.player,
  });

  String roleToString() {
    if(role == null) {
      return "";
    }
    else if(role == "ADMIN") {
      return "pro změnu";
    }
    else if(role == "READER") {
      return "pro čtení";
    }
    return role!;
  }

  String playerToString() {
    if(player == null) {
      return "";
    }
    return player!.name;
  }

  String getOppositeRole() {
    if(role == "READER") {
      return "ADMIN";
    }
    return "READER";
  }

  @override
  String toString() {
    return 'UserTeamRoleApiModel{id: $id, userId: $userId, appTeam: $appTeam, role: $role, player: $player}';
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "appTeam": appTeam,
      "role": role,
      "player": player,
    };
  }

  factory UserTeamRoleApiModel.fromJson(Map<String, dynamic> json) {
    return UserTeamRoleApiModel(
      id: json["id"] ?? 0,
      userId: json["userId"],
      appTeam: AppTeamApiModel.fromJson(json["appTeam"]),
      role: json['role'] ?? "",
      player: json["player"] != null ? PlayerApiModel.fromJson(json["player"]) : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserTeamRoleApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
