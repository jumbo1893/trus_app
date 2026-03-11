
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/main/state/screen_variables_state.dart';
import 'package:trus_app/features/match/match_notifier_args.dart';
import 'package:trus_app/models/api/achievement/achievement_detail.dart';
import 'package:trus_app/models/api/achievement/player_achievement_api_model.dart';
import 'package:trus_app/models/api/fine_api_model.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/football/table_team_api_model.dart';

import '../../../models/api/match/match_api_model.dart';
import '../../../models/api/player/player_api_model.dart';
import '../../../models/api/season_api_model.dart';

// nechávám tvůj MatchNotifierArgs provider
final matchNotifierArgsProvider =
    StateProvider<MatchNotifierArgs>((ref) => const MatchNotifierArgs.add());

final screenVariablesNotifierProvider =
    StateNotifierProvider<ScreenVariablesNotifier, ScreenVariablesState>((ref) {
  return ScreenVariablesNotifier(ref: ref);
});

class ScreenVariablesNotifier extends StateNotifier<ScreenVariablesState> {
  final Ref ref;
  final PageController pageController = PageController();

  ScreenVariablesNotifier({required this.ref}) : super(ScreenVariablesState.initial());

  // ---- args setters/getters ----

  void setMatchId(int id) {
    state = state.copyWith(
      footballMatch: null,
      commonMatchesOnly: false,
      matchId: id,
    );
  }

  void setFootballTeamIdOnlyForCommonMatches(int id) {
    state = state.copyWith(commonMatchesOnly: true, footballTeamId: id);
  }

  void setMatch(MatchApiModel matchModel) {
    state = state.copyWith(
      matchModel: matchModel,
      commonMatchesOnly: false,
      matchId: matchModel.id,
      footballMatch: null,
    );
  }

  void setTableTeamApiModel(TableTeamApiModel tableTeamApiModel) {
    state = state.copyWith(tableTeam: tableTeamApiModel);
  }

  void setPlayerAchievement(PlayerAchievementApiModel model) {
    state = state.copyWith(playerAchievement: model);
  }

  void setAchievementDetail(AchievementDetail detail) {
    state = state.copyWith(achievementDetail: detail);
  }

  void setPlayer(PlayerApiModel playerModel) {
    state = state.copyWith(playerModel: playerModel);
  }

  void setSeason(SeasonApiModel seasonModel) {
    state = state.copyWith(seasonModel: seasonModel);
  }

  void setFine(FineApiModel fineModel) {
    state = state.copyWith(fineModel: fineModel);
  }

  void setPlayerIdList(List<int> playerIdList) {
    state = state.copyWith(playerIdList: List<int>.from(playerIdList));
  }

  void setFootballMatch(FootballMatchApiModel footballMatch) {
    state =
        state.copyWith(commonMatchesOnly: false, footballMatch: footballMatch);
  }

  void setStatsApi(String statsApi) {
    state = state.copyWith(statsApi: statsApi);
  }

  bool consumeChangedMatch() {
    if (!state.changedMatch) return false;
    state = state.copyWith(changedMatch: false);
    return true;
  }

  void setChangedMatch(bool changedMatch) {
    state = state.copyWith(changedMatch: changedMatch);
  }

  void setMatchNotifierArgs(MatchNotifierArgs args) {
    state = state.copyWith(matchNotifierArgs: args);
    ref.read(matchNotifierArgsProvider.notifier).state = args;
  }

}
