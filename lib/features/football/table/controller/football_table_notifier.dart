import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/features/football/repository/football_repository.dart';
import 'package:trus_app/features/football/table/screens/main_table_team_screen.dart';
import 'package:trus_app/features/football/table/state/football_table_list_state.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../../models/api/football/table_team_api_model.dart';
import '../../../main/screen_controller.dart';

final footballTableNotifier = StateNotifierProvider.autoDispose<
    FootballTableNotifier, FootballTableListState>((ref) {
  return FootballTableNotifier(
    ref.read(footballRepositoryProvider),
    ref.read(screenControllerProvider),
  );
});

class FootballTableNotifier extends SafeStateNotifier<FootballTableListState>
    implements IListviewNotifier {
  final FootballRepository repository;
  final ScreenController screenController;

  FootballTableNotifier(this.repository, this.screenController)
      : super(FootballTableListState.initial()) {
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    if (!mounted) return;

    final cached = repository.getCachedTableTeamList();
    if (cached != null) {
      safeSetState(
        state.copyWith(
          tableTeams: AsyncValue.data(cached),
        ),
      );
    } else {
      safeSetState(
        state.copyWith(
          tableTeams: const AsyncValue.loading(),
        ),
      );
    }
    final result = await AsyncValue.guard(
      () => repository.fetchTableTeamList(),
    );

    if (!mounted) return;
    safeSetState(
      state.copyWith(
        tableTeams: result,
      ),
    );
  }

  @override
  selectListviewItem(ModelToString model) {
    screenController.setTableTeamApiModel(
        model as TableTeamApiModel);
    screenController.changeFragment(MainTableTeamScreen.id);
  }
}
