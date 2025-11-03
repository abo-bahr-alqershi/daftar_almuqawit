/// مدير المزامنة الرئيسي
/// ينسق بين خدمة المزامنة وقائمة الانتظار ومحلل التعارضات

import 'package:get_it/get_it.dart';

import 'sync_service.dart';
import 'offline_queue.dart';
import 'conflict_resolver.dart';
import 'sync_queue.dart';
import '../logger_service.dart';

/// مدير المزامنة
class SyncManager {
  final _sl = GetIt.instance;

  SyncService get _service => _sl<SyncService>();
  OfflineQueue get _offlineQueue => _sl<OfflineQueue>();
  ConflictResolver get _resolver => _sl<ConflictResolver>();
  SyncQueue get _syncQueue => _sl<SyncQueue>();
  LoggerService get _logger => _sl<LoggerService>();

  /// مزامنة فورية
  Future<void> syncNow() async {
    try {
      _logger.info('بدء المزامنة الفورية...');
      await _service.syncOnce();
      _logger.info('اكتملت المزامنة الفورية بنجاح');
    } catch (e) {
      _logger.error('خطأ في المزامنة الفورية', error: e);
      rethrow;
    }
  }

  /// بدء المزامنة التلقائية
  void startAuto() {
    try {
      _logger.info('بدء المزامنة التلقائية...');
      _service.startAutoSync();
    } catch (e) {
      _logger.error('خطأ في بدء المزامنة التلقائية', error: e);
    }
  }

  /// إيقاف المزامنة التلقائية
  Future<void> stopAuto() async {
    try {
      _logger.info('إيقاف المزامنة التلقائية...');
      await _service.stopAutoSync();
    } catch (e) {
      _logger.error('خطأ في إيقاف المزامنة التلقائية', error: e);
    }
  }

  /// حل جميع التعارضات
  Future<void> resolveConflicts() async {
    try {
      _logger.info('بدء حل التعارضات...');
      await _resolver.resolveAll();
      _logger.info('تم حل جميع التعارضات');
    } catch (e) {
      _logger.error('خطأ في حل التعارضات', error: e);
      rethrow;
    }
  }

  /// الحصول على حالة المزامنة
  Future<SyncStatus> getStatus() async {
    try {
      final pendingCount = await _syncQueue.getPendingCount();
      final offlineCount = await _offlineQueue.getCount();
      
      return SyncStatus(
        isPending: pendingCount > 0,
        pendingOperations: pendingCount,
        offlineOperations: offlineCount,
        lastSyncTime: DateTime.now(), // TODO: حفظ وقت آخر مزامنة
      );
    } catch (e) {
      _logger.error('خطأ في الحصول على حالة المزامنة', error: e);
      return SyncStatus(
        isPending: false,
        pendingOperations: 0,
        offlineOperations: 0,
        lastSyncTime: null,
      );
    }
  }

  /// مزامنة العمليات غير المتصلة
  Future<void> syncOfflineOperations() async {
    try {
      _logger.info('بدء مزامنة العمليات غير المتصلة...');
      await _offlineQueue.processAll();
      _logger.info('اكتملت مزامنة العمليات غير المتصلة');
    } catch (e) {
      _logger.error('خطأ في مزامنة العمليات غير المتصلة', error: e);
      rethrow;
    }
  }

  /// إضافة عملية لقائمة الانتظار
  Future<void> enqueue(String entity, String operation, Map<String, Object?> payload) =>
      _offlineQueue.enqueue(entity, operation, payload);

  /// عدد العمليات المعلقة
  Future<int> pendingCount() => _offlineQueue.pendingCount();
}

/// حالة المزامنة
class SyncStatus {
  final bool isPending;
  final int pendingOperations;
  final int offlineOperations;
  final DateTime? lastSyncTime;

  const SyncStatus({
    required this.isPending,
    required this.pendingOperations,
    required this.offlineOperations,
    this.lastSyncTime,
  });
}
