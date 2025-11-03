// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import '../../../../domain/entities/sale.dart';
import '../../../../domain/usecases/sales/quick_sale.dart';
import 'quick_sale_event.dart';
import 'quick_sale_state.dart';

class QuickSaleBloc extends Bloc<QuickSaleEvent, QuickSaleState> {
  final QuickSale quickSaleUseCase;

  QuickSaleBloc({required this.quickSaleUseCase}) : super(QuickSaleInitial()) {
    on<InitializeQuickSale>(_onInitialize);
    on<AddItemToSale>(_onAddItem);
    on<RemoveItemFromSale>(_onRemoveItem);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<SetPaidAmount>(_onSetPaidAmount);
    on<CompleteSale>(_onCompleteSale);
    on<CancelSale>(_onCancelSale);
  }

  void _onInitialize(InitializeQuickSale event, Emitter<QuickSaleState> emit) {
    emit(QuickSaleInProgress(items: [], totalAmount: 0));
  }

  void _onAddItem(AddItemToSale event, Emitter<QuickSaleState> emit) {
    final currentState = state;
    if (currentState is! QuickSaleInProgress) return;

    final newItem = SaleItem(
      name: event.qatType.name,
      quantity: event.quantity,
      price: event.price,
      total: event.quantity * event.price,
    );

    final newItems = List<SaleItem>.from(currentState.items)..add(newItem);
    final newTotal = newItems.fold<double>(0, (sum, item) => sum + item.total);

    emit(QuickSaleInProgress(
      items: newItems,
      totalAmount: newTotal,
      paymentMethod: currentState.paymentMethod,
      paidAmount: currentState.paidAmount,
      remainingAmount: newTotal - currentState.paidAmount,
    ));
  }

  void _onRemoveItem(RemoveItemFromSale event, Emitter<QuickSaleState> emit) {
    final currentState = state;
    if (currentState is! QuickSaleInProgress) return;

    final newItems = List<SaleItem>.from(currentState.items)..removeAt(event.index);
    final newTotal = newItems.fold<double>(0, (sum, item) => sum + item.total);

    emit(QuickSaleInProgress(
      items: newItems,
      totalAmount: newTotal,
      paymentMethod: currentState.paymentMethod,
      paidAmount: currentState.paidAmount,
      remainingAmount: newTotal - currentState.paidAmount,
    ));
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<QuickSaleState> emit) {
    final currentState = state;
    if (currentState is! QuickSaleInProgress) return;

    final newItems = List<SaleItem>.from(currentState.items);
    final item = newItems[event.index];
    newItems[event.index] = SaleItem(
      name: item.name,
      quantity: event.quantity,
      price: item.price,
      total: event.quantity * item.price,
    );

    final newTotal = newItems.fold<double>(0, (sum, item) => sum + item.total);

    emit(QuickSaleInProgress(
      items: newItems,
      totalAmount: newTotal,
      paymentMethod: currentState.paymentMethod,
      paidAmount: currentState.paidAmount,
      remainingAmount: newTotal - currentState.paidAmount,
    ));
  }

  void _onSelectPaymentMethod(SelectPaymentMethod event, Emitter<QuickSaleState> emit) {
    final currentState = state;
    if (currentState is! QuickSaleInProgress) return;

    emit(QuickSaleInProgress(
      items: currentState.items,
      totalAmount: currentState.totalAmount,
      paymentMethod: event.method,
      paidAmount: currentState.paidAmount,
      remainingAmount: currentState.remainingAmount,
    ));
  }

  void _onSetPaidAmount(SetPaidAmount event, Emitter<QuickSaleState> emit) {
    final currentState = state;
    if (currentState is! QuickSaleInProgress) return;

    emit(QuickSaleInProgress(
      items: currentState.items,
      totalAmount: currentState.totalAmount,
      paymentMethod: currentState.paymentMethod,
      paidAmount: event.amount,
      remainingAmount: currentState.totalAmount - event.amount,
    ));
  }

  Future<void> _onCompleteSale(CompleteSale event, Emitter<QuickSaleState> emit) async {
    final currentState = state;
    if (currentState is! QuickSaleInProgress) return;

    if (currentState.items.isEmpty) {
      emit(QuickSaleError('لا يمكن إتمام بيع فارغ'));
      return;
    }

    try {
      final params = QuickSaleParams(
        customerId: event.customerId,
        qatTypeId: 1, // سيتم تحديثه لاحقاً
        quantity: currentState.items.first.quantity,
        unit: 'كيلو',
        unitPrice: currentState.items.first.price,
        paidAmount: currentState.paidAmount,
        notes: null,
      );

      final saleId = await quickSaleUseCase(params);
      emit(QuickSaleCompleted('تم إتمام البيع بنجاح', saleId));
    } catch (e) {
      emit(QuickSaleError('فشل إتمام البيع: ${e.toString()}'));
    }
  }

  void _onCancelSale(CancelSale event, Emitter<QuickSaleState> emit) {
    emit(QuickSaleInitial());
  }
}
