import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/footbar/repository/footbar_api_service.dart';
import 'package:trus_app/models/api/footbar/footbar_profile.dart';

import '../../general/cache/cached_repository.dart';
import '../../general/cache/memory_cache.dart';

final footbarRepositoryProvider =
Provider<FootbarRepository>((ref) {
  return FootbarRepository(
    ref.read(footbarApiServiceProvider),
    ref.read(memoryCacheProvider),
  );
});

class FootbarRepository extends CachedRepository {
  final FootbarApiService api;

  FootbarRepository(
      this.api,
      MemoryCache cache,
      ) : super(cache);

  static const _lastSync = 'footbar_last_sync';
  static const _profile = 'footbar_profile';
  static const _statsKey = 'player_stats';


  DateTime? getCachedLastSync() {
    return getCached<DateTime?>(_lastSync);
  }

  Future<DateTime?> fetchLastSync() async {
    final data = await api.getSessionLastSyncDate();
    setCached(_lastSync, data);
    return data;
  }

  FootbarProfile? getCachedProfile() {
    return getCached<FootbarProfile>(_profile);
  }

  Future<FootbarProfile> fetchProfile() async {
    final data = await api.getCurrentProfile();
    setCached(_profile, data);
    return data;
  }

  void invalidateLastSync() {
    invalidate(_lastSync);
  }

  void invalidateProfile() {
    invalidate(_profile);
  }
}
