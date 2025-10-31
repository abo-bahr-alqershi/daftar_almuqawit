// ignore_for_file: public_member_api_docs

import 'dart:convert';
import '../../domain/entities/sync_status.dart';
import '../../domain/repositories/sync_repository.dart';
import '../datasources/local/sync_local_datasource.dart';
import '../models/sync_record_model.dart';

class SyncRepositoryImpl implements SyncRepository {
  final SyncLocalDataSource local;
  SyncRepositoryImpl(this.local);

  @override
  Future<SyncStatus> checkStatus() async {
    // مبدئياً نعيد idle
    return SyncStatus.idle;
  }

  @override
  Future<void> queueOperation(String entity, String operation, Map<String, Object?> payload) async {
    await local.enqueue(entity: entity, operation: operation, payloadJson: jsonEncode(payload));
  }

  @override
  Future<SyncStatus> syncAll() async {
    try {
      final List<SyncRecordModel> pending = await local.getPending(limit: 100);
      for (final SyncRecordModel r in pending) {
        try {
          await local.markProcessing(r.id!);
          // TODO: إرسال العملية إلى السحابة ثم تعديل قواعد البيانات إذا لزم
          await local.markDone(r.id!);
        } catch (_) {
          await local.incrementRetry(r.id!);
          await local.markFailed(r.id!);
        }
      }
      return SyncStatus.success;
    } catch (_) {
      return SyncStatus.failure;
    }
  }
}
