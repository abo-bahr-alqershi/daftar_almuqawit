/// خدمة Firebase Storage - للمزامنة التلقائية بين الأجهزة
/// 
/// توفر مزامنة البيانات بين التخزين المحلي و Firebase Storage
/// هذه الخدمة مخصصة للمزامنة وليس للنسخ الاحتياطي
/// 
/// الفرق بين المزامنة والنسخ الاحتياطي:
/// - المزامنة: تحديث مستمر للبيانات بين الأجهزة عبر Firebase Storage
/// - النسخ الاحتياطي: نسخة كاملة محفوظة على Google Drive للاستعادة عند الحاجة

import 'dart:io';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import '../logger_service.dart';

/// خدمة Firebase Storage للمزامنة
class FirebaseStorageService {
  FirebaseStorageService._();

  static final FirebaseStorageService _instance = FirebaseStorageService._();
  static FirebaseStorageService get instance => _instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LoggerService _logger = LoggerService();

  /// المسار الأساسي للبيانات المتزامنة
  String get _syncDataPath {
    final userId = _auth.currentUser?.uid ?? 'anonymous';
    return 'sync_data/$userId';
  }

  // ========== رفع البيانات للمزامنة ==========

  /// رفع ملف للمزامنة
  Future<String> uploadSyncFile(
    String filePath,
    String collection, {
    Function(double progress)? onProgress,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('الملف غير موجود: $filePath');
      }

      final fileName = path.basename(filePath);
      final cloudPath = '$_syncDataPath/$collection/$fileName';

      _logger.info('رفع للمزامنة: $cloudPath');

      final ref = _storage.ref().child(cloudPath);
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'application/json',
          customMetadata: {
            'syncedAt': DateTime.now().toIso8601String(),
            'collection': collection,
            'version': '1.0',
          },
        ),
      );

      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _logger.info('تم رفع الملف للمزامنة: $downloadUrl');
      return downloadUrl;
    } catch (e, stackTrace) {
      _logger.error('فشل رفع الملف للمزامنة', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// رفع بيانات JSON للمزامنة
  Future<String> uploadJsonData(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      final jsonString = jsonEncode(data);
      final fileName = '$documentId.json';
      final cloudPath = '$_syncDataPath/$collection/$fileName';

      _logger.info('رفع بيانات JSON للمزامنة: $cloudPath');

      final ref = _storage.ref().child(cloudPath);
      final uploadTask = ref.putString(
        jsonString,
        format: PutStringFormat.raw,
        metadata: SettableMetadata(
          contentType: 'application/json',
          customMetadata: {
            'syncedAt': DateTime.now().toIso8601String(),
            'collection': collection,
            'documentId': documentId,
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _logger.info('تم رفع البيانات للمزامنة');
      return downloadUrl;
    } catch (e, stackTrace) {
      _logger.error('فشل رفع البيانات للمزامنة', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ========== تحميل البيانات من المزامنة ==========

  /// تحميل ملف متزامن
  Future<String> downloadSyncFile(
    String collection,
    String fileName,
    String localPath, {
    Function(double progress)? onProgress,
  }) async {
    try {
      final cloudPath = '$_syncDataPath/$collection/$fileName';
      _logger.info('تحميل من المزامنة: $cloudPath');

      final ref = _storage.ref().child(cloudPath);
      final file = File(localPath);

      await file.parent.create(recursive: true);

      final downloadTask = ref.writeToFile(file);

      downloadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      await downloadTask;

      _logger.info('تم تحميل الملف من المزامنة: $localPath');
      return localPath;
    } catch (e, stackTrace) {
      _logger.error('فشل تحميل الملف من المزامنة', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// تحميل بيانات JSON من المزامنة
  Future<Map<String, dynamic>> downloadJsonData(
    String collection,
    String documentId,
  ) async {
    try {
      final fileName = '$documentId.json';
      final cloudPath = '$_syncDataPath/$collection/$fileName';

      _logger.info('تحميل بيانات JSON من المزامنة: $cloudPath');

      final ref = _storage.ref().child(cloudPath);
      final bytes = await ref.getData();

      if (bytes == null) {
        throw Exception('لا توجد بيانات');
      }

      final jsonString = utf8.decode(bytes);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      _logger.info('تم تحميل البيانات من المزامنة');
      return data;
    } catch (e, stackTrace) {
      _logger.error('فشل تحميل البيانات من المزامنة', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ========== قائمة الملفات المتزامنة ==========

  /// الحصول على قائمة الملفات المتزامنة في مجموعة
  Future<List<SyncFileInfo>> listSyncFiles(String collection) async {
    try {
      _logger.info('جلب قائمة الملفات المتزامنة: $collection');

      final ref = _storage.ref().child('$_syncDataPath/$collection');
      final listResult = await ref.listAll();

      final files = <SyncFileInfo>[];

      for (final item in listResult.items) {
        try {
          final metadata = await item.getMetadata();
          final downloadUrl = await item.getDownloadURL();

          files.add(
            SyncFileInfo(
              name: metadata.name ?? item.name,
              path: item.fullPath,
              downloadUrl: downloadUrl,
              size: metadata.size ?? 0,
              syncedAt: metadata.timeCreated ?? DateTime.now(),
              collection: collection,
              metadata: metadata.customMetadata,
            ),
          );
        } catch (e) {
          _logger.warning('تخطي ملف: ${item.name}');
        }
      }

      files.sort((a, b) => b.syncedAt.compareTo(a.syncedAt));

      _logger.info('تم العثور على ${files.length} ملف متزامن');
      return files;
    } catch (e, stackTrace) {
      _logger.error('فشل جلب قائمة الملفات المتزامنة', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // ========== حذف البيانات المتزامنة ==========

  /// حذف ملف متزامن
  Future<void> deleteSyncFile(String collection, String fileName) async {
    try {
      final cloudPath = '$_syncDataPath/$collection/$fileName';
      _logger.info('حذف ملف متزامن: $cloudPath');

      final ref = _storage.ref().child(cloudPath);
      await ref.delete();

      _logger.info('تم حذف الملف المتزامن');
    } catch (e, stackTrace) {
      _logger.error('فشل حذف الملف المتزامن', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// حذف كل البيانات المتزامنة في مجموعة
  Future<void> deleteCollection(String collection) async {
    try {
      _logger.info('حذف المجموعة المتزامنة: $collection');

      final ref = _storage.ref().child('$_syncDataPath/$collection');
      final listResult = await ref.listAll();

      for (final item in listResult.items) {
        try {
          await item.delete();
        } catch (e) {
          _logger.warning('فشل حذف: ${item.name}');
        }
      }

      _logger.info('تم حذف المجموعة المتزامنة');
    } catch (e, stackTrace) {
      _logger.error('فشل حذف المجموعة المتزامنة', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ========== معلومات الحالة ==========

  /// التحقق من وجود ملف متزامن
  Future<bool> syncFileExists(String collection, String fileName) async {
    try {
      final cloudPath = '$_syncDataPath/$collection/$fileName';
      final ref = _storage.ref().child(cloudPath);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// الحصول على تاريخ آخر مزامنة لملف
  Future<DateTime?> getLastSyncTime(String collection, String fileName) async {
    try {
      final cloudPath = '$_syncDataPath/$collection/$fileName';
      final ref = _storage.ref().child(cloudPath);
      final metadata = await ref.getMetadata();
      return metadata.timeCreated;
    } catch (e) {
      return null;
    }
  }

  /// معلومات المستخدم
  String? getUserId() => _auth.currentUser?.uid;
  String? getUserEmail() => _auth.currentUser?.email;
  bool get isAuthenticated => _auth.currentUser != null;

  /// الوصول المباشر للـ FirebaseStorage (للحالات الخاصة)
  FirebaseStorage get storage => _storage;
}

/// معلومات ملف متزامن
class SyncFileInfo {
  final String name;
  final String path;
  final String downloadUrl;
  final int size;
  final DateTime syncedAt;
  final String collection;
  final Map<String, String>? metadata;

  const SyncFileInfo({
    required this.name,
    required this.path,
    required this.downloadUrl,
    required this.size,
    required this.syncedAt,
    required this.collection,
    this.metadata,
  });

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get timeAgo {
    final diff = DateTime.now().difference(syncedAt);

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
    'syncedAt': syncedAt.toIso8601String(),
    'timeAgo': timeAgo,
    'collection': collection,
    'metadata': metadata,
  };
}
