import 'memory_cache.dart';

abstract class CachedRepository {
  final MemoryCache cache;

  CachedRepository(this.cache);

  /// helper na klíče
  String key(String base, [Object? id]) =>
      id == null ? base : '$base-$id';

  T? getCached<T>(String key) => cache.get<T>(key);

  void setCached<T>(String key, T value) => cache.set(key, value);

  void invalidate(String key) => cache.invalidate(key);
}
