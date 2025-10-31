// ignore_for_file: public_member_api_docs

import '../../database/tables/sync_queue_table.dart';
import 'base_local_datasource.dart';

/// مصدر بيانات محلي لقائمة المزامنة
class SyncLocalDataSource extends BaseLocalDataSource {
  SyncLocalDataSource(super.dbHelper);

  Future<int> enqueue({
    required String entity,
    required String operation,
    required String payloadJson,
  }) async {
    final database = await db;
    return database.insert(SyncQueueTable.table, {
      SyncQueueTable.cEntity: entity,
      SyncQueueTable.cOperation: operation,
      SyncQueueTable.cPayload: payloadJson,
    });
  }
}
