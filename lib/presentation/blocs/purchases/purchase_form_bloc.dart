/// Bloc إدارة نموذج المشتريات
/// يدير حالة نموذج إضافة وتعديل المشتريات

import 'package:bloc/bloc.dart';
import 'purchase_form_event.dart';
import 'purchase_form_state.dart';

/// Bloc نموذج المشتريات
class PurchaseFormBloc extends Bloc<PurchaseFormEvent, PurchaseFormState> {
  
  PurchaseFormBloc() : super(PurchaseFormInitial()) {
    on<LoadPurchaseForEdit>(_onLoadPurchaseForEdit);
    on<PurchaseSupplierChanged>(_onSupplierChanged);
    on<PurchaseAmountChanged>(_onAmountChanged);
    on<SavePurchase>(_onSavePurchase);
  }

  Future<void> _onLoadPurchaseForEdit(LoadPurchaseForEdit event, Emitter<PurchaseFormState> emit) async {
    try {
      emit(PurchaseFormLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(PurchaseFormReady(supplierId: 'supplier_1', amount: 500.0, isValid: true));
    } catch (e) {
      emit(PurchaseFormError('فشل تحميل بيانات المشتريات: ${e.toString()}'));
    }
  }

  void _onSupplierChanged(PurchaseSupplierChanged event, Emitter<PurchaseFormState> emit) {
    final currentState = state;
    if (currentState is PurchaseFormReady) {
      emit(currentState.copyWith(supplierId: event.supplierId, isValid: event.supplierId.isNotEmpty && currentState.amount > 0));
    }
  }

  void _onAmountChanged(PurchaseAmountChanged event, Emitter<PurchaseFormState> emit) {
    final currentState = state;
    if (currentState is PurchaseFormReady) {
      emit(currentState.copyWith(amount: event.amount, isValid: currentState.supplierId.isNotEmpty && event.amount > 0));
    }
  }

  Future<void> _onSavePurchase(SavePurchase event, Emitter<PurchaseFormState> emit) async {
    final currentState = state;
    if (currentState is PurchaseFormReady) {
      try {
        emit(PurchaseFormLoading());
        await Future.delayed(const Duration(seconds: 1));
        emit(PurchaseFormSuccess('تم حفظ المشتريات بنجاح'));
      } catch (e) {
        emit(PurchaseFormError('فشل حفظ المشتريات: ${e.toString()}'));
      }
    }
  }
}
