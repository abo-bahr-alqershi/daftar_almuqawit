/// منسق المزامنة بين التخزين المحلي و Firebase Storage
/// 
/// يدير المزامنة الثنائية الاتجاه بين:
/// - قاعدة البيانات المحلية (SQLite)
/// - Firebase Storage (السحابة)
/// 
/// الفرق عن backup_service:
/// - هذه الخدمة للمزامنة المستمرة (sync)
/// - backup_service للنسخ الاحتياطي الكامل على Google Drive

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import '../firebase/firebase_storage_service.dart';
import '../local/shared_preferences_service.dart';
import '../network/connectivity_service.dart';
import '../logger_service.dart';
import '../../constants/storage_keys.dart';
import '../../../data/database/database_helper.dart';

/// منسق مزامنة التخزين
class StorageSyncCoordinator {
  StorageSyncCoordinator._();

  static final StorageSyncCoordinator _instance = StorageSyncCoordinator._();
  static StorageSyncCoordinator get instance => _instance;

  final _sl = GetIt.instance;
  final _logger = LoggerService();

  FirebaseStorageService get _firebaseStorage => FirebaseStorageService.instance;
  SharedPreferencesService get _prefs => _sl<SharedPreferencesService>();
  ConnectivityService get _connectivity => _sl<ConnectivityService>();

  Timer? _periodicSyncTimer;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// المجموعات المدعومة للمزامنة
  final List<String> _supportedCollections = [
    'sales',
    'purchases',
    'customers',
    'suppliers',
    'debts',
    'debt_payments',
    'expenses',
    'qat_types',
    'accounts',
  ];

  // ========== المزامنة اليدوية ==========

