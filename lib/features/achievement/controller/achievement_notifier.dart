import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/features/achievement/repository/achievement_repository.dart';
import 'package:trus_app/features/achievement/state/achievement_list_state.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/models/api/achievement/achievement_detail.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../screens/view_achievement_detail_screen.dart';

final achievementNotifierProvider =
StateNotifierProvider.autoDispose<AchievementNotifier, AchievementListState>((ref) {
  return AchievementNotifier(
    ref,
    ref.read(achievementRepositoryProvider),
    ref.read(screenVariablesNotifierProvider.notifier),
  );
});

class AchievementNotifier extends SafeStateNotifier<AchievementListState>
    implements IListviewNotifier {

  final AchievementRepository repository;
  final ScreenVariablesNotifier screenController;

  AchievementNotifier(Ref ref, this.repository, this.screenController)
      : super(ref, AchievementListState.initial()) {
    Future.microtask(() => _loadAchievements());
  }

  Future<void> _loadAchievements() async {
    final cached = repository.getCachedList();
    if (cached != null) {
      safeSetState(state.copyWith(achievements: AsyncValue.data(cached)));
    } else {
      safeSetState(state.copyWith(achievements: const AsyncValue.loading()));
    }

    await guardSet<List<AchievementDetail>>(
      action: () => runUiWithResult<List<AchievementDetail>>(
            () => repository.fetchList(),
        showLoading: false,
        successSnack: null,
      ),
      reduce: (result) => state.copyWith(achievements: result),
    );
  }

  @override
  void selectListviewItem(ModelToString model) {
    state = state.copyWith(
      selectedAchievement: model as AchievementDetail,
    );

    screenController.setAchievementDetail(model);
    changeFragment(ViewAchievementDetailScreen.id);
  }
}
