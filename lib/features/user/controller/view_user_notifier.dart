import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/notifier/global_variables_notifier.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/user/state/view_user_state.dart';
import 'package:trus_app/models/api/auth/user_setup.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

import '../../../common/widgets/notifier/dropdown/i_dropdown_notifier.dart';
import '../../../models/api/interfaces/dropdown_item.dart';
import '../../auth/repository/auth_repository.dart';
import '../../general/notifier/safe_state_notifier.dart';
import '../../general/repository/api_result.dart';

final viewUserNotifierProvider =
    StateNotifierProvider.autoDispose<ViewUserNotifier, ViewUserState>((ref) {
      return ViewUserNotifier(
        ref: ref,
        authApiService: ref.read(authRepositoryProvider),
      );
    });

class ViewUserNotifier extends SafeStateNotifier<ViewUserState>
    implements IDropdownNotifier {
  final AuthRepository authApiService;
  bool _savingPlayer = false;

  ViewUserNotifier({required Ref ref, required this.authApiService})
    : super(
        ref,
        const ViewUserState(
          name: "",
          email: "",
          eligiblePlayersToPairWith: AsyncValue.data([]),
          userTeamRole: null,
          otherRoles: "",
        ),
      ) {
    Future.microtask(() => _load());
  }

  /// =========================
  /// PUBLIC API
  /// =========================
  Future<void> _load() async {
    final setup = await runUiWithResult<UserSetup>(
      () => authApiService.getUserSetup(),
      showLoading: true,
      successSnack: null,
    );
    if (!mounted) return;

    _applySetup(setup);
  }

  /// =========================
  /// APPLY SETUP → STATE
  /// =========================
  void _applySetup(UserSetup setup) {
    final legacyGlobals = ref.read(globalVariablesControllerProvider);
    final globals = ref.read(globalVariablesProvider.notifier);
    var selectedAppTeam =
        ref.read(globalVariablesProvider).appTeam ?? legacyGlobals.appTeam;
    final currentRole = setup.currentUser.getCurrentUserTeamRole(
      selectedAppTeam?.id,
    );
    if (currentRole != null) {
      selectedAppTeam = currentRole.appTeam;
    }

    if (selectedAppTeam != null) {
      legacyGlobals.setAppTeam(selectedAppTeam);
      globals.setAppTeam(selectedAppTeam);
    }

    final selectedPlayer = setup.primaryPlayer.id == 0
        ? null
        : setup.primaryPlayer;
    legacyGlobals.setPlayerApiModel(selectedPlayer);
    globals.setPlayer(selectedPlayer);

    state = state.copyWith(
      name: setup.currentUser.name ?? "",
      userId: setup.currentUser.id,
      email: setup.currentUser.mail ?? "",
      eligiblePlayersToPairWith: AsyncValue.data(
        setup.eligiblePlayersToPairWith,
      ),
      selectedPlayer: setup.primaryPlayer,
      userTeamRole: currentRole,
      otherRoles: setup.currentUser.getDescriptionOfOtherRoles(
        selectedAppTeam?.id,
      ),
    );
  }

  Future<void> _savePlayer(
    PlayerApiModel playerApiModel,
    PlayerApiModel? previous,
  ) async {
    final removedPlayer = playerApiModel.id == 0;
    final successSnack = removedPlayer
        ? "Z profilu odebrán hráč"
        : "Do profilu přidán hráč ${playerApiModel.name}";
    final globals = ref.read(globalVariablesProvider.notifier);
    try {
      final result = await runUi<void>(
        () => authApiService.setUserPlayerId(playerApiModel),
        showLoading: true,
        successSnack: successSnack,
      );
      if (!mounted) return;
      if (result case ApiFieldError<void>()) {
        final fallbackMessage = result.fieldErrors.isEmpty
            ? 'Hráče se nepodařilo spárovat.'
            : result.fieldErrors.values.first;
        ui.showErrorDialog(result.fieldErrors['player'] ?? fallbackMessage);
      }
      if (result is! ApiSuccess<void>) {
        if (previous != null) state = state.copyWith(selectedPlayer: previous);
        return;
      }
      globals.setPlayer(removedPlayer ? null : playerApiModel);
      ref
          .read(globalVariablesControllerProvider)
          .setPlayerApiModel(removedPlayer ? null : playerApiModel);
    } finally {
      _savingPlayer = false;
    }
  }

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  @override
  selectDropdown(DropdownItem item) {
    if (_savingPlayer || item is! PlayerApiModel) return;
    final previous = state.selectedPlayer as PlayerApiModel?;
    if (previous?.id == item.id) return;
    _savingPlayer = true;
    state = state.copyWith(selectedPlayer: item);
    _savePlayer(item, previous);
  }
}
