import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/player/repository/player_api_service.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/api/player/player_setup.dart';
import 'package:trus_app/models/api/player/stats/player_stats.dart';

import '../../general/cache/cached_repository.dart';
import '../../general/cache/memory_cache.dart';

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepository(
    ref.read(playerApiServiceProvider),
    ref.read(memoryCacheProvider),
  );
});

class PlayerRepository extends CachedRepository {
  final PlayerApiService api;

  PlayerRepository(this.api, MemoryCache cache) : super(cache);

  static const _listKey = 'player_list';
  static const _setupKey = 'player_setup';
  static const _statsKey = 'player_stats';

  /// LIST
  List<PlayerApiModel>? getCachedList() {
    return getCached<List<PlayerApiModel>>(_listKey);
  }

  Future<List<PlayerApiModel>> fetchList() async {
    final data = await api.getPlayers();
    setCached(_listKey, data);
    return data;
  }

  /// DETAIL
  PlayerSetup? getCachedPlayerSetup(int? id) {
    return getCached<PlayerSetup>(key(_setupKey, id));
  }

  Future<PlayerSetup> fetchPlayerSetup(int? id) async {
    final data = await api.setupPlayer(id);
    setCached(key(_setupKey, id), data);
    return data;
  }

  String _playerStatsKey(int playerId, int appTeamId) {
    return key(_statsKey, '$appTeamId-$playerId');
  }

  PlayerStats? getCachedPlayerStats(int playerId, int appTeamId) {
    return getCached<PlayerStats>(_playerStatsKey(playerId, appTeamId));
  }

  Future<PlayerStats> fetchPlayerStats(int playerId, int appTeamId) async {
    final data = await api.getPlayerStats(playerId);
    setCached(_playerStatsKey(playerId, appTeamId), data);
    return data;
  }

  void invalidatePlayerSetup(int? id) {
    invalidate(key(_setupKey, id));
  }

  void invalidatePlayerStats(int playerId, int appTeamId) {
    invalidate(_playerStatsKey(playerId, appTeamId));
  }

  void invalidateList() {
    invalidate(_listKey);
  }
}
