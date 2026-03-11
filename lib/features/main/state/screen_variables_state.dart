import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/match/match_notifier_args.dart';
import 'package:trus_app/models/api/achievement/achievement_detail.dart';
import 'package:trus_app/models/api/achievement/player_achievement_api_model.dart';
import 'package:trus_app/models/api/fine_api_model.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/football/table_team_api_model.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

class ScreenVariablesState {
  final String currentScreenId;

  final Map<String, double> scrollOffsets;

  final int? matchId;
  final int? footballTeamId;

  final FootballMatchApiModel? footballMatch;
  final TableTeamApiModel tableTeam;
  final MatchApiModel matchModel;
  final PlayerApiModel playerModel;
  final PlayerAchievementApiModel playerAchievement;
  final AchievementDetail achievementDetail;
  final SeasonApiModel seasonModel;
  final FineApiModel fineModel;

  final List<int> playerIdList;

  final bool changedMatch;
  final bool commonMatchesOnly;

  final String statsApi;
  final MatchNotifierArgs matchNotifierArgs;

  const ScreenVariablesState({
    required this.currentScreenId,
    required this.scrollOffsets,
    required this.matchId,
    required this.footballTeamId,
    required this.footballMatch,
    required this.tableTeam,
    required this.matchModel,
    required this.playerModel,
    required this.playerAchievement,
    required this.achievementDetail,
    required this.seasonModel,
    required this.fineModel,
    required this.playerIdList,
    required this.changedMatch,
    required this.commonMatchesOnly,
    required this.statsApi,
    required this.matchNotifierArgs,
  });

  factory ScreenVariablesState.initial() => ScreenVariablesState(
    currentScreenId: HomeScreen.id,
    scrollOffsets: const {},
    matchId: null,
    footballTeamId: null,
    footballMatch: null,
    tableTeam: TableTeamApiModel.dummy(),
    matchModel: MatchApiModel.dummy(),
    playerModel: PlayerApiModel.dummy(),
    playerAchievement: PlayerAchievementApiModel.dummy(),
    achievementDetail: AchievementDetail.dummy(),
    seasonModel: SeasonApiModel.dummy(),
    fineModel: FineApiModel.dummy(),
    playerIdList: const [],
    changedMatch: false,
    commonMatchesOnly: false,
    statsApi: "",
    matchNotifierArgs: const MatchNotifierArgs.add(),
  );

  ScreenVariablesState copyWith({
    String? currentScreenId,
    Map<String, double>? scrollOffsets,
    int? matchId,
    int? footballTeamId,
    FootballMatchApiModel? footballMatch,
    TableTeamApiModel? tableTeam,
    MatchApiModel? matchModel,
    PlayerApiModel? playerModel,
    PlayerAchievementApiModel? playerAchievement,
    AchievementDetail? achievementDetail,
    SeasonApiModel? seasonModel,
    FineApiModel? fineModel,
    List<int>? playerIdList,
    bool? changedMatch,
    bool? commonMatchesOnly,
    String? statsApi,
    MatchNotifierArgs? matchNotifierArgs,
  }) {
    return ScreenVariablesState(
      currentScreenId: currentScreenId ?? this.currentScreenId,
      scrollOffsets: scrollOffsets ?? this.scrollOffsets,
      matchId: matchId ?? this.matchId,
      footballTeamId: footballTeamId ?? this.footballTeamId,
      footballMatch: footballMatch ?? this.footballMatch,
      tableTeam: tableTeam ?? this.tableTeam,
      matchModel: matchModel ?? this.matchModel,
      playerModel: playerModel ?? this.playerModel,
      playerAchievement: playerAchievement ?? this.playerAchievement,
      achievementDetail: achievementDetail ?? this.achievementDetail,
      seasonModel: seasonModel ?? this.seasonModel,
      fineModel: fineModel ?? this.fineModel,
      playerIdList: playerIdList ?? this.playerIdList,
      changedMatch: changedMatch ?? this.changedMatch,
      commonMatchesOnly: commonMatchesOnly ?? this.commonMatchesOnly,
      statsApi: statsApi ?? this.statsApi,
      matchNotifierArgs: matchNotifierArgs ?? this.matchNotifierArgs,
    );
  }
}
