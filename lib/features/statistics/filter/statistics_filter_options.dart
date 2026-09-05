import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/player/repository/player_repository.dart';
import 'package:trus_app/features/season/repository/season_api_service.dart';
import 'package:trus_app/features/statistics/repository/stats_api_service.dart';
import 'package:trus_app/features/statistics/stat_args.dart';
import 'package:trus_app/models/api/fine_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

final statisticsSeasonsProvider = FutureProvider.autoDispose(
  (ref) => ref.read(seasonApiServiceProvider).getSeasons(false, true, false),
);

final statisticsFilterOptionsProvider = FutureProvider.autoDispose
    .family<StatisticsFilterOptions, StatsArgs>((ref, args) async {
      final seasons = ref.watch(statisticsSeasonsProvider.future);
      final repository = ref.read(playerRepositoryProvider);
      final cachedPlayers = repository.getCachedList();
      final players = args.matchOrPlayer
          ? (cachedPlayers == null
                ? repository.fetchList()
                : Future.value(cachedPlayers))
          : Future.value(<PlayerApiModel>[]);
      final opponents = args.matchOrPlayer
          ? Future.value(<String>[])
          : ref.read(statsApiServiceProvider).getOpponents();
      final fines = args.api == receivedFineApi
          ? ref.read(statsApiServiceProvider).getFineOptions()
          : Future.value(<FineApiModel>[]);
      final results = await Future.wait<Object>([
        seasons,
        players,
        opponents,
        fines,
      ]);
      return StatisticsFilterOptions(
        seasons: results[0] as List<SeasonApiModel>,
        players: [...results[1] as List<PlayerApiModel>]
          ..sort((a, b) => a.name.compareTo(b.name)),
        opponents: results[2] as List<String>,
        fines: [...results[3] as List<FineApiModel>]
          ..sort((a, b) => a.name.compareTo(b.name)),
      );
    });

class StatisticsFilterOptions {
  final List<SeasonApiModel> seasons;
  final List<PlayerApiModel> players;
  final List<String> opponents;
  final List<FineApiModel> fines;
  const StatisticsFilterOptions({
    required this.seasons,
    required this.players,
    required this.opponents,
    required this.fines,
  });
}
