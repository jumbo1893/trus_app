import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/participation/match_participation_member.dart';
import 'package:trus_app/models/api/participation/match_participation_status.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class MatchParticipationDetail {
  final FootballMatchApiModel footballMatch;
  final PlayerApiModel? currentPlayer;
  final MatchParticipationStatus? currentStatus;
  final List<MatchParticipationMember> attendingPlayers;
  final List<MatchParticipationMember> attendingFans;
  final List<MatchParticipationMember> maybePlayers;
  final List<MatchParticipationMember> maybeFans;
  final List<MatchParticipationMember> notAttendingPlayers;
  final List<MatchParticipationMember> notAttendingFans;
  final List<PlayerApiModel> eligiblePlayers;

  const MatchParticipationDetail({
    required this.footballMatch,
    required this.currentPlayer,
    required this.currentStatus,
    required this.attendingPlayers,
    required this.attendingFans,
    required this.maybePlayers,
    required this.maybeFans,
    required this.notAttendingPlayers,
    required this.notAttendingFans,
    required this.eligiblePlayers,
  });

  factory MatchParticipationDetail.fromJson(Map<String, dynamic> json) {
    List<MatchParticipationMember> members(String key) {
      return (json[key] as List<dynamic>? ?? const [])
          .map((item) => MatchParticipationMember.fromJson(item))
          .toList();
    }

    return MatchParticipationDetail(
      footballMatch: FootballMatchApiModel.fromJson(json['footballMatch']),
      currentPlayer: json['currentPlayer'] != null
          ? PlayerApiModel.fromJson(json['currentPlayer'])
          : null,
      currentStatus: MatchParticipationStatusExtension.fromJson(
        json['currentStatus'],
      ),
      attendingPlayers: members('attendingPlayers'),
      attendingFans: members('attendingFans'),
      maybePlayers: members('maybePlayers'),
      maybeFans: members('maybeFans'),
      notAttendingPlayers: members('notAttendingPlayers'),
      notAttendingFans: members('notAttendingFans'),
      eligiblePlayers: (json['eligiblePlayers'] as List<dynamic>? ?? const [])
          .map((item) => PlayerApiModel.fromJson(item))
          .toList(),
    );
  }
}
