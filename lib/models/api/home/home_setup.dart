import 'package:trus_app/features/general/cache/i_endpoint_id.dart';

import 'dashboard_match.dart';
import '../participation/match_participation_prompt.dart';
import 'stats_board_data.dart';

class HomeSetup implements IEndpointId {
  String nextBirthday;
  List<String> randomFacts;
  final DashboardMatch? nextMatch;
  final DashboardMatch? lastMatch;
  final MatchParticipationPrompt? participationPrompt;
  final String? footbarWarning;
  final List<PendingTeamMember> pendingTeamMembers;

  final List<StatsBoardData> statsBoards;

  static const endpointId = "home_setup";

  HomeSetup({
    required this.nextBirthday,
    required this.randomFacts,
    required this.nextMatch,
    required this.lastMatch,
    required this.participationPrompt,
    required this.statsBoards,
    this.footbarWarning,
    this.pendingTeamMembers = const [],
  });

  factory HomeSetup.fromJson(Map<String, dynamic> json) {
    return HomeSetup(
      nextBirthday: json["nextBirthday"] ?? "",
      footbarWarning: json['footbarWarning'] as String?,
      pendingTeamMembers:
          (json['pendingTeamMembers'] as List<dynamic>? ?? const [])
              .map(
                (item) =>
                    PendingTeamMember.fromJson(item as Map<String, dynamic>),
              )
              .toList(),

      randomFacts: List<String>.from(json['randomFacts'] ?? []),

      nextMatch: json["nextMatch"] != null
          ? DashboardMatch.fromJson(json["nextMatch"])
          : null,

      lastMatch: json["lastMatch"] != null
          ? DashboardMatch.fromJson(json["lastMatch"])
          : null,
      participationPrompt: json["participationPrompt"] != null
          ? MatchParticipationPrompt.fromJson(json["participationPrompt"])
          : null,

      statsBoards: List<StatsBoardData>.from(
        (json['statsBoards'] as List<dynamic>? ?? []).map(
          (e) => StatsBoardData.fromJson(e),
        ),
      ),
    );
  }

  @override
  String getEndpointId() {
    return endpointId;
  }
}

class PendingTeamMember {
  final int userTeamRoleId;
  final String userName;

  const PendingTeamMember({
    required this.userTeamRoleId,
    required this.userName,
  });

  factory PendingTeamMember.fromJson(Map<String, dynamic> json) =>
      PendingTeamMember(
        userTeamRoleId: json['userTeamRoleId'] as int,
        userName: json['userName'] as String? ?? '',
      );
}
