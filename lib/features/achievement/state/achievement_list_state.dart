import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_state.dart';

import '../../../models/api/achievement/achievement_detail.dart';

class AchievementListState implements IListviewState {
  final AsyncValue<List<AchievementDetail>> achievements;
  final AchievementDetail? selectedAchievement;

  AchievementListState({
    required this.achievements,
    required this.selectedAchievement,
  });

  factory AchievementListState.initial() => AchievementListState(
    achievements: const AsyncValue.loading(),
    selectedAchievement: null,
      );

  AchievementListState copyWith({
    AsyncValue<List<AchievementDetail>>? achievements,
    AchievementDetail? selectedAchievement,
  }) {
    return AchievementListState(
      achievements: achievements ?? this.achievements,
      selectedAchievement: selectedAchievement ?? this.selectedAchievement,
        );
  }

  @override
  AsyncValue<List<AchievementDetail>> getListViewItems() {
    return achievements;
  }
}
