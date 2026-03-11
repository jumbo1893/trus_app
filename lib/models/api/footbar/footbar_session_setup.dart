import 'package:trus_app/models/api/match/match_api_model.dart';

import '../season_api_model.dart';
import 'footbar_account_sessions.dart';

class FootbarSessionSetup {
  MatchApiModel? match;
  final SeasonApiModel season;
  final List<MatchApiModel> matches;
  final List<FootbarAccountSessions> sessions;


  FootbarSessionSetup({
    this.match,
    required this.season,
    required this.matches,
    required this.sessions,
  });

  factory FootbarSessionSetup.fromJson(Map<String, dynamic> json) {
    return FootbarSessionSetup(
      match: json["match"] != null ? MatchApiModel.fromJson(json["match"]) : null,
      season: SeasonApiModel.fromJson(json["season"]),
      matches: (json['matches'] as List<dynamic>)
          .map((a) => MatchApiModel.fromJson(a))
          .toList(),
      sessions: (json['sessions'] as List<dynamic>)
          .map((a) => FootbarAccountSessions.fromJson(a))
          .toList(),
    );
  }
}
