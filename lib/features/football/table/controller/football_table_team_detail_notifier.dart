// lib/features/football/table/controller/football_table_team_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/features/football/repository/football_repository.dart';
import 'package:trus_app/features/football/table/state/football_table_team_state.dart';
import 'package:trus_app/features/main/screen_controller.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../football_team_detail_tab.dart';

final footballTableTeamDetailNotifierProvider = StateNotifierProvider.autoDispose
    .family<FootballTableTeamDetailNotifier, FootballTableTeamState, int>((ref, teamId) {
  return FootballTableTeamDetailNotifier(
    repository: ref.read(footballRepositoryProvider),
    screenController: ref.read(screenControllerProvider),
    teamId: teamId,
  );
});

class FootballTableTeamDetailNotifier extends StateNotifier<FootballTableTeamState> implements IListviewNotifier {
  final FootballRepository repository;
  final ScreenController screenController;
  final int teamId;

  FootballTableTeamDetailNotifier({
    required this.repository,
    required this.screenController,
    required this.teamId,
  }) : super(FootballTableTeamState.initial()) {
    _load(teamId);
  }

  Future<void> _load(int teamId) async {
    state = state.copyWith(
      loading: state.loading.loading("Načítám tým…"),
    );

    final cached = repository.getCachedFootballTeamDetail(teamId);
    if (cached != null) {
      _applyDetail(cached);
    }

    final fresh = await repository.fetchFootballTeamDetail(teamId);
    _applyDetail(fresh);
  }

  void _applyDetail(detail) {
    final tabs = _buildTabs(detail);
    // pokud aktivní tab už neexistuje, fallback na detail
    final active = tabs.contains(state.activeTab) ? state.activeTab : FootballTeamDetailTab.detail;

    state = state.copyWith(
      loading: state.loading.idle(),
      detail: detail,
      tabs: tabs,
      activeTab: active,
    );
  }

  List<FootballTeamDetailTab> _buildTabs(detail) {
    final tabs = <FootballTeamDetailTab>[
      FootballTeamDetailTab.detail,
      FootballTeamDetailTab.nextMatches,
      FootballTeamDetailTab.pastMatches,
    ];
    if (detail.mutualMatches.isNotEmpty) {
      tabs.add(FootballTeamDetailTab.mutualMatches);
    }
    return tabs;
  }

  void changeTab(FootballTeamDetailTab tab) {
    if (!state.tabs.contains(tab)) return;
    state = state.copyWith(activeTab: tab);
  }

  void changeTabByIndex(int index) {
    if (index < 0 || index >= state.tabs.length) return;
    changeTab(state.tabs[index]);
  }

  @override
  selectListviewItem(ModelToString model) {
    //TODO implement select item if needed
  }
}
