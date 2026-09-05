import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/achievement/filter/achievement_filter.dart';

final achievementFilterNotifierProvider =
    StateNotifierProvider<AchievementFilterNotifier, AchievementFilterState>(
      (ref) => AchievementFilterNotifier(),
    );

class AchievementFilterState {
  final AchievementFilter listFilter;
  final int? playerId;
  final AchievementFilter playerFilter;

  const AchievementFilterState({
    this.listFilter = const AchievementFilter(),
    this.playerId,
    this.playerFilter = const AchievementFilter(),
  });

  AchievementFilter filterForPlayer(int playerId) =>
      this.playerId == playerId ? playerFilter : const AchievementFilter();

  AchievementFilterState copyWith({
    AchievementFilter? listFilter,
    int? playerId,
    AchievementFilter? playerFilter,
  }) {
    return AchievementFilterState(
      listFilter: listFilter ?? this.listFilter,
      playerId: playerId ?? this.playerId,
      playerFilter: playerFilter ?? this.playerFilter,
    );
  }
}

class AchievementFilterNotifier extends StateNotifier<AchievementFilterState> {
  AchievementFilterNotifier() : super(const AchievementFilterState());

  void setListFilter(AchievementFilter filter) {
    state = state.copyWith(listFilter: filter);
  }

  void setPlayerFilter(int playerId, AchievementFilter filter) {
    state = AchievementFilterState(
      listFilter: state.listFilter,
      playerId: playerId,
      playerFilter: filter,
    );
  }

  void clearListFilter() {
    if (!state.listFilter.isActive) return;
    state = state.copyWith(listFilter: const AchievementFilter());
  }

  void clearPlayerFilter() {
    if (state.playerId == null && !state.playerFilter.isActive) return;
    state = AchievementFilterState(listFilter: state.listFilter);
  }

  void clearAll() {
    state = const AchievementFilterState();
  }
}
