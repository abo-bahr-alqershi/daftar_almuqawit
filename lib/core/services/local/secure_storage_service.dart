// ignore_for_file: public_member_api_docs

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// غلاف مبسّط لـ SecureStorage لحفظ البيانات الحساسة
class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> write(String key, String value) => _storage.write(key: key, value: value);
  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> delete(String key) => _storage.delete(key: key);
}
