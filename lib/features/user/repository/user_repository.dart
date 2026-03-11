import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/auth/repository/auth_repository.dart';
import 'package:trus_app/models/api/auth/user_api_model.dart';

import '../../general/cache/cached_repository.dart';
import '../../general/cache/memory_cache.dart';

final userRepositoryProvider =
Provider<UserRepository>((ref) {
  return UserRepository(
    ref.read(authRepositoryProvider),
    ref.read(memoryCacheProvider),
  );
});

class UserRepository extends CachedRepository {
  final AuthRepository api;

  UserRepository(
      this.api,
      MemoryCache cache,
      ) : super(cache);

  static const _listKey = 'user_list_team_roles';


  /// LIST
  List<UserApiModel>? getCachedList() {
    return getCached<List<UserApiModel>>(_listKey);
  }

  Future<List<UserApiModel>> fetchList() async {
    final data = await api.getUsers(true);
    setCached(_listKey, data);
    return data;
  }

  void invalidateList() {
    invalidate(_listKey);
  }
}
