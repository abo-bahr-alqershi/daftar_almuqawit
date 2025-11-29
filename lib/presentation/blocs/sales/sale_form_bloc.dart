/// Bloc إدارة نموذج المبيعات
/// يدير حالة نموذج إضافة وتعديل المبيعات

import 'package:bloc/bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/sale.dart';
import '../../../domain/usecases/sales/add_sale.dart';
import 'sale_form_event.dart';
import 'sale_form_state.dart';

/// Bloc نموذج المبيعات
class SaleFormBloc extends Bloc<SaleFormEvent, SaleFormState> {
  final AddSale? _addSaleUseCase;
  
  SaleFormBloc({AddSale? addSaleUseCase}) 
      : _addSaleUseCase = addSaleUseCase ?? sl<AddSale>(),
        super(SaleFormInitial()) {
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
    try {
      emit(SaleFormLoading());
      
      // تحويل البيانات إلى كائن Sale
      final sale = Sale(
        id: 0, // سيتم توليد ID تلقائيًا من قاعدة البيانات
        date: event.saleData['date'] as String,
        time: event.saleData['time'] as String,
        customerId: event.saleData['customerId'] as int?,
        customerName: event.saleData['customerName'] as String?,
        qatTypeId: event.saleData['qatTypeId'] as int,
        qatTypeName: event.saleData['qatTypeName'] as String?,
        quantity: event.saleData['quantity'] as double,
        unit: event.saleData['unit'] as String,
        unitPrice: event.saleData['unitPrice'] as double,
        totalAmount: event.saleData['totalAmount'] as double,
        discount: event.saleData['discount'] as double? ?? 0.0,
        paymentStatus: _calculatePaymentStatus(
          event.saleData['totalAmount'] as double,
          event.saleData['paidAmount'] as double? ?? 0.0,
        ),
        paymentMethod: event.saleData['paymentMethod'] as String,
        paidAmount: event.saleData['paidAmount'] as double? ?? 0.0,
        remainingAmount: (event.saleData['totalAmount'] as double) - 
                        (event.saleData['paidAmount'] as double? ?? 0.0),
        dueDate: event.saleData['dueDate'] as String?,
        invoiceNumber: event.saleData['invoiceNumber'] as String?,
        notes: event.saleData['notes'] as String?,
        isQuickSale: false,
      );
      
      // حفظ البيع في قاعدة البيانات
      final saleId = await _addSaleUseCase!(sale);
      
      emit(SaleFormSuccess('تم حفظ البيع بنجاح - رقم البيع: $saleId'));
    } catch (e) {
      emit(SaleFormError('فشل حفظ البيع: ${e.toString()}'));
    }
  }
  
  /// حساب حالة الدفع
  String _calculatePaymentStatus(double totalAmount, double paidAmount) {
    if (paidAmount >= totalAmount) {
      return 'مدفوع';
    } else if (paidAmount > 0) {
      return 'مدفوع جزئياً';
    } else {
      return 'غير مدفوع';
    }
  }

  /// معالج إعادة تعيين النموذج
  void _onResetForm(ResetSaleForm event, Emitter<SaleFormState> emit) {
    emit(SaleFormReady());
  }
}
