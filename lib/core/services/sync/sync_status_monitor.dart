/// مراقب حالة المزامنة - يوفر معلومات مباشرة عن حالة المزامنة
/// 
/// يُستخدم في واجهة المستخدم لعرض:
/// - حالة المزامنة الحالية
/// - التقدم في المزامنة
/// - آخر وقت مزامنة
/// - الأخطاء إن وجدت

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'storage_sync_coordinator.dart';
import '../logger_service.dart';

/// مراقب حالة المزامنة
class SyncStatusMonitor extends ChangeNotifier {
  final StorageSyncCoordinator _coordinator = StorageSyncCoordinator.instance;
  final LoggerService _logger = LoggerService();

  StreamSubscription<SyncStatus>? _statusSubscription;

  // الحالة الحالية
  SyncStatus _currentStatus = SyncStatus.idle;
  String? _lastErrorMessage;
  SyncResult? _lastResult;
  SyncInfo? _syncInfo;

  // Getters
  SyncStatus get status => _currentStatus;
  String? get errorMessage => _lastErrorMessage;
  SyncResult? get lastResult => _lastResult;
  SyncInfo? get syncInfo => _syncInfo;

  bool get isSyncing => _currentStatus == SyncStatus.syncing;
  bool get hasError => _currentStatus == SyncStatus.error;
  bool get isSynced => _currentStatus == SyncStatus.synced;

  /// بدء المراقبة
  void startMonitoring() {
    _logger.info('👁️ بدء مراقبة حالة المزامنة');

    // الاشتراك في تحديثات الحالة
    _statusSubscription = _coordinator.syncStatusStream.listen(
      (status) {
        _currentStatus = status;
        _logger.info('📊 تغيرت حالة المزامنة: $status');
        notifyListeners();
      },
      onError: (error) {
        _logger.error('خطأ في مراقبة المزامنة', error: error);
        _lastErrorMessage = error.toString();
        _currentStatus = SyncStatus.error;
        notifyListeners();
      },
    );

    // تحميل معلومات المزامنة
    _loadSyncInfo();
  }

  /// إيقاف المراقبة
  void stopMonitoring() {
    _logger.info('⏹️ إيقاف مراقبة حالة المزامنة');
    _statusSubscription?.cancel();
    _statusSubscription = null;
  }

  /// تحميل معلومات المزامنة
  Future<void> _loadSyncInfo() async {
    try {
      _syncInfo = await _coordinator.getSyncInfo();
      notifyListeners();
    } catch (e) {
      _logger.error('فشل تحميل معلومات المزامنة', error: e);
    }
  }

  /// تحديث معلومات المزامنة يدوياً
  Future<void> refreshInfo() async {
    await _loadSyncInfo();
  }

  /// بدء مزامنة فورية ومراقبة النتيجة
  Future<void> triggerSync({bool forceUpload = false}) async {
    try {
      _currentStatus = SyncStatus.syncing;
      _lastErrorMessage = null;
      notifyListeners();

      final result = await _coordinator.syncNow(forceUpload: forceUpload);
      
      _lastResult = result;
      _currentStatus = result.success ? SyncStatus.synced : SyncStatus.error;
      
      if (!result.success) {
        _lastErrorMessage = result.message;
      }

      await _loadSyncInfo();
      notifyListeners();
    } catch (e) {
      _logger.error('فشلت المزامنة', error: e);
      _currentStatus = SyncStatus.error;
      _lastErrorMessage = e.toString();
      notifyListeners();
    }
  }

  /// تشغيل المزامنة التلقائية
  void enableAutoSync({Duration interval = const Duration(minutes: 15)}) {
    _coordinator.startAutoSync(interval: interval);
    _loadSyncInfo();
  }

  /// إيقاف المزامنة التلقائية
  void disableAutoSync() {
    _coordinator.stopAutoSync();
    _loadSyncInfo();
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}

/// Widget يراقب حالة المزامنة
class SyncStatusWidget extends StatelessWidget {
  final SyncStatusMonitor monitor;
  final Widget Function(BuildContext, SyncStatus, SyncInfo?) builder;

  const SyncStatusWidget({
    Key? key,
    required this.monitor,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: monitor,
      builder: (context, _) {
        return builder(context, monitor.status, monitor.syncInfo);
      },
    );
  }
}
