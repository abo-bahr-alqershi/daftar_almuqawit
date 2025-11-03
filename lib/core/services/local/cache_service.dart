/// خدمة التخزين المؤقت في الذاكرة
/// 
/// توفر تخزين سريع للبيانات المؤقتة في الذاكرة
class CacheService {
  CacheService._();
  
  static final CacheService _instance = CacheService._();
  static CacheService get instance => _instance;

  final Map<String, Object?> _cache = {};
  final Map<String, DateTime> _expiryTimes = {};

  /// حفظ قيمة في الذاكرة
  void set<T>(String key, T value, {Duration? ttl}) {
    _cache[key] = value;
    if (ttl != null) {
      _expiryTimes[key] = DateTime.now().add(ttl);
    }
  }

  /// الحصول على قيمة من الذاكرة
  T? get<T>(String key) {
    // التحقق من انتهاء الصلاحية
    if (_expiryTimes.containsKey(key)) {
      if (DateTime.now().isAfter(_expiryTimes[key]!)) {
        remove(key);
        return null;
      }
    }
    
    return _cache[key] as T?;
  }

  /// التحقق من وجود قيمة
  bool has(String key) {
    if (_expiryTimes.containsKey(key)) {
      if (DateTime.now().isAfter(_expiryTimes[key]!)) {
        remove(key);
        return false;
      }
    }
    return _cache.containsKey(key);
  }

  /// حذف قيمة من الذاكرة
  void remove(String key) {
    _cache.remove(key);
    _expiryTimes.remove(key);
  }

  /// مسح جميع البيانات
  void clear() {
    _cache.clear();
    _expiryTimes.clear();
  }

  /// مسح البيانات المنتهية الصلاحية
  void clearExpired() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    _expiryTimes.forEach((key, expiryTime) {
      if (now.isAfter(expiryTime)) {
        expiredKeys.add(key);
      }
    });
    
    for (final key in expiredKeys) {
      remove(key);
    }
  }

  /// الحصول على حجم الذاكرة
  int get size => _cache.length;

  /// التحقق من فراغ الذاكرة
  bool get isEmpty => _cache.isEmpty;

  /// التحقق من عدم فراغ الذاكرة
  bool get isNotEmpty => _cache.isNotEmpty;
}
