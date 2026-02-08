import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/cache/cache_processor.dart';
import 'package:trus_app/features/mixin/player_stats_mixin.dart';
import 'package:trus_app/features/player/repository/player_api_service.dart';
import 'package:trus_app/models/api/player/stats/player_stats.dart';

import '../../../services/ws/player_update_service.dart';
import '../../general/cache/cache_controller.dart';

final mainControllerProvider = Provider((ref) {
  final playerApiService = ref.watch(playerApiServiceProvider);
  return MainController(
      playerApiService: playerApiService, ref: ref);
});

class MainController extends CacheProcessor
    with PlayerStatsMixin {
  final PlayerApiService playerApiService;
  final _service = PlayerUpdatesService();
  final String playerStatsKey = "playerStats";

  MainController({
    required this.playerApiService,
    required Ref ref,
  }) : super(ref);

  void loadPlayerStats() {
    PlayerStats? playerStats = ref.read(cacheControllerProvider).getCachedEndpoint(PlayerStats.endpoint) as PlayerStats?;
    initPlayerStatsFields(playerStats, playerStatsKey);
  }

  Future<void> viewPlayerStats() async {
    Future.delayed(Duration.zero, () => loadPlayerStats());
  }

  void setPlayerStats(PlayerStats playerStats) {
    setPlayerStatsValue(playerStats, playerStatsKey);
  }

  /// Spuštění websocket odběru pro daného hráče
  void subscribePlayerStatsUpdates(int playerId) {
    _service.connect(
      playerId: playerId,
      onUpdate: (PlayerStats stats) {
        // tady se to propojí přímo do mixinu / UI
        setPlayerStats(stats);
      },
    );
  }

  Future<void> setupPlayerStats(int? playerId) async {
    if (playerId != null) {
      await setupEndpoint<PlayerStats>(
          () => playerApiService.getPlayerStats(playerId),
          PlayerStats.endpoint);
    }
    // po prvním načtení rozjedeme live update
    if(playerId!= null) {
      subscribePlayerStatsUpdates(playerId);
    }
  }
}
