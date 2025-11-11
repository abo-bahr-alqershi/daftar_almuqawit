// ignore_for_file: public_member_api_docs

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// إعدادات قاعدة البيانات
class DatabaseConfig {
  DatabaseConfig._();

  static const String dbName = 'daftar_almuqawit.db';
  static const int dbVersion = 4; // الإصدار 4: إضافة دعم الوحدات المتعددة والأسعار الافتراضية

  /// مسار ملف قاعدة البيانات
  static Future<String> get databasePath async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, dbName);
  }
}
