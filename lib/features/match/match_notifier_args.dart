import 'package:trus_app/models/api/football/football_match_api_model.dart';

import '../../models/enum/match_detail_options.dart';

class MatchNotifierArgs {
  final MatchDetailOptions preferredScreen;
  final int? matchId;
  final FootballMatchApiModel? footballMatchApiModel;

  const MatchNotifierArgs.add()
      : preferredScreen = MatchDetailOptions.editMatch,
        footballMatchApiModel = null,
        matchId = null;

  const MatchNotifierArgs.edit(this.matchId)
      : preferredScreen = MatchDetailOptions.editMatch,
        footballMatchApiModel = null;

  const MatchNotifierArgs.footballMatchDetailByMatchId(this.matchId)
      : preferredScreen = MatchDetailOptions.footballMatchDetail,
        footballMatchApiModel = null;

  const MatchNotifierArgs.newByFootballMatch(this.footballMatchApiModel)
      : preferredScreen = MatchDetailOptions.editMatch,
        matchId = null;

  const MatchNotifierArgs.footballMatchDetail(this.footballMatchApiModel)
      : preferredScreen = MatchDetailOptions.footballMatchDetail,
        matchId = null;

  const MatchNotifierArgs.mutualMatches(this.footballMatchApiModel)
      : preferredScreen = MatchDetailOptions.mutualMatches,
        matchId = null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MatchNotifierArgs &&
              runtimeType == other.runtimeType &&
              preferredScreen == other.preferredScreen &&
              matchId == other.matchId &&
              footballMatchApiModel == other.footballMatchApiModel;

  @override
  int get hashCode =>
      Object.hash(
        preferredScreen,
        matchId,
        footballMatchApiModel,
      );

  @override
  String toString() {
    return 'MatchNotifierArgs{preferredScreen: $preferredScreen, matchId: $matchId, footballMatchApiModel: $footballMatchApiModel}';
  }
}
