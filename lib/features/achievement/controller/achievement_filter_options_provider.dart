import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/achievement/filter/achievement_filter_options.dart';
import 'package:trus_app/features/player/repository/player_repository.dart';

final achievementPlayerLabelsProvider = StateProvider<Map<int, String>>(
  (ref) => {},
);

final achievementFilterOptionsProvider =
    FutureProvider<AchievementFilterOptions>((ref) async {
      final playerRepository = ref.read(playerRepositoryProvider);
      final cachedPlayers = playerRepository.getCachedList();

      final players = [
        ...(cachedPlayers ?? await playerRepository.fetchList()),
      ];
      players.sort(
        (first, second) =>
            first.name.toLowerCase().compareTo(second.name.toLowerCase()),
      );

      ref.read(achievementPlayerLabelsProvider.notifier).state = {
        for (final p in players)
          if (p.id != null) p.id!: p.name,
      };
      return AchievementFilterOptions(players: List.unmodifiable(players));
    });
