import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/achievement/filter/achievement_filter_options.dart';
import 'package:trus_app/features/player/repository/player_repository.dart';

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

      return AchievementFilterOptions(players: List.unmodifiable(players));
    });
