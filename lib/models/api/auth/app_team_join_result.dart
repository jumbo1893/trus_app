import 'package:trus_app/models/api/auth/user_api_model.dart';

class AppTeamJoinResult {
  final UserApiModel user;
  final int appTeamId;
  final String assignedRole;

  const AppTeamJoinResult({
    required this.user,
    required this.appTeamId,
    required this.assignedRole,
  });

  factory AppTeamJoinResult.fromJson(Map<String, dynamic> json) {
    return AppTeamJoinResult(
      user: UserApiModel.fromJson(json['user'] as Map<String, dynamic>),
      appTeamId: json['appTeamId'] as int,
      assignedRole: json['assignedRole'] as String,
    );
  }
}
