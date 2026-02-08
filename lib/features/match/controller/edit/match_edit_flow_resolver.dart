import 'package:trus_app/features/match/match_notifier_args.dart';
import 'package:trus_app/models/enum/match_detail_options.dart';

enum MatchFlow {
  createEmpty,
  createFromFootballMatch,
  editFromHomeByMatchId,
  openDetailByMatchId,
  openFootballDetailOnly,
  openMutualOnly,
}

class MatchEditFlowResolver {
  const MatchEditFlowResolver();

  MatchFlow resolve(MatchNotifierArgs a) {
    // matchId + preferredScreen
    if (a.matchId != null && a.preferredScreen == MatchDetailOptions.editMatch) {
      return MatchFlow.editFromHomeByMatchId;
    }
    if (a.matchId != null &&
        a.preferredScreen == MatchDetailOptions.footballMatchDetail) {
      return MatchFlow.openDetailByMatchId;
    }

    // footballMatch + preferredScreen
    if (a.footballMatchApiModel != null &&
        a.preferredScreen == MatchDetailOptions.editMatch) {
      return MatchFlow.createFromFootballMatch;
    }
    if (a.footballMatchApiModel != null &&
        a.preferredScreen == MatchDetailOptions.mutualMatches) {
      return MatchFlow.openMutualOnly;
    }
    if (a.footballMatchApiModel != null &&
        a.preferredScreen == MatchDetailOptions.footballMatchDetail) {
      return MatchFlow.openFootballDetailOnly;
    }

    return MatchFlow.createEmpty;
  }
}
