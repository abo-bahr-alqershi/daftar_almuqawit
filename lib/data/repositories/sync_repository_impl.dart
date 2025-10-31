// ignore_for_file: public_member_api_docs

import 'dart:convert';
import '../../domain/entities/sync_status.dart';
import '../../domain/repositories/sync_repository.dart';
import '../datasources/local/sync_local_datasource.dart';

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
    // لاحقاً: تنفيذ المزامنة مع السحابة
    return SyncStatus.success;
  }
}
