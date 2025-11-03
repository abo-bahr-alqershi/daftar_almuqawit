/// خدمة إدارة قائمة العمليات غير المتصلة
/// تخزن العمليات التي تحدث بدون اتصال وتعالجها عند توفر الاتصال

import 'package:get_it/get_it.dart';
import '../../../domain/repositories/sync_repository.dart';
import 'sync_queue.dart';
import 'sync_service.dart';

/// خدمة قائمة الانتظار للعمليات غير المتصلة
class OfflineQueue {
  final _sl = GetIt.instance;

  SyncRepository get _repo => _sl<SyncRepository>();
  SyncQueue get _queue => _sl<SyncQueue>();
  SyncService get _service => _sl<SyncService>();

  /// إضافة عملية إلى قائمة الانتظار
  Future<void> enqueue(
    String entity,
    String operation,
    Map<String, Object?> payload, {
    int priority = 0,
  }) async {
    await _repo.queueOperation(entity, operation, payload, priority: priority);
  }

  /// الحصول على عدد العمليات المعلقة
  Future<int> pendingCount() async {
    final pending = await _queue.getPending(limit: 1 << 20);
    return pending.length;
  }

  /// معالجة جميع العمليات في القائمة
  Future<void> drain() async {
    await _service.syncOnce();
  }

  /// الحصول على العمليات المعلقة مرتبة حسب الأولوية
  Future<List<Map<String, dynamic>>> getPendingOperations({
    int? limit,
  }) async {
    return await _queue.getPending(limit: limit ?? 100);
  }

  /// إعادة محاولة العمليات الفاشلة
  Future<void> retryFailed() async {
    final failed = await _queue.getFailedOperations();
    for (final operation in failed) {
      try {
        await _service.processOperation(operation);
        await _queue.markAsCompleted(operation['id'] as int);
      } catch (e) {
        // تسجيل الخطأ وزيادة عداد المحاولات
        await _queue.incrementRetryCount(operation['id'] as int);
      }
    }
  }

  /// حذف العمليات المكتملة
  Future<void> clearCompleted() async {
    await _queue.deleteCompleted();
  }

  /// حذف عملية محددة
  Future<void> removeOperation(int operationId) async {
    await _queue.deleteOperation(operationId);
  }

  /// الحصول على إحصائيات القائمة
  Future<Map<String, int>> getStatistics() async {
    final pending = await pendingCount();
    final failed = await _queue.getFailedCount();
    final completed = await _queue.getCompletedCount();
    
    return {
      'pending': pending,
      'failed': failed,
      'completed': completed,
      'total': pending + failed + completed,
    };
  }
}
