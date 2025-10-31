// ignore_for_file: public_member_api_docs

import '../entities/sync_status.dart';

abstract class SyncRepository {
  Future<SyncStatus> syncAll();
  Future<SyncStatus> checkStatus();
  Future<void> queueOperation(String entity, String operation, Map<String, Object?> payload);
}
