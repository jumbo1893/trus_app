import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/features/football/repository/football_repository.dart';
import 'package:trus_app/features/football/table/screens/main_table_team_screen.dart';
import 'package:trus_app/features/football/table/state/football_table_list_state.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../../models/api/football/table_team_api_model.dart';

final footballTableNotifier = StateNotifierProvider.autoDispose<
    FootballTableNotifier, FootballTableListState>((ref) {
  return FootballTableNotifier(
    ref,
    ref.read(footballRepositoryProvider),
    ref.read(screenVariablesNotifierProvider.notifier),
  );
});

class FootballTableNotifier extends SafeStateNotifier<FootballTableListState>
    implements IListviewNotifier {
  final FootballRepository repository;
  final ScreenVariablesNotifier screenController;

  FootballTableNotifier(Ref ref, this.repository, this.screenController)
      : super(ref, FootballTableListState.initial()) {
    Future.microtask(() => _loadTeams());
  }

  Future<void> _loadTeams() async {
    final cached = repository.getCachedTableTeamList();
    if (cached != null) {
      safeSetState(state.copyWith(tableTeams: AsyncValue.data(cached)));
    } else {
      safeSetState(state.copyWith(tableTeams: const AsyncValue.loading()));
    }

    await guardSet<List<TableTeamApiModel>>(
      action: () => runUiWithResult<List<TableTeamApiModel>>(
            () => repository.fetchTableTeamList(),
        showLoading: false,
        successSnack: null,
      ),
      reduce: (result) => state.copyWith(tableTeams: result),
    );
  }

  @override
  selectListviewItem(ModelToString model) {
    screenController.setTableTeamApiModel(
        model as TableTeamApiModel);
    changeFragment(MainTableTeamScreen.id);
  }
}
