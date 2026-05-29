import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/match/state/match_stats_state.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

import '../../../common/widgets/notifier/dropdown/i_dropdown_state.dart';
import '../../../models/api/interfaces/dropdown_item.dart';
import '../../../models/enum/match_detail_options.dart';
import '../../general/state/base_crud_state.dart';
import 'footbal_match_detail_state.dart';

class MatchEditState extends BaseCrudState<MatchApiModel> implements IDropdownState {
  final String name;
  final DateTime date;
  final bool home;
  final AsyncValue<List<DropdownItem>> seasons;
  final DropdownItem? selectedSeason;
  final List<PlayerApiModel> allPlayers;
  final List<PlayerApiModel> selectedPlayers;
  final List<PlayerApiModel> allFans;
  final List<PlayerApiModel> selectedFans;
  final FootballMatchApiModel? footballMatch;
  final List<MatchDetailOptions> matchOptions;
  final MatchDetailOptions initialTab;
  final FootballMatchDetailState footballMatchDetailState;
  final MatchStatsState matchStatsState;
  final int? homeGoalNumber;
  final int? awayGoalNumber;


  const MatchEditState({
    required this.name,
    required this.date,
    required this.home,
    required this.homeGoalNumber,
    required this.awayGoalNumber,
    required this.seasons,
    required this.selectedSeason,
    required this.allPlayers,
    required this.selectedPlayers,
    required this.allFans,
    required this.selectedFans,
    required this.footballMatch,
    required this.matchOptions,
    required this.initialTab,
    required this.footballMatchDetailState,
    required this.matchStatsState,
    MatchApiModel? model,
    super.errors,
  }) : super(model: model);

  @override
  MatchEditState copyWith({
    String? name,
    DateTime? date,
    bool? home,
    int? homeGoalNumber,
    int? awayGoalNumber,
    AsyncValue<List<DropdownItem>>? seasons,
    DropdownItem? selectedSeason,
    List<PlayerApiModel>? allPlayers,
    List<PlayerApiModel>? selectedPlayers,
    List<PlayerApiModel>? allFans,
    List<PlayerApiModel>? selectedFans,
    FootballMatchApiModel? footballMatch,
    List<MatchDetailOptions>? matchOptions,
    FootballMatchDetailState? footballMatchDetailState,
    MatchStatsState? matchStatsState,
    MatchDetailOptions? initialTab,
    MatchApiModel? model,
    Map<String, String>? errors,
  }) {
    return MatchEditState(
      name: name ?? this.name,
      date: date ?? this.date,
      home: home ?? this.home,
      homeGoalNumber: homeGoalNumber ?? this.homeGoalNumber,
      awayGoalNumber: awayGoalNumber ?? this.awayGoalNumber,
      seasons: seasons ?? this.seasons,
      selectedSeason: selectedSeason ?? this.selectedSeason,
      allPlayers: allPlayers ?? this.allPlayers,
      selectedPlayers: selectedPlayers ?? this.selectedPlayers,
      allFans: allFans ?? this.allFans,
      selectedFans: selectedFans ?? this.selectedFans,
      footballMatch: footballMatch ?? this.footballMatch,
      matchOptions: matchOptions ?? this.matchOptions,
      initialTab: initialTab ?? this.initialTab,
      footballMatchDetailState: footballMatchDetailState ?? this.footballMatchDetailState,
      matchStatsState: matchStatsState ?? this.matchStatsState,
      model: model ?? this.model,
      errors: errors ?? this.errors,
    );
  }

  @override
  AsyncValue<List<DropdownItem>> getDropdownItems() {
    return seasons;
  }

  @override
  DropdownItem? getSelected() {
    return selectedSeason;
  }
}
