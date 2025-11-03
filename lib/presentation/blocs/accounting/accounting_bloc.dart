/// Bloc إدارة المحاسبة
/// يدير جميع العمليات المتعلقة بالمحاسبة والمعاملات المالية

import 'package:bloc/bloc.dart';
import '../../../domain/repositories/sales_repository.dart';
import '../../../domain/repositories/purchase_repository.dart';
import '../../../domain/repositories/expense_repository.dart';
import 'accounting_event.dart';
import 'accounting_state.dart';

/// Bloc المحاسبة
class AccountingBloc extends Bloc<AccountingEvent, AccountingState> {
  final SalesRepository salesRepository;
  final PurchaseRepository purchaseRepository;
  final ExpenseRepository expenseRepository;

  AccountingBloc({
    required this.salesRepository,
    required this.purchaseRepository,
    required this.expenseRepository,
  }) : super(AccountingInitial()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<CalculateBalance>(_onCalculateBalance);
  }

  /// معالج تحميل الحسابات
  Future<void> _onLoadAccounts(LoadAccounts event, Emitter<AccountingState> emit) async {
    try {
      emit(AccountingLoading());
      // حساب الإجماليات
      final sales = await salesRepository.getAll();
      final purchases = await purchaseRepository.getAll();
      final expenses = await expenseRepository.getAll();
      
      final totalIncome = sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
      final totalExpenses = purchases.fold<double>(0, (sum, purchase) => sum + purchase.totalAmount) +
                           expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
      final balance = totalIncome - totalExpenses;
      
      emit(AccountingLoaded(
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        balance: balance,
        transactions: [],
      ));
    } catch (e) {
      emit(AccountingError('فشل تحميل الحسابات: ${e.toString()}'));
    }
  }

  /// معالج تحميل المعاملات
  Future<void> _onLoadTransactions(LoadTransactions event, Emitter<AccountingState> emit) async {
    try {
      emit(AccountingLoading());
      // تحميل المعاملات حسب الفلاتر
      emit(AccountingLoaded(
        totalIncome: 0,
        totalExpenses: 0,
        balance: 0,
        transactions: [],
      ));
    } catch (e) {
      emit(AccountingError('فشل تحميل المعاملات: ${e.toString()}'));
    }
  }

  /// معالج إضافة معاملة
  Future<void> _onAddTransaction(AddTransaction event, Emitter<AccountingState> emit) async {
    try {
      // إضافة معاملة جديدة
      add(LoadAccounts());
    } catch (e) {
      emit(AccountingError('فشل إضافة المعاملة: ${e.toString()}'));
    }
  }

  /// معالج حساب الرصيد
  Future<void> _onCalculateBalance(CalculateBalance event, Emitter<AccountingState> emit) async {
    try {
      add(LoadAccounts());
    } catch (e) {
      emit(AccountingError('فشل حساب الرصيد: ${e.toString()}'));
    }
  }
}
