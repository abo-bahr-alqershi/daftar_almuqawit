/// Bloc إدارة المشتريات
/// يدير جميع العمليات المتعلقة بالمشتريات من الموردين

import 'package:bloc/bloc.dart';
import '../../../domain/usecases/base/base_usecase.dart';
import '../../../domain/usecases/purchases/add_purchase.dart';
import '../../../domain/usecases/purchases/cancel_purchase.dart';
import '../../../domain/usecases/purchases/delete_purchase.dart';
import '../../../domain/usecases/purchases/get_purchases.dart';
import '../../../domain/usecases/purchases/get_purchases_by_supplier.dart';
import '../../../domain/usecases/purchases/get_today_purchases.dart';
import '../../../domain/usecases/purchases/update_purchase.dart';
import 'purchases_event.dart';
import 'purchases_state.dart';

/// Bloc المشتريات
class PurchasesBloc extends Bloc<PurchasesEvent, PurchasesState> {
  final GetPurchases getPurchases;
  final GetTodayPurchases getTodayPurchases;
  final GetPurchasesBySupplier getPurchasesBySupplier;
  final AddPurchase addPurchase;
  final UpdatePurchase updatePurchase;
  final DeletePurchase deletePurchase;
  final CancelPurchase cancelPurchase;

  PurchasesBloc({
    required this.getPurchases,
    required this.getTodayPurchases,
    required this.getPurchasesBySupplier,
    required this.addPurchase,
    required this.updatePurchase,
    required this.deletePurchase,
    required this.cancelPurchase,
  }) : super(PurchasesInitial()) {
    on<LoadPurchases>(_onLoadPurchases);
    on<LoadPurchaseById>(_onLoadPurchaseById);
    on<LoadTodayPurchases>(_onLoadTodayPurchases);
    on<LoadPurchasesBySupplier>(_onLoadPurchasesBySupplier);
    on<AddPurchaseEvent>(_onAddPurchase);
    on<UpdatePurchaseEvent>(_onUpdatePurchase);
    on<DeletePurchaseEvent>(_onDeletePurchase);
    on<CancelPurchaseEvent>(_onCancelPurchase);
  }

  /// معالج تحميل مشترى معين بالمعرف
  Future<void> _onLoadPurchaseById(LoadPurchaseById event, Emitter<PurchasesState> emit) async {
    try {
      emit(PurchasesLoading());
      final purchases = await getPurchases(NoParams());
      final purchase = purchases.firstWhere(
        (p) => p.id.toString() == event.purchaseId,
        orElse: () => throw Exception('Purchase not found'),
      );
      emit(PurchaseLoaded(purchase));
    } catch (e) {
      emit(PurchasesError('فشل تحميل تفاصيل المشترى: ${e.toString()}'));
    }
  }

  /// معالج تحميل جميع المشتريات
  Future<void> _onLoadPurchases(LoadPurchases event, Emitter<PurchasesState> emit) async {
    try {
      emit(PurchasesLoading());
      final purchases = await getPurchases(NoParams());
      emit(PurchasesLoaded(purchases));
    } catch (e) {
      emit(PurchasesError('فشل تحميل المشتريات: ${e.toString()}'));
    }
  }

  /// معالج تحميل مشتريات اليوم
  Future<void> _onLoadTodayPurchases(LoadTodayPurchases event, Emitter<PurchasesState> emit) async {
    try {
      emit(PurchasesLoading());
      final purchases = await getTodayPurchases(event.date);
      emit(PurchasesLoaded(purchases));
    } catch (e) {
      emit(PurchasesError('فشل تحميل مشتريات اليوم: ${e.toString()}'));
    }
  }

  /// معالج تحميل مشتريات مورد معين
  Future<void> _onLoadPurchasesBySupplier(LoadPurchasesBySupplier event, Emitter<PurchasesState> emit) async {
    try {
      emit(PurchasesLoading());
      final purchases = await getPurchasesBySupplier(event.supplierId);
      emit(PurchasesLoaded(purchases));
    } catch (e) {
      emit(PurchasesError('فشل تحميل مشتريات المورد: ${e.toString()}'));
    }
  }

  /// معالج إضافة مشترى جديد
  Future<void> _onAddPurchase(AddPurchaseEvent event, Emitter<PurchasesState> emit) async {
    try {
      await addPurchase(event.purchase);
      emit(PurchaseOperationSuccess('تم إضافة المشترى بنجاح'));
      add(LoadPurchases());
    } catch (e) {
      emit(PurchasesError('فشل إضافة المشترى: ${e.toString()}'));
    }
  }

  /// معالج تحديث مشترى
  Future<void> _onUpdatePurchase(UpdatePurchaseEvent event, Emitter<PurchasesState> emit) async {
    try {
      await updatePurchase(event.purchase);
      emit(PurchaseOperationSuccess('تم تحديث المشترى بنجاح'));
      add(LoadPurchases());
    } catch (e) {
      emit(PurchasesError('فشل تحديث المشترى: ${e.toString()}'));
    }
  }

  /// معالج حذف مشترى
  Future<void> _onDeletePurchase(DeletePurchaseEvent event, Emitter<PurchasesState> emit) async {
    try {
      await deletePurchase(event.id);
      emit(PurchaseOperationSuccess('تم حذف المشترى بنجاح'));
      add(LoadPurchases());
    } catch (e) {
      emit(PurchasesError('فشل حذف المشترى: ${e.toString()}'));
    }
  }

  /// معالج إلغاء مشترى
  Future<void> _onCancelPurchase(CancelPurchaseEvent event, Emitter<PurchasesState> emit) async {
    try {
      await cancelPurchase(event.id);
      emit(PurchaseOperationSuccess('تم إلغاء المشترى بنجاح'));
      add(LoadPurchases());
    } catch (e) {
      emit(PurchasesError('فشل إلغاء المشترى: ${e.toString()}'));
    }
  }
}
