/// Bloc إدارة نموذج المبيعات
/// يدير حالة نموذج إضافة وتعديل المبيعات

import 'package:bloc/bloc.dart';
import 'sale_form_event.dart';
import 'sale_form_state.dart';

/// Bloc نموذج المبيعات
class SaleFormBloc extends Bloc<SaleFormEvent, SaleFormState> {
  
  SaleFormBloc() : super(SaleFormInitial()) {
    on<LoadSaleForEdit>(_onLoadSaleForEdit);
    on<SaleCustomerChanged>(_onCustomerChanged);
    on<SaleAmountChanged>(_onAmountChanged);
    on<AddProductToSale>(_onAddProduct);
    on<SaveSale>(_onSaveSale);
    on<ResetSaleForm>(_onResetForm);
  }

  /// معالج تحميل بيانات المبيعة للتعديل
  Future<void> _onLoadSaleForEdit(LoadSaleForEdit event, Emitter<SaleFormState> emit) async {
    try {
      emit(SaleFormLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(SaleFormReady(
        customerId: 'customer_1',
        amount: 1000.0,
        isValid: true,
      ));
    } catch (e) {
      emit(SaleFormError('فشل تحميل بيانات المبيعة: ${e.toString()}'));
    }
  }

  /// معالج تغيير العميل
  void _onCustomerChanged(SaleCustomerChanged event, Emitter<SaleFormState> emit) {
    final currentState = state;
    if (currentState is SaleFormReady) {
      emit(currentState.copyWith(
        customerId: event.customerId,
        isValid: event.customerId.isNotEmpty && currentState.amount > 0,
      ));
    }
  }

  /// معالج تغيير المبلغ
  void _onAmountChanged(SaleAmountChanged event, Emitter<SaleFormState> emit) {
    final currentState = state;
    if (currentState is SaleFormReady) {
      emit(currentState.copyWith(
        amount: event.amount,
        isValid: currentState.customerId.isNotEmpty && event.amount > 0,
      ));
    }
  }

  /// معالج إضافة منتج
  void _onAddProduct(AddProductToSale event, Emitter<SaleFormState> emit) {
    final currentState = state;
    if (currentState is SaleFormReady) {
      final products = List<Map<String, dynamic>>.from(currentState.products);
      products.add({'productId': event.productId, 'quantity': event.quantity});
      emit(currentState.copyWith(products: products));
    }
  }

  /// معالج حفظ المبيعة
  Future<void> _onSaveSale(SaveSale event, Emitter<SaleFormState> emit) async {
    final currentState = state;
    if (currentState is SaleFormReady) {
      try {
        emit(SaleFormLoading());
        await Future.delayed(const Duration(seconds: 1));
        emit(SaleFormSuccess('تم حفظ المبيعة بنجاح'));
      } catch (e) {
        emit(SaleFormError('فشل حفظ المبيعة: ${e.toString()}'));
      }
    }
  }

  /// معالج إعادة تعيين النموذج
  void _onResetForm(ResetSaleForm event, Emitter<SaleFormState> emit) {
    emit(SaleFormReady());
  }
}
