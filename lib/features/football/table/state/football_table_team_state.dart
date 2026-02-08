// lib/features/football/table/state/football_table_team_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_state.dart';
import 'package:trus_app/common/widgets/notifier/loader/loading_state.dart';
import 'package:trus_app/models/api/football/detail/football_team_detail.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../general/state/base_crud_state.dart';
import '../football_team_detail_tab.dart';

class FootballTableTeamState extends BaseCrudState<FootballTeamDetail> implements IListviewState {
  final FootballTeamDetail? detail;

  // řízení tabů
  final List<FootballTeamDetailTab> tabs;
  final FootballTeamDetailTab activeTab;

  const FootballTableTeamState({
    required this.detail,
    required this.tabs,
    required this.activeTab,
    super.loading,
  });

  factory FootballTableTeamState.initial() => const FootballTableTeamState(
    detail: null,
    tabs: [FootballTeamDetailTab.detail],
    activeTab: FootballTeamDetailTab.detail,
  );

  @override
  FootballTableTeamState copyWith({
    FootballTeamDetail? detail,
    List<FootballTeamDetailTab>? tabs,
    FootballTeamDetailTab? activeTab,
    FootballTeamDetail? model,
    LoadingState? loading,
    Map<String, String>? errors,
    String? successMessage,
  }) {
    return FootballTableTeamState(
      detail: detail ?? this.detail,
      tabs: tabs ?? this.tabs,
      activeTab: activeTab ?? this.activeTab,
      loading: loading ?? this.loading,
    );
  }

  String get teamName => detail?.tableTeam.teamName ?? "";
  String get leagueRanking => detail?.tableTeam.toStringForDetail() ?? "";
  String get averageBirthYear => detail?.averageBirthYearToString() ?? "";
  String get bestScorer => detail?.bestScorerToString() ?? "";
  String get aggregateScore => detail?.aggregateScore ?? "";
  String get aggregateMatches => detail?.aggregateMatches ?? "";

  bool get hasMutual => (detail?.mutualMatches ?? const []).isNotEmpty;

  List<FootballMatchApiModel> get currentMatchList {
    final d = detail;
    if (d == null) return [FootballMatchApiModel.noMatch()];

    List<FootballMatchApiModel> list;
    switch (activeTab) {
      case FootballTeamDetailTab.nextMatches:
        list = d.nextMatches;
        break;
      case FootballTeamDetailTab.pastMatches:
        list = d.pastMatches;
        break;
      case FootballTeamDetailTab.mutualMatches:
        list = d.mutualMatches;
        break;
      case FootballTeamDetailTab.detail:
        list = const [];
        break;
    }

    if (list.isEmpty && activeTab != FootballTeamDetailTab.detail) {
      return [FootballMatchApiModel.noMatch()];
    }
    return list;
  }

  AsyncValue<List<FootballMatchApiModel>> get currentMatchListAsync {
    // pro snadné napojení na tvé list view widgety
    if (activeTab == FootballTeamDetailTab.detail) {
      return const AsyncValue.data([]);
    }
    return AsyncValue.data(currentMatchList);
  }

  @override
  AsyncValue<List<ModelToString>> getListViewItems() {
    return currentMatchListAsync;
  }
}
