import 'package:flutter_riverpod/flutter_riverpod.dart';

final memoryCacheProvider = Provider<MemoryCache>((ref) {
  return MemoryCache();
});

class MemoryCache {
  final Map<String, Object?> _cache = {};

  T? get<T>(String key) {
    return _cache[key] as T?;
  }

  void set<T>(String key, T value) {
    _cache[key] = value;
  }

  void invalidate(String key) {
    _cache.remove(key);
  }
}

