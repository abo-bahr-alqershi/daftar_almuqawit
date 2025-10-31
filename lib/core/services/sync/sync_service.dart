import 'dart:async';
import 'package:get_it/get_it.dart';

import '../network/connectivity_service.dart';
import '../../../domain/repositories/sync_repository.dart';
import '../logger_service.dart';

class SyncService {
  final _sl = GetIt.instance;
  StreamSubscription<bool>? _subscription;

  Future<void> syncOnce() async {
    final logger = _sl<LoggerService>();
    final online = await _sl<ConnectivityService>().isOnline;
    if (!online) {
      logger.i('Sync skipped: offline');
      return;
    }
    logger.i('Sync started');
    await _sl<SyncRepository>().syncAll();
    logger.i('Sync finished');
  }

  void startAutoSync() {
    _subscription?.cancel();
    _subscription = _sl<ConnectivityService>().onStatusChange.listen((online) {
      if (online) {
        syncOnce();
      }
    });
  }

  Future<void> disposeAutoSync() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
