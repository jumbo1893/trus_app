import 'package:trus_app/models/api/auth/team_member_api_model.dart';

class TeamAdministrationApiModel {
  final int appTeamId;
  final String teamName;
  final int? ownerId;
  final String? ownerName;
  final int currentUserId;
  final String readerCode;
  final String editorCode;
  final List<TeamMemberApiModel> members;

  const TeamAdministrationApiModel({
    required this.appTeamId,
    required this.teamName,
    required this.ownerId,
    required this.ownerName,
    required this.currentUserId,
    required this.readerCode,
    required this.editorCode,
    required this.members,
  });

  factory TeamAdministrationApiModel.fromJson(Map<String, dynamic> json) {
    return TeamAdministrationApiModel(
      appTeamId: json['appTeamId'] as int,
      teamName: json['teamName'] as String? ?? '',
      ownerId: json['ownerId'] as int?,
      ownerName: json['ownerName'] as String?,
      currentUserId: json['currentUserId'] as int,
      readerCode: json['readerCode'] as String? ?? '',
      editorCode: json['editorCode'] as String? ?? '',
      members: (json['members'] as List<dynamic>? ?? const [])
          .map(
            (item) => TeamMemberApiModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
