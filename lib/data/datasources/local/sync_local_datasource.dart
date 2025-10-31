// ignore_for_file: public_member_api_docs

import '../../database/tables/sync_queue_table.dart';
import 'base_local_datasource.dart';
import '../../models/sync_record_model.dart';

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

  Future<List<SyncRecordModel>> getPending({int limit = 50}) async {
    final database = await db;
    final rows = await database.query(
      SyncQueueTable.table,
      where: '${SyncQueueTable.cStatus} = ?',
      whereArgs: const ['pending'],
      orderBy: '${SyncQueueTable.cCreatedAt} ASC',
      limit: limit,
    );
    return rows.map((e) => SyncRecordModel.fromMap(e)).toList();
  }

  Future<void> markProcessing(int id) async {
    final database = await db;
    await database.update(
      SyncQueueTable.table,
      {SyncQueueTable.cStatus: 'processing'},
      where: '${SyncQueueTable.cId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> markDone(int id) async {
    final database = await db;
    await database.update(
      SyncQueueTable.table,
      {SyncQueueTable.cStatus: 'done'},
      where: '${SyncQueueTable.cId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> markFailed(int id) async {
    final database = await db;
    await database.update(
      SyncQueueTable.table,
      {SyncQueueTable.cStatus: 'failed'},
      where: '${SyncQueueTable.cId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> incrementRetry(int id) async {
    final database = await db;
    await database.rawUpdate(
      'UPDATE ${SyncQueueTable.table} SET ${SyncQueueTable.cRetryCount} = ${SyncQueueTable.cRetryCount} + 1 WHERE ${SyncQueueTable.cId} = ?',
      [id],
    );
  }
}
