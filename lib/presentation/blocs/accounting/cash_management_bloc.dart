/// Bloc إدارة الصندوق
/// يدير عمليات الصندوق والحركات النقدية

import 'package:bloc/bloc.dart';
import 'cash_management_event.dart';
import 'cash_management_state.dart';

/// Bloc إدارة الصندوق
class CashManagementBloc extends Bloc<CashManagementEvent, CashManagementState> {
  
  CashManagementBloc() : super(CashManagementInitial()) {
    on<LoadCashBalance>(_onLoadCashBalance);
    on<AddCashTransaction>(_onAddCashTransaction);
    on<LoadCashTransactions>(_onLoadCashTransactions);
  }

  /// معالج تحميل رصيد الصندوق
  Future<void> _onLoadCashBalance(LoadCashBalance event, Emitter<CashManagementState> emit) async {
    try {
      emit(CashManagementLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      emit(CashBalanceLoaded(5000.0));
    } catch (e) {
      emit(CashManagementError('فشل تحميل رصيد الصندوق: ${e.toString()}'));
    }
  }

  /// معالج إضافة حركة نقدية
  Future<void> _onAddCashTransaction(AddCashTransaction event, Emitter<CashManagementState> emit) async {
    try {
      emit(CashManagementLoading());
      await Future.delayed(const Duration(seconds: 1));
      emit(CashTransactionSuccess('تمت إضافة الحركة النقدية بنجاح'));
    } catch (e) {
      emit(CashManagementError('فشلت إضافة الحركة النقدية: ${e.toString()}'));
    }
  }

  /// معالج تحميل الحركات النقدية
  Future<void> _onLoadCashTransactions(LoadCashTransactions event, Emitter<CashManagementState> emit) async {
    try {
      emit(CashManagementLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      final transactions = [
        {'id': '1', 'type': 'إيداع', 'amount': 1000.0, 'date': '2025-01-01'},
        {'id': '2', 'type': 'سحب', 'amount': 500.0, 'date': '2025-01-02'},
      ];
      emit(CashTransactionsLoaded(transactions));
    } catch (e) {
      emit(CashManagementError('فشل تحميل الحركات النقدية: ${e.toString()}'));
    }
  }
}
