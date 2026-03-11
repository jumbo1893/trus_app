import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/features/auth/repository/auth_repository.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/user/state/user_state.dart';
import 'package:trus_app/models/api/auth/user_api_model.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../repository/user_repository.dart';

final userNotifierProvider =
    StateNotifierProvider.autoDispose<UserNotifier, UserState>((ref) {
  return UserNotifier(
    ref,
    ref.read(userRepositoryProvider),
    ref.read(authRepositoryProvider),
  );
});

class UserNotifier extends SafeStateNotifier<UserState>
    implements IListviewNotifier {
  final UserRepository repository;
  final AuthRepository authRepository;

  UserNotifier(
    Ref ref,
    this.repository,
    this.authRepository,
  ) : super(ref, UserState.initial()) {
    Future.microtask(_loadUsers);
  }

  Future<void> _loadUsers() async {
    final cached = repository.getCachedList();
    if (cached != null) {
      safeSetState(state.copyWith(users: AsyncValue.data(cached)));
    } else {
      safeSetState(state.copyWith(users: const AsyncValue.loading()));
    }

    await guardSet<List<UserApiModel>>(
      action: () => runUiWithResult<List<UserApiModel>>(
        () => repository.fetchList(),
        showLoading: false,
        successSnack: null,
      ),
      reduce: (result) => state.copyWith(users: result),
    );
  }

  @override
  Future<void> selectListviewItem(ModelToString model) async {
    UserApiModel user = model as UserApiModel;
    ui.showConfirmationDialog(
        user.admin!
            ? "Opravdu chcete odebrat práva uživateli ${user.name}?"
            : "Opravdu chcete zpřístupnit práva uživateli ${user.name}?",
        () async {
      await changePermissions(user);
    });
  }

  Future<void> changePermissions(UserApiModel user) async {
    if (user.teamRoles == null || user.teamRoles!.isEmpty) {
      ui.showSnack("Tomuto uživateli nelze zadat práva, obrať se na admina");
      return;
    }
    if (user == await authRepository.getCurrentUserData()) {
      ui.showSnack("Nemůžeš změnit práva sám sobě");
      return;
    }
    String newRole = user.teamRoles![0].getOppositeRole();

    runUiWithResult<void>(
      () => authRepository.setUserWritePermissions(
          user.teamRoles![0].id!, newRole),
      showLoading: true,
      successSnack: "Práva pro ${user.name} úspěšně změněna",
    );
    changeFragment(HomeScreen.id);
  }
}
