import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/features/fine/repository/fine_api_service.dart';
import 'package:trus_app/features/fine/screens/edit_fine_screen.dart';
import 'package:trus_app/features/fine/state/fine_list_state.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/models/api/fine_api_model.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

final fineNotifierProvider =
    StateNotifierProvider.autoDispose<FineNotifier, FineListState>((ref) {
  return FineNotifier(
    ref,
    ref.read(fineApiServiceProvider),
    ref.read(screenVariablesNotifierProvider.notifier),
  );
});

class FineNotifier extends SafeStateNotifier<FineListState>
    implements IListviewNotifier {
  final FineApiService api;
  final ScreenVariablesNotifier screenController;

  FineNotifier(Ref ref, this.api, this.screenController)
      : super(ref, FineListState.initial()) {
    Future.microtask(() => loadFines());
  }

  Future<void> loadFines() async {
    if (!mounted) return;

    safeSetState(
      state.copyWith(fines: const AsyncValue.loading()),
    );
    final result = await AsyncValue.guard(
            () => runUiWithResult<List<FineApiModel>>(
              () => api.getFines(),
          showLoading: false,
          successSnack: null,
        ));

    if (!mounted) return;

    safeSetState(
      state.copyWith(fines: result),
    );
  }

  @override
  selectListviewItem(ModelToString model) {
    state = state.copyWith(
      selectedFine: model as FineApiModel,
    );
    screenController.setFine(model);
    changeFragment(EditFineScreen.id);
  }
}
