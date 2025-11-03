/// Bloc إدارة المزامنة
/// يدير جميع العمليات المتعلقة بمزامنة البيانات مع السحابة

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'sync_event.dart';
import 'sync_state.dart';

/// Bloc المزامنة
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  Timer? _autoSyncTimer;

  SyncBloc() : super(SyncInitial()) {
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
      // تنفيذ المزامنة
      await Future.delayed(const Duration(seconds: 2));
      emit(SyncSuccess('تمت المزامنة بنجاح'));
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
