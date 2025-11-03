// ignore_for_file: public_member_api_docs

import 'dart:convert';
import '../../domain/entities/sync_status.dart';
import '../../domain/repositories/sync_repository.dart';
import '../datasources/local/sync_local_datasource.dart';
import '../datasources/remote/sync_remote_datasource.dart';
import '../models/sync_record_model.dart';

class SyncRepositoryImpl implements SyncRepository {
  final SyncLocalDataSource local;
  final SyncRemoteDataSource remote;
  SyncRepositoryImpl(this.local, this.remote);

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
          final Map<String, dynamic> payload = jsonDecode(r.payloadJson) as Map<String, dynamic>;
          await remote.pushOperation(entity: r.entity, operation: r.operation, payload: payload);
          await local.markDone(r.id!);
        } catch (_) {
          await local.incrementRetry(r.id!);
          await local.markFailed(r.id!);
        }
      }
      return SyncStatus.success;
    } catch (_) {
      return SyncStatus.failed;
    }
  }
}
