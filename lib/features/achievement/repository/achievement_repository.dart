import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/api/achievement/achievement_detail.dart';
import '../../general/cache/cached_repository.dart';
import '../../general/cache/memory_cache.dart';
import 'achievement_api_service.dart';

final achievementRepositoryProvider =
Provider<AchievementRepository>((ref) {
  return AchievementRepository(
    ref.read(achievementApiServiceProvider),
    ref.read(memoryCacheProvider),
  );
});

class AchievementRepository extends CachedRepository {
  final AchievementApiService api;

  AchievementRepository(
      this.api,
      MemoryCache cache,
      ) : super(cache);

  static const _listKey = 'achievement_list';
  static const _detailKey = 'achievement_detail';

  /// LIST
  List<AchievementDetail>? getCachedList() {
    return getCached<List<AchievementDetail>>(_listKey);
  }

  Future<List<AchievementDetail>> fetchList() async {
    final data = await api.getAllDetailed();
    setCached(_listKey, data);
    return data;
  }

  /// DETAIL
  AchievementDetail? getCachedDetail(int id) {
    return getCached<AchievementDetail>(key(_detailKey, id));
  }

  Future<AchievementDetail> fetchDetail(int id) async {
    final data = await api.getAchievementDetail(id);
    setCached(key(_detailKey, id), data);
    return data;
  }

  void invalidateDetail(int id) {
    invalidate(key(_detailKey, id));
  }

  void invalidateList() {
    invalidate(_listKey);
  }
}
