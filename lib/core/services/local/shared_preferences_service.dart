import 'package:shared_preferences/shared_preferences.dart';

/// خدمة التخزين المحلي باستخدام SharedPreferences
/// 
/// توفر تخزين دائم للبيانات البسيطة
class SharedPreferencesService {
  SharedPreferencesService._();
  
  static final SharedPreferencesService _instance = SharedPreferencesService._();
  static SharedPreferencesService get instance => _instance;

  SharedPreferences? _prefs;

  /// تهيئة الخدمة
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw StateError('SharedPreferencesService لم يتم تهيئته');
    }
    return _prefs!;
  }

  // ========== String ==========

  /// حفظ نص
  Future<bool> setString(String key, String value) async {
    await init();
    return _preferences.setString(key, value);
  }

  /// قراءة نص
  String? getString(String key) {
    return _preferences.getString(key);
  }

  // ========== Int ==========

  /// حفظ رقم صحيح
  Future<bool> setInt(String key, int value) async {
    await init();
    return _preferences.setInt(key, value);
  }

  /// قراءة رقم صحيح
  int? getInt(String key) {
    return _preferences.getInt(key);
  }

  // ========== Double ==========

  /// حفظ رقم عشري
  Future<bool> setDouble(String key, double value) async {
    await init();
    return _preferences.setDouble(key, value);
  }

  /// قراءة رقم عشري
  double? getDouble(String key) {
    return _preferences.getDouble(key);
  }

  // ========== Bool ==========

  /// حفظ قيمة منطقية
  Future<bool> setBool(String key, bool value) async {
    await init();
    return _preferences.setBool(key, value);
  }

  /// قراءة قيمة منطقية
  bool? getBool(String key) {
    return _preferences.getBool(key);
  }

  // ========== List<String> ==========

  /// حفظ قائمة نصوص
  Future<bool> setStringList(String key, List<String> value) async {
    await init();
    return _preferences.setStringList(key, value);
  }

  /// قراءة قائمة نصوص
  List<String>? getStringList(String key) {
    return _preferences.getStringList(key);
  }

  // ========== عمليات عامة ==========

  /// التحقق من وجود مفتاح
  bool containsKey(String key) {
    return _preferences.containsKey(key);
  }

  /// حذف مفتاح
  Future<bool> remove(String key) async {
    await init();
    return _preferences.remove(key);
  }

  /// مسح جميع البيانات
  Future<bool> clear() async {
    await init();
    return _preferences.clear();
  }

  /// الحصول على جميع المفاتيح
  Set<String> getKeys() {
    return _preferences.getKeys();
  }

  /// إعادة تحميل البيانات
  Future<void> reload() async {
    await init();
    await _preferences.reload();
  }
}
