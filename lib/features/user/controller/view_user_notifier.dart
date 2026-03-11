import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/notifier/global_variables_notifier.dart';
import 'package:trus_app/features/general/state/global_variables_state.dart';
import 'package:trus_app/features/user/state/view_user_state.dart';
import 'package:trus_app/models/api/auth/user_setup.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

import '../../../common/widgets/notifier/dropdown/i_dropdown_notifier.dart';
import '../../../models/api/interfaces/dropdown_item.dart';
import '../../auth/repository/auth_repository.dart';
import '../../general/notifier/safe_state_notifier.dart';
import '../../home/screens/home_screen.dart';
import '../../main/controller/screen_notifier.dart';

final viewUserNotifierProvider = StateNotifierProvider.autoDispose
    <ViewUserNotifier, ViewUserState>((ref) {
  return ViewUserNotifier(
    ref: ref,
    authApiService: ref.read(authRepositoryProvider),
    globalVariablesState: ref.watch(globalVariablesProvider),
  );
});

class ViewUserNotifier
    extends SafeStateNotifier<ViewUserState> implements IDropdownNotifier {
  final AuthRepository authApiService;
  final GlobalVariablesState globalVariablesState;

  ViewUserNotifier({
    required Ref ref,
    required this.authApiService,
    required this.globalVariablesState,
  }) : super(
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
    state = state.copyWith(
      name: setup.currentUser.name ?? "",
      email: setup.currentUser.mail ?? "",
      eligiblePlayersToPairWith: AsyncValue.data(setup.eligiblePlayersToPairWith),
      selectedPlayer: setup.primaryPlayer,
      userTeamRole: setup.currentUser.getCurrentUserTeamRole(globalVariablesState.appTeam!.id),
      otherRoles: setup.currentUser.getDescriptionOfOtherRoles(globalVariablesState.appTeam!.id),
    );
  }

  Future<void> commit() async {
    PlayerApiModel playerApiModel = state.selectedPlayer as PlayerApiModel;
    bool removedPlayer = playerApiModel.id == 0;
    String successSnack = removedPlayer ? "Z profilu odebrán hráč" : "Do profilu přidán hráč ${playerApiModel.name}";
    final globals = ref.read(globalVariablesProvider.notifier);
    final screen = ref.read(screenNotifierProvider.notifier);
    await runUiWithResult<void>(
          () => authApiService
              .setUserPlayerId(state.selectedPlayer as PlayerApiModel),
      showLoading: true,
      successSnack: successSnack,
    );
    if (!mounted) return;
    if(removedPlayer) {
      globals.setPlayer(null);
    }
    else {
      globals.setPlayer(playerApiModel);
    }
    screen.changeFragment(HomeScreen.id);
  }

  @override
  selectDropdown(DropdownItem item) {
    state = state.copyWith(selectedPlayer: item);
  }
}
