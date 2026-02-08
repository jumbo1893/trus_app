import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

import '../../../common/widgets/notifier/dropdown/i_dropdown_state.dart';
import '../../../common/widgets/notifier/loader/loading_state.dart';
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

  const MatchEditState({
    required this.name,
    required this.date,
    required this.home,
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
    MatchApiModel? model,
    super.loading,
    super.errors,
    super.successMessage,
  }) : super(model: model);

  @override
  MatchEditState copyWith({
    String? name,
    DateTime? date,
    bool? home,
    AsyncValue<List<DropdownItem>>? seasons,
    DropdownItem? selectedSeason,
    List<PlayerApiModel>? allPlayers,
    List<PlayerApiModel>? selectedPlayers,
    List<PlayerApiModel>? allFans,
    List<PlayerApiModel>? selectedFans,
    FootballMatchApiModel? footballMatch,
    List<MatchDetailOptions>? matchOptions,
    FootballMatchDetailState? footballMatchDetailState,
    MatchDetailOptions? initialTab,
    MatchApiModel? model,
    LoadingState? loading,
    Map<String, String>? errors,
    String? successMessage,
  }) {
    return MatchEditState(
      name: name ?? this.name,
      date: date ?? this.date,
      home: home ?? this.home,
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
      model: model ?? this.model,
      loading: loading ?? this.loading,
      errors: errors ?? this.errors,
      successMessage: successMessage,
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
