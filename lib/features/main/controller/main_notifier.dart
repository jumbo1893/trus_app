import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/features/achievement/repository/achievement_repository.dart';
import 'package:trus_app/features/achievement/state/achievement_list_state.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/models/api/achievement/achievement_detail.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../main/screen_controller.dart';

final mainNotifierProvider =
StateNotifierProvider.autoDispose<MainNotifier, AchievementListState>((ref) {
  return MainNotifier(
    ref.read(achievementRepositoryProvider),
    ref.read(screenControllerProvider),
  );
});

class MainNotifier extends SafeStateNotifier<AchievementListState>
    implements IListviewNotifier {

  final AchievementRepository repository;
  final ScreenController screenController;

  MainNotifier(this.repository, this.screenController)
      : super(AchievementListState.initial()) {
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    if (!mounted) return;

    /// 1️⃣ OKAMŽITĚ zobraz cache (pokud existuje)
    final cached = repository.getCachedList();
    if (cached != null) {
      safeSetState(
        state.copyWith(
          achievements: AsyncValue.data(cached),
        ),
      );
    } else {
      /// cache není → zobraz loading
      safeSetState(
        state.copyWith(
          achievements: const AsyncValue.loading(),
        ),
      );
    }

    /// 2️⃣ NA POZADÍ zavolej API
    final result = await AsyncValue.guard(
          () => repository.fetchList(),
    );

    if (!mounted) return;

    /// 3️⃣ Přepiš state čerstvými daty (cache už je aktualizovaná)
    safeSetState(
      state.copyWith(
        achievements: result,
      ),
    );
  }

  @override
  void selectListviewItem(ModelToString model) {
    state = state.copyWith(
      selectedAchievement: model as AchievementDetail,
    );

    screenController.setAchievementDetail(model);
  }
}
