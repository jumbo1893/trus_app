import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/season/season_args.dart';
import 'package:trus_app/features/season/state/season_list_state.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../models/api/season_api_model.dart';
import '../repository/season_api_service.dart';
import '../screens/edit_season_screen.dart';

final seasonNotifierProvider =
StateNotifierProvider.autoDispose<SeasonNotifier, SeasonListState>((ref) {
  return SeasonNotifier(
    ref,
    ref.read(seasonApiServiceProvider),
    ref.read(screenVariablesNotifierProvider.notifier)
  );
});

class SeasonNotifier extends SafeStateNotifier<SeasonListState>
    implements IListviewNotifier {
  final SeasonApiService api;
  final ScreenVariablesNotifier screenController;

  SeasonNotifier(
      Ref ref,
      this.api,
      this.screenController,
      ) : super(ref, SeasonListState.initial()) {
    Future.microtask(loadSeasons);
  }

  Future<void> loadSeasons() async {
    if (!mounted) return;

    safeSetState(
      state.copyWith(seasons: const AsyncValue.loading()),
    );
    final result = await AsyncValue.guard(
        () => runUiWithResult<List<SeasonApiModel>>(
          () => api.getSeasons2(const SeasonArgs(false, false, false)),
      showLoading: false,
      successSnack: null,
    ));

    if (!mounted) return;

    safeSetState(
      state.copyWith(seasons: result),
    );
  }

  @override
  selectListviewItem(ModelToString model) {
    state = state.copyWith(
      selectedSeason: model as SeasonApiModel,
    );
    screenController.setSeason(model);
    changeFragment(EditSeasonScreen.id);
  }
}
