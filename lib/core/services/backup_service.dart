// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/database/database_helper.dart';
import '../../data/database/database_config.dart';

/// خدمة النسخ الاحتياطي لقاعدة البيانات (نسخ الملف كما هو)
class BackupService {
  Timer? _timer;

  Future<String> createBackup() async {
    final srcPath = await DatabaseConfig.databasePath;
    final srcFile = File(srcPath);
    if (!await srcFile.exists()) {
      throw Exception('Database file not found at $srcPath');
    }
    final dir = await getApplicationDocumentsDirectory();
    final backupPath = p.join(
      dir.path,
      'backup_${DateTime.now().millisecondsSinceEpoch}.db',
    );
    await srcFile.copy(backupPath);
    return backupPath;
  }

  Future<void> restoreBackup(String path) async {
    final backupFile = File(path);
    if (!await backupFile.exists()) {
      throw Exception('Backup file not found at $path');
    }
    // إغلاق الاتصال الحالي بقاعدة البيانات قبل الاستبدال
    await DatabaseHelper.instance.close();
    final dstPath = await DatabaseConfig.databasePath;
    await backupFile.copy(dstPath);
    // إعادة فتح القاعدة بعد الاستعادة
    await DatabaseHelper.init();
  }

  Future<void> scheduleAutoBackup({Duration interval = const Duration(days: 1)}) async {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) async {
      try {
        await createBackup();
      } catch (_) {
        // تجاهل الأخطاء في النسخ الدوري
      }
    });
  }

  Future<void> cancelAutoBackup() async {
    _timer?.cancel();
    _timer = null;
  }
}
