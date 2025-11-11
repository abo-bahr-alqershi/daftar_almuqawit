// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/database/database_helper.dart';
import '../../data/database/database_config.dart';
import 'cloud_storage_service.dart';
import 'google_drive_service.dart';
export 'google_drive_service.dart' show DriveBackupInfo;
import 'logger_service.dart';

/// خدمة النسخ الاحتياطي لقاعدة البيانات
///
/// ⚠️ ملاحظة مهمة - الفرق بين النسخ الاحتياطي والمزامنة:
///
/// 1. النسخ الاحتياطي (هذه الخدمة):
///    - نسخة كاملة من قاعدة البيانات
///    - يُحفظ على Google Drive
///    - يُستخدم للاستعادة الكاملة عند الحاجة
///    - يُنفذ يدوياً أو بجدولة (يومي/أسبوعي)
///
/// 2. المزامنة (storage_sync_coordinator):
///    - تحديث مستمر للبيانات بين الأجهزة
///    - يُحفظ على Firebase Storage
///    - يُستخدم لمشاركة البيانات بين عدة أجهزة
///    - يُنفذ تلقائياً عند كل تغيير
///
/// الميزات:
/// - نسخ محلي لقاعدة البيانات
/// - رفع إلى Google Drive (للنسخ الاحتياطي الآمن)
/// - جدولة نسخ احتياطي دوري
/// - استعادة من النسخ المحلية أو Google Drive
class BackupService {
  // ❌ لا تستخدم CloudStorageService هنا - هذا للمزامنة فقط
  // final CloudStorageService _cloudStorage = CloudStorageService.instance;

  final GoogleDriveService _googleDrive = GoogleDriveService.instance;
  final LoggerService _logger = LoggerService();
  Timer? _timer;

