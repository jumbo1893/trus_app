import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/player/repository/player_repository.dart';
import 'package:trus_app/features/player/screens/view_player_screen.dart';
import 'package:trus_app/features/player/state/player_list_state.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

final playerNotifierProvider =
    StateNotifierProvider.autoDispose<PlayerNotifier, PlayerListState>((ref) {
  return PlayerNotifier(
    ref,
    ref.read(playerRepositoryProvider),
    ref.read(screenVariablesNotifierProvider.notifier),
  );
});

class PlayerNotifier extends SafeStateNotifier<PlayerListState>
    implements IListviewNotifier {
  final PlayerRepository repository;
  final ScreenVariablesNotifier screenController;

  PlayerNotifier(
    Ref ref,
    this.repository,
    this.screenController,
  ) : super(ref, PlayerListState.initial()) {
    Future.microtask(_loadPlayers);
  }

  Future<void> _loadPlayers() async {
    final cached = repository.getCachedList();
    if (cached != null) {
      safeSetState(state.copyWith(players: AsyncValue.data(cached)));
    } else {
      safeSetState(state.copyWith(players: const AsyncValue.loading()));
    }

    await guardSet<List<PlayerApiModel>>(
      action: () => runUiWithResult<List<PlayerApiModel>>(
        () => repository.fetchList(),
        showLoading: false,
        successSnack: null,
      ),
      reduce: (result) => state.copyWith(players: result),
    );
  }

  @override
  void selectListviewItem(ModelToString model) {
    state = state.copyWith(
      selectedPlayer: model as PlayerApiModel,
    );

    screenController.setPlayer(model);
    changeFragment(ViewPlayerScreen.id);
  }
}
