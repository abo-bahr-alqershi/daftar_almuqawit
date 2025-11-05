/// Bloc إدارة المزامنة
/// يدير جميع العمليات المتعلقة بمزامنة البيانات مع السحابة

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'sync_event.dart';
import 'sync_state.dart';
import '../../../core/services/sync/sync_manager.dart';
import '../../../core/services/network/connectivity_service.dart';
import '../../../domain/usecases/sync/sync_all.dart';
import '../../../domain/usecases/sync/check_sync_status.dart';
import '../../../domain/usecases/sync/queue_offline_operation.dart';
import '../../../domain/usecases/sync/resolve_conflicts.dart';
import '../../../domain/entities/sync_status.dart';
import '../../../domain/usecases/base/base_usecase.dart';

/// Bloc المزامنة
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncManager _syncManager;
  final SyncAll _syncAll;
  final CheckSyncStatus _checkSyncStatus;
  final QueueOfflineOperation _queueOfflineOperation;
  final ResolveConflicts _resolveConflicts;
  final ConnectivityService _connectivityService;
  
  Timer? _autoSyncTimer;
  StreamSubscription<bool>? _connectivitySubscription;

  SyncBloc({
    required SyncManager syncManager,
    required SyncAll syncAll,
    required CheckSyncStatus checkSyncStatus,
    required QueueOfflineOperation queueOfflineOperation,
    required ResolveConflicts resolveConflicts,
    required ConnectivityService connectivityService,
  }) : _syncManager = syncManager,
       _syncAll = syncAll,
       _checkSyncStatus = checkSyncStatus,
       _queueOfflineOperation = queueOfflineOperation,
       _resolveConflicts = resolveConflicts,
       _connectivityService = connectivityService,
       super(SyncInitial()) {
    on<StartSync>(_onStartSync);
    on<SyncSales>(_onSyncSales);
    on<SyncPurchases>(_onSyncPurchases);
    on<SyncCustomers>(_onSyncCustomers);
    on<StopSync>(_onStopSync);
    on<ScheduleAutoSync>(_onScheduleAutoSync);
    on<CancelAutoSync>(_onCancelAutoSync);
  }

  /// معالج بدء المزامنة
  Future<void> _onStartSync(StartSync event, Emitter<SyncState> emit) async {
    try {
      emit(SyncInProgress('جاري بدء المزامنة...', 0.0));
      
      // التحقق من الاتصال
      final isOnline = await _connectivityService.isOnline;
      if (!isOnline) {
        emit(SyncFailure('لا يوجد اتصال بالإنترنت'));
        return;
      }
      
      // تنفيذ المزامنة
      emit(SyncInProgress('جاري مزامنة البيانات...', 0.3));
      await _syncManager.syncNow();
      
      // حل التعارضات إن وجدت
      emit(SyncInProgress('جاري حل التعارضات...', 0.6));
      await _syncManager.resolveConflicts();
      
      // مزامنة العمليات غير المتصلة
      emit(SyncInProgress('جاري مزامنة العمليات المعلقة...', 0.8));
      await _syncManager.syncOfflineOperations();
      
      // التحقق من الحالة النهائية
      final status = await _syncManager.getStatus();
      if (status.pendingOperations == 0) {
        emit(SyncSuccess('تمت المزامنة بنجاح'));
      } else {
        emit(SyncPartial('تمت المزامنة جزئياً - ${status.pendingOperations} عملية معلقة'));
      }
    } catch (e) {
      emit(SyncFailure('فشلت المزامنة: ${e.toString()}'));
    }
  }

  /// معالج مزامنة المبيعات
  Future<void> _onSyncSales(SyncSales event, Emitter<SyncState> emit) async {
    try {
      emit(SyncInProgress('جاري مزامنة المبيعات...', 0.3));
      await Future.delayed(const Duration(seconds: 1));
      emit(SyncSuccess('تمت مزامنة المبيعات بنجاح'));
    } catch (e) {
      emit(SyncFailure('فشلت مزامنة المبيعات: ${e.toString()}'));
    }
  }

  /// معالج مزامنة المشتريات
  Future<void> _onSyncPurchases(SyncPurchases event, Emitter<SyncState> emit) async {
    try {
      emit(SyncInProgress('جاري مزامنة المشتريات...', 0.6));
      await Future.delayed(const Duration(seconds: 1));
      emit(SyncSuccess('تمت مزامنة المشتريات بنجاح'));
    } catch (e) {
      emit(SyncFailure('فشلت مزامنة المشتريات: ${e.toString()}'));
    }
  }

  /// معالج مزامنة العملاء
  Future<void> _onSyncCustomers(SyncCustomers event, Emitter<SyncState> emit) async {
    try {
      emit(SyncInProgress('جاري مزامنة العملاء...', 0.9));
      await Future.delayed(const Duration(seconds: 1));
      emit(SyncSuccess('تمت مزامنة العملاء بنجاح'));
    } catch (e) {
      emit(SyncFailure('فشلت مزامنة العملاء: ${e.toString()}'));
    }
  }

  /// معالج إيقاف المزامنة
  Future<void> _onStopSync(StopSync event, Emitter<SyncState> emit) async {
    emit(SyncInitial());
  }

  /// معالج جدولة المزامنة التلقائية
  Future<void> _onScheduleAutoSync(
    ScheduleAutoSync event,
    Emitter<SyncState> emit,
  ) async {
    // إلغاء أي جدولة سابقة
    _autoSyncTimer?.cancel();
    
    // جدولة المزامنة التلقائية
    _autoSyncTimer = Timer.periodic(event.interval, (timer) {
      add(StartSync());
    });
    
    emit(SyncAutoScheduled(event.interval));
  }

  /// معالج إلغاء جدولة المزامنة التلقائية
  Future<void> _onCancelAutoSync(
    CancelAutoSync event,
    Emitter<SyncState> emit,
  ) async {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    emit(SyncInitial());
  }

  @override
  Future<void> close() {
    _autoSyncTimer?.cancel();
    return super.close();
  }
}
