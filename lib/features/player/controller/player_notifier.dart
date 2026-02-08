import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/player/repository/player_repository.dart';
import 'package:trus_app/features/player/screens/view_player_screen.dart';
import 'package:trus_app/features/player/state/player_list_state.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

import '../../main/screen_controller.dart';

final playerNotifierProvider =
StateNotifierProvider.autoDispose<PlayerNotifier, PlayerListState>((ref) {
  return PlayerNotifier(
    ref.read(playerRepositoryProvider),
    ref.read(screenControllerProvider),
  );
});

class PlayerNotifier extends SafeStateNotifier<PlayerListState>
    implements IListviewNotifier {

  final PlayerRepository repository;
  final ScreenController screenController;

  PlayerNotifier(this.repository, this.screenController)
      : super(PlayerListState.initial()) {
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    if (!mounted) return;

    final cached = repository.getCachedList();
    if (cached != null) {
      safeSetState(
        state.copyWith(
          players: AsyncValue.data(cached),
        ),
      );
    } else {
      safeSetState(
        state.copyWith(
          players: const AsyncValue.loading(),
        ),
      );
    }
    final result = await AsyncValue.guard(
          () => repository.fetchList(),
    );

    if (!mounted) return;
    safeSetState(
      state.copyWith(
        players: result,
      ),
    );
  }

  @override
  void selectListviewItem(ModelToString model) {
    state = state.copyWith(
      selectedPlayer: model as PlayerApiModel,
    );

    screenController.setPlayer(model);
    screenController.changeFragment(ViewPlayerScreen.id);
  }
}
