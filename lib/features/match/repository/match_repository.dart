import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/match/match_setup.dart';
import 'package:trus_app/models/api/match/match_stats.dart';

import '../../general/cache/cached_repository.dart';
import '../../general/cache/memory_cache.dart';
import 'match_api_service.dart';

final matchRepositoryProvider =
Provider<MatchRepository>((ref) {
  return MatchRepository(
    ref.read(matchApiServiceProvider),
    ref.read(memoryCacheProvider),
  );
});

class MatchRepository extends CachedRepository {
  final MatchApiService api;

  MatchRepository(
      this.api,
      MemoryCache cache,
      ) : super(cache);

  static const _listKey = 'match_list';
  static const _setupKey = 'match_setup';
  static const _statsKey = 'match_stats';



  /// LIST
  List<MatchApiModel>? getCachedList(int seasonId) {
    return getCached<List<MatchApiModel>>(key(_setupKey, seasonId));
  }

  Future<List<MatchApiModel>> fetchList(int seasonId) async {
    final data = await api.getMatchesBySeason(seasonId);
    setCached(key(_setupKey, seasonId), data);
    return data;
  }

  /// DETAIL
  MatchSetup? getCachedMatchSetup(int? id) {
    return getCached<MatchSetup>(key(_setupKey, id));
  }

  Future<MatchSetup> fetchMatchSetup(int? id) async {
    final data = await api.setupMatch(id);
    setCached(key(_setupKey, id), data);
    return data;
  }

  /// STATS
  MatchStats? getCachedMatchStats(int id) {
    return getCached<MatchStats>(key(_statsKey, id));
  }

  Future<MatchStats> fetchMatchStats(int id) async {
    final data = await api.getMatchStats(id);
    setCached(key(_statsKey, id), data);
    return data;
  }

  void invalidateMatchSetup(int? id) {
    invalidate(key(_statsKey, id));
  }

  void invalidateMatchStats(int? id) {
    invalidate(key(_setupKey, id));
  }

  void invalidateMatchDetailData(int? id) {
    invalidateMatchSetup(id);
    invalidateMatchStats(id);
  }

  void invalidateList() {
    invalidate(_listKey);
  }
}
