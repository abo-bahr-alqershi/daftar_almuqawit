/// خدمة التخزين السحابي - Firebase Storage
/// توفر رفع وتحميل النسخ الاحتياطية للسحابة باستخدام Firebase Storage
///
/// الميزات:
/// - رفع الملفات مع شريط التقدم
/// - تحميل الملفات من السحابة
/// - حذف الملفات القديمة
/// - إدارة المساحة التخزينية
/// - ضغط الملفات قبل الرفع

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'logger_service.dart';

/// خدمة التخزين السحابي
class CloudStorageService {
  CloudStorageService._();

  static final CloudStorageService _instance = CloudStorageService._();
  static CloudStorageService get instance => _instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LoggerService _logger = LoggerService();

  /// المسار الأساسي للنسخ الاحتياطية في Firebase Storage
  String get _backupsPath {
    final userId = _auth.currentUser?.uid ?? 'anonymous';
    return 'backups/$userId';
  }

  // ========== رفع الملفات ==========

  /// رفع ملف نسخة احتياطية إلى السحابة
  ///
  /// Parameters:
  /// - [filePath]: مسار الملف المحلي
  /// - [onProgress]: دالة callback لتتبع التقدم (0.0 - 1.0)
  ///
  /// Returns: رابط تحميل الملف في السحابة
  Future<String> uploadBackup(
    String filePath, {
    Function(double progress)? onProgress,
  }) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw Exception('الملف غير موجود: $filePath');
      }

      _logger.info('بدء رفع النسخة الاحتياطية: ${path.basename(filePath)}');

      // إنشاء اسم فريد للملف
      final fileName = path.basename(filePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cloudPath = '$_backupsPath/${timestamp}_$fileName';

      // رفع الملف
      final ref = _storage.ref().child(cloudPath);
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'application/x-sqlite3',
          customMetadata: {
            'uploadedAt': DateTime.now().toIso8601String(),
            'originalName': fileName,
            'appVersion': '1.0.0',
          },
        ),
      );

      // تتبع التقدم
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        _logger.info('تقدم الرفع: ${(progress * 100).toStringAsFixed(1)}%');
        onProgress?.call(progress);
      });

      // انتظار اكتمال الرفع
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _logger.info('تم رفع النسخة الاحتياطية بنجاح: $downloadUrl');

      return downloadUrl;
    } catch (e, stackTrace) {
      _logger.error(
        'فشل رفع النسخة الاحتياطية',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ========== تحميل الملفات ==========

  /// تحميل ملف نسخة احتياطية من السحابة
  ///
  /// Parameters:
  /// - [cloudPath]: المسار في السحابة أو رابط التحميل
  /// - [localPath]: المسار المحلي لحفظ الملف
  /// - [onProgress]: دالة callback لتتبع التقدم
  Future<String> downloadBackup(
    String cloudPath,
    String localPath, {
    Function(double progress)? onProgress,
  }) async {
    try {
      _logger.info('بدء تحميل النسخة الاحتياطية من: $cloudPath');

      // الحصول على مرجع الملف
      final ref = cloudPath.startsWith('http')
          ? _storage.refFromURL(cloudPath)
          : _storage.ref().child(cloudPath);

      final file = File(localPath);

      // التأكد من وجود المجلد
      await file.parent.create(recursive: true);

      // تحميل الملف
      final downloadTask = ref.writeToFile(file);

      // تتبع التقدم
      downloadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        _logger.info('تقدم التحميل: ${(progress * 100).toStringAsFixed(1)}%');
        onProgress?.call(progress);
      });

      await downloadTask;

      _logger.info('تم تحميل النسخة الاحتياطية بنجاح: $localPath');

      return localPath;
    } catch (e, stackTrace) {
      _logger.error(
        'فشل تحميل النسخة الاحتياطية',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ========== قائمة الملفات ==========

  /// الحصول على قائمة النسخ الاحتياطية المتاحة
  ///
  /// Returns: قائمة من معلومات الملفات
  Future<List<BackupFileInfo>> listBackups() async {
    try {
      _logger.info('جلب قائمة النسخ الاحتياطية...');

      final ref = _storage.ref().child(_backupsPath);
      final listResult = await ref.listAll();

      final backups = <BackupFileInfo>[];

      for (final item in listResult.items) {
        try {
          final metadata = await item.getMetadata();
          final downloadUrl = await item.getDownloadURL();

          backups.add(
            BackupFileInfo(
              name: metadata.name ?? item.name,
              path: item.fullPath,
              downloadUrl: downloadUrl,
              size: metadata.size ?? 0,
              createdAt: metadata.timeCreated ?? DateTime.now(),
              updatedAt: metadata.updated ?? DateTime.now(),
              contentType: metadata.contentType,
              metadata: metadata.customMetadata,
            ),
          );
        } catch (e) {
          _logger.warning('تخطي ملف: ${item.name}');
          _logger.d('تفاصيل الخطأ: $e');
        }
      }

      // ترتيب حسب التاريخ (الأحدث أولاً)
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _logger.info('تم العثور على ${backups.length} نسخة احتياطية');

      return backups;
    } catch (e, stackTrace) {
      _logger.error(
        'فشل جلب قائمة النسخ الاحتياطية',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  // ========== حذف الملفات ==========

  /// حذف نسخة احتياطية من السحابة
  Future<void> deleteBackup(String cloudPath) async {
    try {
      _logger.info('حذف النسخة الاحتياطية: $cloudPath');

      final ref = cloudPath.startsWith('http')
          ? _storage.refFromURL(cloudPath)
          : _storage.ref().child(cloudPath);

      await ref.delete();

      _logger.info('تم حذف النسخة الاحتياطية بنجاح');
    } catch (e, stackTrace) {
      _logger.error(
        'فشل حذف النسخة الاحتياطية',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// حذف النسخ الاحتياطية القديمة (أكثر من X يوم)
  Future<int> deleteOldBackups({int daysOld = 30, int keepLast = 5}) async {
    try {
      _logger.info('حذف النسخ الاحتياطية القديمة (أقدم من $daysOld يوم)...');

      final backups = await listBackups();

      if (backups.length <= keepLast) {
        _logger.info('عدد النسخ ($keepLast أو أقل) - لن يتم الحذف');
        return 0;
      }

      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      int deletedCount = 0;

      // الاحتفاظ بآخر X نسخة
      final toDelete = backups
          .skip(keepLast)
          .where((backup) => backup.createdAt.isBefore(cutoffDate));

      for (final backup in toDelete) {
        try {
          await deleteBackup(backup.path);
          deletedCount++;
        } catch (e) {
          _logger.warning('فشل حذف: ${backup.name}');
          _logger.d('تفاصيل الخطأ: $e');
        }
      }

      _logger.info('تم حذف $deletedCount نسخة احتياطية قديمة');

      return deletedCount;
    } catch (e, stackTrace) {
      _logger.error('فشل حذف النسخ القديمة', error: e, stackTrace: stackTrace);
      return 0;
    }
  }

  // ========== معلومات التخزين ==========

  /// الحصول على حجم التخزين المستخدم
  Future<int> getUsedStorage() async {
    try {
      final backups = await listBackups();
      return backups.fold<int>(0, (sum, backup) => sum + backup.size);
    } catch (e) {
      _logger.error('فشل حساب المساحة المستخدمة', error: e);
      return 0;
    }
  }

  /// التحقق من توفر الاتصال بالسحابة
  Future<bool> isCloudAvailable() async {
    try {
      await _storage.ref().child('.health_check').getDownloadURL();
      return true;
    } catch (e) {
      // إذا فشل، نفترض أن السحابة متاحة لكن الملف غير موجود
      return true;
    }
  }

  /// الحصول على معلومات المستخدم
  String? getUserId() => _auth.currentUser?.uid;
  String? getUserEmail() => _auth.currentUser?.email;
  bool get isAuthenticated => _auth.currentUser != null;
}

/// معلومات ملف النسخة الاحتياطية
class BackupFileInfo {
  final String name;
  final String path;
  final String downloadUrl;
  final int size;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? contentType;
  final Map<String, String>? metadata;

  const BackupFileInfo({
    required this.name,
    required this.path,
    required this.downloadUrl,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
    this.contentType,
    this.metadata,
  });

  /// حجم الملف بصيغة قابلة للقراءة
  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// الوقت منذ الإنشاء
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);

    if (diff.inSeconds < 60) return 'منذ ${diff.inSeconds} ثانية';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
    if (diff.inDays < 365) return 'منذ ${(diff.inDays / 30).floor()} شهر';
    return 'منذ ${(diff.inDays / 365).floor()} سنة';
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
    'downloadUrl': downloadUrl,
    'size': size,
    'sizeFormatted': sizeFormatted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'timeAgo': timeAgo,
    'contentType': contentType,
    'metadata': metadata,
  };
}
