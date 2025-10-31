import 'package:get_it/get_it.dart';

import '../../../domain/repositories/sync_repository.dart';
import 'sync_queue.dart';
import 'sync_service.dart';

class OfflineQueue {
  final _sl = GetIt.instance;

  SyncRepository get _repo => _sl<SyncRepository>();
  SyncQueue get _queue => _sl<SyncQueue>();
  SyncService get _service => _sl<SyncService>();

  Future<void> enqueue(String entity, String operation, Map<String, Object?> payload) async {
    await _repo.queueOperation(entity, operation, payload);
  }

  Future<int> pendingCount() async => (await _queue.getPending(limit: 1 << 20)).length;

  Future<void> drain() => _service.syncOnce();
}
