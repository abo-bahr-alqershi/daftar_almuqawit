import 'package:get_it/get_it.dart';

import 'sync_service.dart';
import 'offline_queue.dart';
import 'conflict_resolver.dart';

class SyncManager {
  final _sl = GetIt.instance;

  SyncService get _service => _sl<SyncService>();
  OfflineQueue get _offlineQueue => _sl<OfflineQueue>();
  ConflictResolver get _resolver => _sl<ConflictResolver>();

  Future<void> syncNow() => _service.syncOnce();
  void startAuto() => _service.startAutoSync();
  Future<void> stopAuto() => _service.stopAutoSync();
  Future<void> resolveConflicts() => _resolver.resolveAll();

  Future<void> enqueue(String entity, String operation, Map<String, Object?> payload) =>
      _offlineQueue.enqueue(entity, operation, payload);

  Future<int> pendingCount() => _offlineQueue.pendingCount();
}
