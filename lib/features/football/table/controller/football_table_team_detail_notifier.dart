// lib/features/football/table/controller/football_table_team_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/features/football/repository/football_repository.dart';
import 'package:trus_app/features/football/table/state/football_table_team_state.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../../models/api/football/detail/football_team_detail.dart';
import '../football_team_detail_tab.dart';

final footballTableTeamDetailNotifierProvider = StateNotifierProvider.autoDispose
    .family<FootballTableTeamDetailNotifier, FootballTableTeamState, int>((ref, teamId) {
  return FootballTableTeamDetailNotifier(
    ref: ref,
    repository: ref.read(footballRepositoryProvider),
    screenController: ref.read(screenVariablesNotifierProvider.notifier),
    teamId: teamId,
  );
});

class FootballTableTeamDetailNotifier extends AppNotifier<FootballTableTeamState> implements IListviewNotifier {
  final FootballRepository repository;
  final ScreenVariablesNotifier screenController;
  final int teamId;

  FootballTableTeamDetailNotifier({
    required Ref ref,
    required this.repository,
    required this.screenController,
    required this.teamId,
  }) : super(ref, FootballTableTeamState.initial()) {
    Future.microtask(() => _load(teamId));
  }

  Future<void> _load(int teamId) async {

    final cached = repository.getCachedFootballTeamDetail(teamId);
    if (cached != null) {
      _applyDetail(cached);
    }
    final fresh = await runUiWithResult<FootballTeamDetail>(
          () => repository.fetchFootballTeamDetail(teamId),
      showLoading: false,
      successSnack: null,
    );
    _applyDetail(fresh);
  }

  void _applyDetail(detail) {
    final tabs = _buildTabs(detail);
    // pokud aktivní tab už neexistuje, fallback na detail
    final active = tabs.contains(state.activeTab) ? state.activeTab : FootballTeamDetailTab.detail;

    state = state.copyWith(
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
