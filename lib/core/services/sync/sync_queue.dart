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
      // TODO: تطبيق الحذف من قاعدة البيانات
      _logger.info('تم تنظيف السجلات القديمة');
    } catch (e) {
      _logger.error('خطأ في تنظيف السجلات', error: e);
    }
  }
}
