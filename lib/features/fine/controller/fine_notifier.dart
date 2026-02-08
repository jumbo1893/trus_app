import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/features/fine/repository/fine_api_service.dart';
import 'package:trus_app/features/fine/screens/edit_fine_screen.dart';
import 'package:trus_app/features/fine/state/fine_list_state.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/models/api/fine_api_model.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../main/screen_controller.dart';

final fineNotifierProvider =
    StateNotifierProvider.autoDispose<FineNotifier, FineListState>((ref) {
  return FineNotifier(
    ref.read(fineApiServiceProvider),
    ref.read(screenControllerProvider),
  );
});

class FineNotifier extends SafeStateNotifier<FineListState>
    implements IListviewNotifier {
  final FineApiService api;
  final ScreenController screenController;

  FineNotifier(this.api, this.screenController)
      : super(FineListState.initial()) {
    loadFines();
  }

  Future<void> loadFines() async {
    if (!mounted) return;

    safeSetState(
      state.copyWith(fines: const AsyncValue.loading()),
    );

    final result = await AsyncValue.guard(
          () => api.getFines(),
    );

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
    screenController.changeFragment(EditFineScreen.id);
  }
}
