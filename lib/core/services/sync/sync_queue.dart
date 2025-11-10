/// قائمة انتظار المزامنة
/// تدير العمليات المعلقة للمزامنة مع الخادم البعيد

import 'package:get_it/get_it.dart';

import '../../../data/datasources/local/sync_local_datasource.dart';
import '../../../data/models/sync_record_model.dart';
import '../logger_service.dart';

/// قائمة انتظار المزامنة
class SyncQueue {
  final _sl = GetIt.instance;

  SyncLocalDataSource get _local => _sl<SyncLocalDataSource>();
  LoggerService get _logger => _sl<LoggerService>();

  /// الحصول على العمليات المعلقة
  Future<List<SyncRecordModel>> getPending({int limit = 50}) async {
    try {
      return await _local.getPending(limit: limit);
    } catch (e) {
      _logger.error('خطأ في الحصول على العمليات المعلقة', error: e);
      return [];
    }
  }

  /// وضع علامة معالجة على عملية
  Future<void> markProcessing(int id) async {
    try {
      await _local.markProcessing(id);
      _logger.info('تم وضع علامة معالجة على العملية: $id');
    } catch (e) {
      _logger.error('خطأ في وضع علامة معالجة', error: e);
    }
  }

  /// وضع علامة اكتمال على عملية
  Future<void> markDone(int id) async {
    try {
      await _local.markDone(id);
      _logger.info('تم وضع علامة اكتمال على العملية: $id');
    } catch (e) {
      _logger.error('خطأ في وضع علامة اكتمال', error: e);
    }
  }

  /// وضع علامة فشل على عملية
  Future<void> markFailed(int id) async {
    try {
      await _local.markFailed(id);
      _logger.warning('تم وضع علامة فشل على العملية: $id');
    } catch (e) {
      _logger.error('خطأ في وضع علامة فشل', error: e);
    }
  }

  /// زيادة عداد المحاولات
  Future<void> incrementRetry(int id) async {
    try {
      await _local.incrementRetry(id);
      _logger.info('تم زيادة عداد المحاولات للعملية: $id');
    } catch (e) {
      _logger.error('خطأ في زيادة عداد المحاولات', error: e);
    }
  }

  /// الحصول على عدد العمليات المعلقة
  Future<int> getPendingCount() async {
    try {
      final pending = await getPending(limit: 1000);
      return pending.length;
    } catch (e) {
      _logger.error('خطأ في حساب العمليات المعلقة', error: e);
      return 0;
    }
  }

  /// حذف العمليات المكتملة القديمة
  Future<void> cleanupOldRecords({int daysOld = 30}) async {
    try {
      _logger.info('تنظيف سجلات المزامنة القديمة...');
      final deletedCount = await _local.deleteOldRecords(daysOld: daysOld);
      _logger.info('تم حذف $deletedCount سجل قديم');
    } catch (e) {
      _logger.error('خطأ في تنظيف السجلات', error: e);
    }
  }
  
  /// إضافة عملية للقائمة
  Future<void> addOperation(Map<String, dynamic> operation) async {
    try {
      final record = SyncRecordModel.fromJson(operation);
      await _local.insert(record);
      _logger.info('تمت إضافة عملية جديدة للقائمة');
    } catch (e) {
      _logger.error('خطأ في إضافة العملية', error: e);
    }
  }
  
  /// تحديث حالة العملية
  Future<void> updateStatus(int id, String status) async {
    try {
      if (status == 'done') {
        await markDone(id);
      } else if (status == 'failed') {
        await markFailed(id);
      } else if (status == 'processing') {
        await markProcessing(id);
      }
    } catch (e) {
      _logger.error('خطأ في تحديث حالة العملية', error: e);
    }
  }
  
  /// زيادة عدد المحاولات
  Future<void> incrementRetryCount(int id) async {
    await incrementRetry(id);
  }
  
  /// حذف العمليات المكتملة
  Future<void> deleteCompleted() async {
    try {
      final deletedCount = await _local.deleteCompleted();
      _logger.info('تم حذف $deletedCount عملية مكتملة');
    } catch (e) {
      _logger.error('خطأ في حذف العمليات المكتملة', error: e);
    }
  }
  
  /// حذف عملية محددة
  Future<void> deleteOperation(int operationId) async {
    try {
      await _local.delete(operationId);
      _logger.info('تم حذف العملية: $operationId');
    } catch (e) {
      _logger.error('خطأ في حذف العملية', error: e);
    }
  }
  
  /// الحصول على عدد العمليات الفاشلة
  Future<int> getFailedCount() async {
    try {
      return await _local.getFailedCount();
    } catch (e) {
      _logger.error('خطأ في حساب العمليات الفاشلة', error: e);
      return 0;
    }
  }
  
  /// الحصول على عدد العمليات المكتملة
  Future<int> getCompletedCount() async {
    try {
      return await _local.getCompletedCount();
    } catch (e) {
      _logger.error('خطأ في حساب العمليات المكتملة', error: e);
      return 0;
    }
  }

  /// الحصول على العمليات الفاشلة
  Future<List<SyncRecordModel>> getFailed({int limit = 50}) async {
    try {
      return await _local.getFailed(limit: limit);
    } catch (e) {
      _logger.error('خطأ في الحصول على العمليات الفاشلة', error: e);
      return [];
    }
  }
}
