// ignore_for_file: public_member_api_docs

class CacheService {
  final Map<String, Object?> _cache = {};

  T? get<T>(String key) => _cache[key] as T?;
  void set(String key, Object? value) => _cache[key] = value;
  void remove(String key) => _cache.remove(key);
  void clear() => _cache.clear();
}
