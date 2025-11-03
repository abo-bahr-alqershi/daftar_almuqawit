import 'dart:async';
import 'package:get_it/get_it.dart';

import '../network/connectivity_service.dart';
import '../../../domain/repositories/sync_repository.dart';
import '../../../domain/entities/sync_status.dart';
import '../logger_service.dart';

/// خدمة المزامنة بين قاعدة البيانات المحلية والسحابية
/// 
/// توفر مزامنة يدوية وتلقائية مع إدارة التعارضات
class SyncService {
  SyncService._();
  
  static final SyncService _instance = SyncService._();
  static SyncService get instance => _instance;

  final _sl = GetIt.instance;
  
  StreamSubscription<bool>? _autoSyncSubscription;
  Timer? _periodicSyncTimer;
  
  bool _isSyncing = false;
  SyncStatus _lastStatus = SyncStatus.idle;
  DateTime? _lastSyncTime;
  
  final StreamController<SyncStatus> _statusController = 
      StreamController<SyncStatus>.broadcast();

  // ========== الحالة ==========

  /// حالة المزامنة الحالية
  SyncStatus get status => _lastStatus;

  /// هل تتم المزامنة الآن
  bool get isSyncing => _isSyncing;

  /// وقت آخر مزامنة
  DateTime? get lastSyncTime => _lastSyncTime;

  /// مراقبة حالة المزامنة
  Stream<SyncStatus> get onStatusChange => _statusController.stream;

  // ========== المزامنة اليدوية ==========

  /// تنفيذ مزامنة واحدة
  Future<SyncStatus> syncOnce() async {
    if (_isSyncing) {
      _log('المزامنة جارية بالفعل');
      return _lastStatus;
    }

    // فحص الاتصال
    final online = await _sl<ConnectivityService>().isOnline;
    if (!online) {
      _log('المزامنة متوقفة: لا يوجد اتصال');
      _updateStatus(SyncStatus.idle);
      return SyncStatus.idle;
    }

    _isSyncing = true;
    _updateStatus(SyncStatus.syncing);
    _log('بدء المزامنة');

    try {
      final result = await _sl<SyncRepository>().syncAll();
      _lastSyncTime = DateTime.now();
      _updateStatus(result);
      _log('انتهت المزامنة: $result');
      return result;
    } catch (e) {
      _log('خطأ في المزامنة: $e');
      _updateStatus(SyncStatus.failed);
      return SyncStatus.failed;
    } finally {
      _isSyncing = false;
    }
  }

  // ========== المزامنة التلقائية ==========

  /// بدء المزامنة التلقائية عند الاتصال
  void startAutoSync() {
    _autoSyncSubscription?.cancel();
    
    _autoSyncSubscription = _sl<ConnectivityService>()
        .onStatusChange
        .listen((online) {
      if (online && !_isSyncing) {
        _log('الاتصال متوفر - بدء المزامنة التلقائية');
        syncOnce();
      }
    });
    
    _log('تم تفعيل المزامنة التلقائية');
  }

  /// إيقاف المزامنة التلقائية
  Future<void> stopAutoSync() async {
    await _autoSyncSubscription?.cancel();
    _autoSyncSubscription = null;
    _log('تم إيقاف المزامنة التلقائية');
  }

  // ========== المزامنة الدورية ==========

  /// بدء المزامنة الدورية
  void startPeriodicSync({Duration interval = const Duration(minutes: 15)}) {
    _periodicSyncTimer?.cancel();
    
    _periodicSyncTimer = Timer.periodic(interval, (_) {
      if (!_isSyncing) {
        _log('مزامنة دورية مجدولة');
        syncOnce();
      }
    });
    
    _log('تم تفعيل المزامنة الدورية (كل ${interval.inMinutes} دقيقة)');
  }

  /// إيقاف المزامنة الدورية
  void stopPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
    _log('تم إيقاف المزامنة الدورية');
  }

  // ========== مساعد ==========

  void _updateStatus(SyncStatus status) {
    _lastStatus = status;
    _statusController.add(status);
  }

  void _log(String message) {
    try {
      _sl<LoggerService>().i('SyncService: $message');
    } catch (_) {
      // Logger not available
    }
  }

  /// إغلاق الخدمة
  Future<void> dispose() async {
    await stopAutoSync();
    stopPeriodicSync();
    await _statusController.close();
  }
}