  /// إنشاء نسخة احتياطية محلية فقط
  ///
  /// ⚠️ ملاحظة: لا يتم الرفع لـ Firebase Storage هنا
  /// هذه الدالة للنسخ المحلي فقط
  /// للرفع إلى Google Drive استخدم createBackupToDrive()
  ///
  /// Returns: مسار النسخة المحلية
  Future<String> createBackup({Function(double progress)? onProgress}) async {
    try {
      _logger.info('📦 بدء إنشاء نسخة احتياطية محلية...');

      // نسخ قاعدة البيانات محلياً
      final srcPath = await DatabaseConfig.databasePath;
      final srcFile = File(srcPath);

      if (!await srcFile.exists()) {
        throw Exception('Database file not found at $srcPath');
      }

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupPath = p.join(dir.path, 'backup_local_$timestamp.db');

      _logger.info('نسخ قاعدة البيانات من $srcPath إلى $backupPath');
      await srcFile.copy(backupPath);

      final fileSize = await srcFile.length();
      _logger.info(
        '✅ تم إنشاء النسخة المحلية بنجاح (${(fileSize / 1024).toStringAsFixed(1)} KB)',
      );

      onProgress?.call(1.0);

      return backupPath;
    } catch (e, stackTrace) {
      _logger.error(
        'فشل إنشاء النسخة الاحتياطية',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// استعادة من نسخة احتياطية محلية
  Future<void> restoreBackup(String path) async {
    try {
      _logger.info('بدء استعادة من النسخة الاحتياطية: $path');

      final backupFile = File(path);
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found at $path');
      }

      // إغلاق الاتصال الحالي بقاعدة البيانات قبل الاستبدال
      _logger.info('إغلاق قاعدة البيانات...');
      await DatabaseHelper.instance.close();

      // استبدال قاعدة البيانات
      final dstPath = await DatabaseConfig.databasePath;
      _logger.info('استبدال قاعدة البيانات: $dstPath');
      await backupFile.copy(dstPath);

      // إعادة فتح القاعدة بعد الاستعادة
      _logger.info('إعادة فتح قاعدة البيانات...');
      await DatabaseHelper.init();

      _logger.info('تمت الاستعادة بنجاح');
    } catch (e, stackTrace) {
      _logger.error('فشلت عملية الاستعادة', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// استعادة من نسخة احتياطية محلية أو من Google Drive
  Future<void> restoreFromCloud(
    String cloudPath, {
    Function(double progress)? onDownloadProgress,
  }) async {
    try {
      _logger.info(
        '❌ تحذير: هذه الدالة قديمة - استخدم restoreFromDrive() بدلاً منها',
      );
      _logger.info('⬇️ بدء تحميل النسخة من Google Drive: $cloudPath');

      // تحميل الملف من Google Drive
      final dir = await getApplicationDocumentsDirectory();
      final localPath = p.join(dir.path, 'restore_temp.db');

      await _googleDrive.downloadBackup(
        cloudPath,
        localPath,
        onProgress: onDownloadProgress,
      );

      _logger.info('تم تحميل النسخة بنجاح، بدء الاستعادة...');

      // استعادة من الملف المحلي
      await restoreBackup(localPath);

      // حذف الملف المؤقت
      await File(localPath).delete();

      _logger.info('✅ تمت الاستعادة من Google Drive بنجاح');
    } catch (e, stackTrace) {
      _logger.error(
        'فشلت الاستعادة من Google Drive',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ========== Google Drive - النسخ الاحتياطي ==========
  //
  // ⚠️ ملاحظة: Google Drive مخصص للنسخ الاحتياطي الكامل فقط
  // للمزامنة المستمرة بين الأجهزة، استخدم storage_sync_coordinator

  /// إنشاء نسخة احتياطية ورفعها إلى Google Drive
  Future<String> createBackupToDrive({
    Function(double progress)? onUploadProgress,
  }) async {
    try {
      _logger.info('🚀 بدء إنشاء نسخة احتياطية إلى Google Drive...');

      // التحقق من تسجيل الدخول
      if (!_googleDrive.isSignedIn) {
        _logger.warning(
          '⚠️ لم يتم تسجيل الدخول إلى Google Drive - محاولة تسجيل دخول صامت...',
        );
        final signedIn = await _googleDrive.signInSilently();
        if (!signedIn) {
          throw Exception('يجب تسجيل الدخول إلى Google Drive أولاً');
        }
      }

      // 1. إنشاء نسخة محلية
      final srcPath = await DatabaseConfig.databasePath;
      final srcFile = File(srcPath);

      if (!await srcFile.exists()) {
        throw Exception('Database file not found at $srcPath');
      }

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupPath = p.join(dir.path, 'backup_drive_$timestamp.db');

      _logger.info('نسخ قاعدة البيانات...');
      await srcFile.copy(backupPath);

      final fileSize = await srcFile.length();
      _logger.info(
        'تم إنشاء النسخة المحلية (${(fileSize / 1024).toStringAsFixed(1)} KB)',
      );

      // 2. رفع إلى Google Drive
      _logger.info('📤 رفع النسخة إلى Google Drive...');

      final driveFileId = await _googleDrive.uploadBackup(
        backupPath,
        onProgress: (progress) {
          _logger.info('تقدم الرفع: ${(progress * 100).toStringAsFixed(0)}%');
          onUploadProgress?.call(progress);
        },
      );

      _logger.info('✅ تم رفع النسخة إلى Google Drive بنجاح!');
      _logger.info('📁 معرف الملف: $driveFileId');

      // حذف النسخة المحلية المؤقتة
      await File(backupPath).delete();

      return driveFileId;
    } catch (e, stackTrace) {
      _logger.error(
        '❌ فشل النسخ الاحتياطي إلى Google Drive',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// استعادة من Google Drive
  Future<void> restoreFromDrive(
    String driveFileId, {
    Function(double progress)? onDownloadProgress,
  }) async {
    try {
      _logger.info('⬇️ بدء الاستعادة من Google Drive...');

      // التحقق من تسجيل الدخول
      if (!_googleDrive.isSignedIn) {
        throw Exception('يجب تسجيل الدخول إلى Google Drive أولاً');
      }

      // تحميل من Google Drive
      final dir = await getApplicationDocumentsDirectory();
      final localPath = p.join(dir.path, 'restore_drive_temp.db');

      await _googleDrive.downloadBackup(
        driveFileId,
        localPath,
        onProgress: onDownloadProgress,
      );

      _logger.info('تم تحميل النسخة، بدء الاستعادة...');

      // استعادة من الملف المحلي
      await restoreBackup(localPath);

      // حذف الملف المؤقت
      await File(localPath).delete();

      _logger.info('✅ تمت الاستعادة من Google Drive بنجاح');
    } catch (e, stackTrace) {
      _logger.error(
        '❌ فشلت الاستعادة من Google Drive',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// الحصول على قائمة النسخ الاحتياطية من Google Drive
  Future<List<DriveBackupInfo>> getDriveBackups() async {
    try {
      if (!_googleDrive.isSignedIn) {
        await _googleDrive.signInSilently();
      }
      return await _googleDrive.listBackups();
    } catch (e) {
      _logger.error('فشل جلب قائمة النسخ من Google Drive', error: e);
      return [];
    }
  }

  /// تسجيل الدخول إلى Google Drive
  Future<bool> signInToGoogleDrive() async {
    return await _googleDrive.signIn();
  }

  /// تسجيل الخروج من Google Drive
  Future<void> signOutFromGoogleDrive() async {
    await _googleDrive.signOut();
  }

  /// التحقق من تسجيل الدخول إلى Google Drive
  bool get isSignedInToDrive => _googleDrive.isSignedIn;

  // ========== نهاية Google Drive ==========

  /// جدولة نسخ احتياطي تلقائي
  Future<void> scheduleAutoBackup({
    Duration interval = const Duration(days: 1),
  }) async {
    _logger.info('جدولة نسخ احتياطي تلقائي كل ${interval.inHours} ساعة');

    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) async {
      try {
        _logger.info('تنفيذ نسخ احتياطي مجدول...');
        await createBackup();
        _logger.info('اكتمل النسخ الاحتياطي المجدول بنجاح');
      } catch (e) {
        _logger.error('فشل النسخ الاحتياطي المجدول', error: e);
      }
    });
  }

  /// إلغاء جدولة النسخ الاحتياطي التلقائي
  Future<void> cancelAutoBackup() async {
    _logger.info('إلغاء جدولة النسخ الاحتياطي التلقائي');
    _timer?.cancel();
    _timer = null;
  }

  /// الحصول على قائمة النسخ الاحتياطية السحابية (من Google Drive)
  Future<List<DriveBackupInfo>> getCloudBackups() async {
    try {
      return await getDriveBackups();
    } catch (e) {
      _logger.error('فشل جلب قائمة النسخ من Google Drive', error: e);
      return [];
    }
  }

  /// حذف نسخة احتياطية سحابية (من Google Drive)
  Future<void> deleteCloudBackup(String driveFileId) async {
    try {
      await _googleDrive.deleteBackup(driveFileId);
      _logger.info('تم حذف النسخة من Google Drive: $driveFileId');
    } catch (e) {
      _logger.error('فشل حذف النسخة من Google Drive', error: e);
      rethrow;
    }
  }

  /// حذف النسخ الاحتياطية القديمة (من Google Drive)
  Future<int> deleteOldBackups({int daysOld = 30, int keepLast = 5}) async {
    try {
      return await _googleDrive.deleteOldBackups(
        daysOld: daysOld,
        keepLast: keepLast,
      );
    } catch (e) {
      _logger.error('فشل حذف النسخ القديمة من Google Drive', error: e);
      return 0;
    }
  }

  /// الحصول على حجم التخزين المستخدم (من Google Drive)
  Future<int> getUsedStorage() async {
    try {
      final backups = await getDriveBackups();
      return backups.fold<int>(0, (sum, backup) => sum + backup.size);
    } catch (e) {
      _logger.error('فشل حساب المساحة المستخدمة', error: e);
      return 0;
    }
  }

  /// التحقق من توفر Google Drive
  Future<bool> isCloudAvailable() async {
    return _googleDrive.isSignedIn;
  }
}