  /// مزامنة فورية لكل البيانات
  Future<SyncResult> syncNow({bool forceUpload = false}) async {
    if (_isSyncing) {
      _logger.warning('⚠️ المزامنة جارية بالفعل');
      return SyncResult(
        success: false,
        message: 'المزامنة جارية بالفعل',
        uploadedCount: 0,
        downloadedCount: 0,
        errorCount: 0,
      );
    }

    if (!_firebaseStorage.isAuthenticated) {
      _logger.warning('⚠️ لم يتم تسجيل الدخول - لن تتم المزامنة');
      return SyncResult(
        success: false,
        message: 'يجب تسجيل الدخول أولاً',
        uploadedCount: 0,
        downloadedCount: 0,
        errorCount: 0,
      );
    }

    final isOnline = await _connectivity.isOnline;
    if (!isOnline) {
      _logger.warning('⚠️ لا يوجد اتصال بالإنترنت');
      return SyncResult(
        success: false,
        message: 'لا يوجد اتصال بالإنترنت',
        uploadedCount: 0,
        downloadedCount: 0,
        errorCount: 0,
      );
    }

    _isSyncing = true;
    _updateStatus(SyncStatus.syncing);

    int uploadedCount = 0;
    int downloadedCount = 0;
    int errorCount = 0;

    try {
      _logger.info('🔄 بدء المزامنة الشاملة...');

      // 1. المزامنة من المحلي للسحابة (رفع)
      for (final collection in _supportedCollections) {
        try {
          final uploaded = await _syncCollectionToCloud(collection, forceUpload);
          uploadedCount += uploaded;
          _logger.info('✅ تم رفع $uploaded عنصر من $collection');
        } catch (e) {
          errorCount++;
          _logger.error('❌ فشل رفع $collection', error: e);
        }
      }

      // 2. المزامنة من السحابة للمحلي (تحميل)
      for (final collection in _supportedCollections) {
        try {
          final downloaded = await _syncCollectionFromCloud(collection);
          downloadedCount += downloaded;
          _logger.info('✅ تم تحميل $downloaded عنصر من $collection');
        } catch (e) {
          errorCount++;
          _logger.error('❌ فشل تحميل $collection', error: e);
        }
      }

      // حفظ وقت آخر مزامنة
      _lastSyncTime = DateTime.now();
      await _prefs.setString(
        StorageKeys.lastSyncTime,
        _lastSyncTime!.toIso8601String(),
      );

      _updateStatus(SyncStatus.synced);
      _logger.info('✅ اكتملت المزامنة: رفع=$uploadedCount، تحميل=$downloadedCount، أخطاء=$errorCount');

      return SyncResult(
        success: errorCount == 0,
        message: 'تمت المزامنة بنجاح',
        uploadedCount: uploadedCount,
        downloadedCount: downloadedCount,
        errorCount: errorCount,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ فشلت المزامنة', error: e, stackTrace: stackTrace);
      _updateStatus(SyncStatus.error);

      return SyncResult(
        success: false,
        message: 'فشلت المزامنة: $e',
        uploadedCount: uploadedCount,
        downloadedCount: downloadedCount,
        errorCount: errorCount + 1,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// مزامنة مجموعة واحدة من المحلي للسحابة
  Future<int> _syncCollectionToCloud(
    String collection,
    bool forceUpload,
  ) async {
    try {
      // الحصول على البيانات المحلية
      final localData = await _getLocalCollectionData(collection);

      if (localData.isEmpty) {
        _logger.info('ℹ️ لا توجد بيانات محلية في $collection');
        return 0;
      }

      int uploadedCount = 0;

      for (final item in localData) {
        try {
          final docId = item['id']?.toString() ?? item['uuid']?.toString();
          if (docId == null) continue;

          // التحقق من وجود الملف في السحابة
          final exists = await _firebaseStorage.syncFileExists(collection, '$docId.json');

          // رفع فقط إذا كان جديداً أو forceUpload
          if (!exists || forceUpload) {
            await _firebaseStorage.uploadJsonData(collection, docId, item);
            uploadedCount++;
          }
        } catch (e) {
          _logger.warning('تخطي عنصر في $collection', data: {'error': e.toString()});
        }
      }

      return uploadedCount;
    } catch (e) {
      _logger.error('فشل رفع المجموعة $collection', error: e);
      rethrow;
    }
  }

  /// مزامنة مجموعة من السحابة للمحلي
  Future<int> _syncCollectionFromCloud(String collection) async {
    try {
      // الحصول على قائمة الملفات من السحابة
      final cloudFiles = await _firebaseStorage.listSyncFiles(collection);

      if (cloudFiles.isEmpty) {
        _logger.info('ℹ️ لا توجد بيانات سحابية في $collection');
        return 0;
      }

      int downloadedCount = 0;

      for (final file in cloudFiles) {
        try {
          final docId = file.name.replaceAll('.json', '');

          // التحقق من وجود البيانات محلياً
          final exists = await _localDataExists(collection, docId);

          if (!exists) {
            // تحميل البيانات
            final data = await _firebaseStorage.downloadJsonData(collection, docId);

            // حفظ البيانات محلياً
            await _saveLocalData(collection, data);
            downloadedCount++;
          }
        } catch (e) {
          _logger.warning('تخطي ملف ${file.name} في $collection', data: {'error': e.toString()});
        }
      }

      return downloadedCount;
    } catch (e) {
      _logger.error('فشل تحميل المجموعة $collection', error: e);
      rethrow;
    }
  }

  // ========== المزامنة التلقائية ==========

  /// بدء المزامنة التلقائية
  void startAutoSync({Duration interval = const Duration(minutes: 15)}) {
    _periodicSyncTimer?.cancel();

    _periodicSyncTimer = Timer.periodic(interval, (_) async {
      if (!_isSyncing) {
        final isOnline = await _connectivity.isOnline;
        if (isOnline) {
          _logger.info('⏰ مزامنة دورية مجدولة');
          await syncNow();
        }
      }
    });

    _logger.info('✅ تم تفعيل المزامنة التلقائية (كل ${interval.inMinutes} دقيقة)');
  }

  /// إيقاف المزامنة التلقائية
  void stopAutoSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
    _logger.info('⏹️ تم إيقاف المزامنة التلقائية');
  }

  // ========== مساعدات قاعدة البيانات المحلية ==========

  /// الحصول على بيانات مجموعة محلية
  Future<List<Map<String, dynamic>>> _getLocalCollectionData(
    String collection,
  ) async {
    final db = await DatabaseHelper.instance.database;

    try {
      return await db.query(collection);
    } catch (e) {
      _logger.warning('المجموعة $collection غير موجودة محلياً');
      return [];
    }
  }

  /// التحقق من وجود بيانات محلية
  Future<bool> _localDataExists(String collection, String id) async {
    final db = await DatabaseHelper.instance.database;

    try {
      final result = await db.query(
        collection,
        where: 'id = ? OR uuid = ?',
        whereArgs: [id, id],
        limit: 1,
      );

      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// حفظ بيانات محلية
  Future<void> _saveLocalData(
    String collection,
    Map<String, dynamic> data,
  ) async {
    final db = await DatabaseHelper.instance.database;

    try {
      await db.insert(
        collection,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      _logger.error('فشل حفظ البيانات في $collection', error: e);
      rethrow;
    }
  }

  // ========== حالة المزامنة ==========

  void _updateStatus(SyncStatus status) {
    _syncStatusController.add(status);
  }

  /// معلومات حالة المزامنة
  Future<SyncInfo> getSyncInfo() async {
    final lastSyncStr = _prefs.getString(StorageKeys.lastSyncTime);
    final lastSync = lastSyncStr != null ? DateTime.tryParse(lastSyncStr) : null;

    return SyncInfo(
      isAuthenticated: _firebaseStorage.isAuthenticated,
      isSyncing: _isSyncing,
      lastSyncTime: lastSync,
      autoSyncEnabled: _periodicSyncTimer != null,
    );
  }

  /// تصدير بيانات المزامنة لملف JSON (للفحص)
  Future<String> exportSyncData(String collection) async {
    try {
      final data = await _getLocalCollectionData(collection);
      final jsonString = jsonEncode(data);

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/sync_export_$collection.json');
      await file.writeAsString(jsonString);

      _logger.info('تم تصدير بيانات $collection إلى ${file.path}');
      return file.path;
    } catch (e) {
      _logger.error('فشل تصدير بيانات $collection', error: e);
      rethrow;
    }
  }

  /// إغلاق الخدمة
  Future<void> dispose() async {
    stopAutoSync();
    await _syncStatusController.close();
  }
}

// ========== نماذج البيانات ==========

/// حالة المزامنة
enum SyncStatus {
  idle,
  syncing,
  synced,
  error,
}

/// نتيجة المزامنة
class SyncResult {
  final bool success;
  final String message;
  final int uploadedCount;
  final int downloadedCount;
  final int errorCount;

  const SyncResult({
    required this.success,
    required this.message,
    required this.uploadedCount,
    required this.downloadedCount,
    required this.errorCount,
  });

  @override
  String toString() {
    return 'SyncResult(success: $success, uploaded: $uploadedCount, '
        'downloaded: $downloadedCount, errors: $errorCount)';
  }
}

/// معلومات المزامنة
class SyncInfo {
  final bool isAuthenticated;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final bool autoSyncEnabled;

  const SyncInfo({
    required this.isAuthenticated,
    required this.isSyncing,
    this.lastSyncTime,
    required this.autoSyncEnabled,
  });

  String get lastSyncFormatted {
    if (lastSyncTime == null) return 'لم تتم المزامنة بعد';

    final diff = DateTime.now().difference(lastSyncTime!);

    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';

    return '${lastSyncTime!.day}/${lastSyncTime!.month}/${lastSyncTime!.year}';
  }

  Map<String, dynamic> toJson() => {
    'isAuthenticated': isAuthenticated,
    'isSyncing': isSyncing,
    'lastSyncTime': lastSyncTime?.toIso8601String(),
    'lastSyncFormatted': lastSyncFormatted,
    'autoSyncEnabled': autoSyncEnabled,
  };
}
