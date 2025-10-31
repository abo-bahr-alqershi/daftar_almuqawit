import 'package:get_it/get_it.dart';

import '../../../data/datasources/local/sync_local_datasource.dart';
import '../../../data/models/sync_record_model.dart';

class SyncQueue {
  final _sl = GetIt.instance;

  SyncLocalDataSource get _local => _sl<SyncLocalDataSource>();

  Future<List<SyncRecordModel>> getPending({int limit = 50}) => _local.getPending(limit: limit);
  Future<void> markProcessing(int id) => _local.markProcessing(id);
  Future<void> markDone(int id) => _local.markDone(id);
  Future<void> markFailed(int id) => _local.markFailed(id);
  Future<void> incrementRetry(int id) => _local.incrementRetry(id);
}
