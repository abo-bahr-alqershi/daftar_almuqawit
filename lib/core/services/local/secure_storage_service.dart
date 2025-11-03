import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// خدمة التخزين الآمن للبيانات الحساسة
/// 
/// تستخدم FlutterSecureStorage لحفظ البيانات بشكل مشفر
class SecureStorageService {
  SecureStorageService._();
  
  static final SecureStorageService _instance = SecureStorageService._();
  static SecureStorageService get instance => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // ========== عمليات الكتابة والقراءة ==========

  /// كتابة قيمة
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw Exception('فشل حفظ البيانات الآمنة: $e');
    }
  }

  /// قراءة قيمة
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw Exception('فشل قراءة البيانات الآمنة: $e');
    }
  }

  /// حذف قيمة
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw Exception('فشل حذف البيانات الآمنة: $e');
    }
  }

  /// قراءة جميع البيانات
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      throw Exception('فشل قراءة جميع البيانات: $e');
    }
  }

  /// حذف جميع البيانات
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('فشل حذف جميع البيانات: $e');
    }
  }

  /// التحقق من وجود مفتاح
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      throw Exception('فشل التحقق من المفتاح: $e');
    }
  }

  // ========== مفاتيح محددة للتطبيق ==========

  /// حفظ رمز المصادقة
  Future<void> saveAuthToken(String token) => write('auth_token', token);

  /// قراءة رمز المصادقة
  Future<String?> getAuthToken() => read('auth_token');

  /// حذف رمز المصادقة
  Future<void> deleteAuthToken() => delete('auth_token');

  /// حفظ معرف المستخدم
  Future<void> saveUserId(String userId) => write('user_id', userId);

  /// قراءة معرف المستخدم
  Future<String?> getUserId() => read('user_id');

  /// حذف معرف المستخدم
  Future<void> deleteUserId() => delete('user_id');

  /// حفظ مفتاح التشفير
  Future<void> saveEncryptionKey(String key) => write('encryption_key', key);

  /// قراءة مفتاح التشفير
  Future<String?> getEncryptionKey() => read('encryption_key');

  /// حذف مفتاح التشفير
  Future<void> deleteEncryptionKey() => delete('encryption_key');
}
