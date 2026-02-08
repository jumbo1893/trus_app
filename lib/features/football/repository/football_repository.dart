import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/repository/football_api_service.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/football/table_team_api_model.dart';

import '../../../models/api/football/detail/football_match_detail.dart';
import '../../../models/api/football/detail/football_team_detail.dart';
import '../../general/cache/cached_repository.dart';
import '../../general/cache/memory_cache.dart';

final footballRepositoryProvider =
Provider<FootballRepository>((ref) {
  return FootballRepository(
    ref.read(footballApiServiceProvider),
    ref.read(memoryCacheProvider),
  );
});

class FootballRepository extends CachedRepository {
  final FootballApiService api;

  FootballRepository(
      this.api,
      MemoryCache cache,
      ) : super(cache);

  static const _listKey = 'football_match_list';
  static const _matchDetailKey = 'football_detail';
  static const _listTableKey = 'table_team_list';
  static const _teamDetailKey = 'football_team_detail';


  /// LIST
  List<FootballMatchApiModel>? getCachedList() {
    return getCached<List<FootballMatchApiModel>>(key(_listKey));
  }

  Future<List<FootballMatchApiModel>> fetchList() async {
    final data = await api.getTeamFixtures();
    setCached(key(_listKey), data);
    return data;
  }

  /// LIST
  List<TableTeamApiModel>? getCachedTableTeamList() {
    return getCached<List<TableTeamApiModel>>(key(_listTableKey));
  }

  Future<List<TableTeamApiModel>> fetchTableTeamList() async {
    final data = await api.getFootballTable();
    setCached(key(_listTableKey), data);
    return data;
  }

  /// DETAIL
  FootballMatchDetail? getCachedFootballMatchDetail(int id) {
    return getCached<FootballMatchDetail>(key(_matchDetailKey, id));
  }

  Future<FootballMatchDetail> fetchFootballMatchDetail(int id) async {
    final data = await api.getFootballMatchDetail(id);
    setCached(key(_matchDetailKey, id), data);
    return data;
  }

  FootballTeamDetail? getCachedFootballTeamDetail(int teamId) {
    return getCached<FootballTeamDetail>(key(_teamDetailKey, teamId));
  }

  Future<FootballTeamDetail> fetchFootballTeamDetail(int teamId) async {
    final data = await api.getFootballTeamDetail(teamId);
    setCached(key(_teamDetailKey, teamId), data);
    return data;
  }
}
