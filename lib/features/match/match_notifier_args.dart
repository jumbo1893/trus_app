import 'package:trus_app/models/api/football/football_match_api_model.dart';

import '../../models/enum/match_detail_options.dart';

class MatchNotifierArgs {
  final MatchDetailOptions preferredScreen;
  final int? matchId;
  final FootballMatchApiModel? footballMatchApiModel;
  final bool openBottomSheet;

  const MatchNotifierArgs.add()
      : preferredScreen = MatchDetailOptions.editMatch,
        footballMatchApiModel = null,
        openBottomSheet = false,
        matchId = null;

  const MatchNotifierArgs.edit(this.matchId)
      : preferredScreen = MatchDetailOptions.editMatch,
        openBottomSheet = false,
        footballMatchApiModel = null;

  const MatchNotifierArgs.footballMatchDetailByMatchId(this.matchId)
      : preferredScreen = MatchDetailOptions.footballMatchDetail,
        openBottomSheet = false,
        footballMatchApiModel = null;

  const MatchNotifierArgs.newByFootballMatch(this.footballMatchApiModel)
      : preferredScreen = MatchDetailOptions.editMatch,
        openBottomSheet = false,
        matchId = null;

  const MatchNotifierArgs.footballMatchDetail(this.footballMatchApiModel)
      : preferredScreen = MatchDetailOptions.footballMatchDetail,
        openBottomSheet = false,
        matchId = null;

  const MatchNotifierArgs.mutualMatches(this.footballMatchApiModel)
      : preferredScreen = MatchDetailOptions.mutualMatches,
        openBottomSheet = false,
        matchId = null;

  const MatchNotifierArgs.newByFootballMatchWithBottomSheet(this.footballMatchApiModel)
      : preferredScreen = MatchDetailOptions.editMatch,
        openBottomSheet = true,
        matchId = null;

  const MatchNotifierArgs.editWithBottomSheet(this.matchId)
      : preferredScreen = MatchDetailOptions.editMatch,
        openBottomSheet = true,
        footballMatchApiModel = null;

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
