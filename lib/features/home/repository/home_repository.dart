import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/home/repository/home_api_service.dart';
import 'package:trus_app/models/api/home/home_setup.dart';

import '../../general/cache/cached_repository.dart';
import '../../general/cache/memory_cache.dart';

final homeRepositoryProvider =
Provider<HomeRepository>((ref) {
  return HomeRepository(
    ref.read(homeApiServiceProvider),
    ref.read(memoryCacheProvider),
  );
});

class HomeRepository extends CachedRepository {
  final HomeApiService api;

  HomeRepository(
      this.api,
      MemoryCache cache,
      ) : super(cache);

  static const _setupKey = 'home_setup';


  /// LIST
  HomeSetup? getCachedSetup() {
    return getCached<HomeSetup>(_setupKey);
  }

  Future<HomeSetup> fetchSetup() async {
    final data = await api.setupHome();
    setCached(_setupKey, data);
    return data;
  }


  void invalidatePlayerSetup(int? id) {
    invalidate(key(_setupKey, id));
  }
}
