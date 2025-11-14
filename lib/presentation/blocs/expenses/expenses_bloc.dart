/// Bloc إدارة المصروفات
/// يدير جميع العمليات المتعلقة بالمصروفات والنفقات

import 'package:bloc/bloc.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../../domain/usecases/expenses/add_expense.dart';
import '../../../domain/usecases/expenses/delete_expense.dart';
import '../../../domain/usecases/expenses/get_daily_expenses.dart';
import '../../../domain/usecases/expenses/get_expenses_by_category.dart';
import '../../../domain/usecases/expenses/update_expense.dart';
import '../../../domain/usecases/statistics/invalidate_daily_statistics.dart';
import 'expenses_event.dart';
import 'expenses_state.dart';

/// Bloc المصروفات
class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final ExpenseRepository repository;
  final GetDailyExpenses getTodayExpenses;
  final GetExpensesByCategory getExpensesByType;
  final AddExpense addExpense;
  final UpdateExpense updateExpense;
  final DeleteExpense deleteExpense;
  final InvalidateDailyStatistics? invalidateStatistics;

  ExpensesBloc({
    required this.repository,
    required this.getTodayExpenses,
    required this.getExpensesByType,
    required this.addExpense,
    required this.updateExpense,
    required this.deleteExpense,
    this.invalidateStatistics,
  }) : super(ExpensesInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<LoadTodayExpenses>(_onLoadTodayExpenses);
    on<LoadExpensesByType>(_onLoadExpensesByType);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
  }

  /// معالج تحميل جميع المصروفات
  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpensesState> emit,
  ) async {
    try {
      emit(ExpensesLoading());
      final expenses = await repository.getAll();
      emit(ExpensesLoaded(expenses));
    } catch (e) {
      emit(ExpensesError('فشل تحميل المصروفات: ${e.toString()}'));
    }
  }

  /// معالج تحميل مصروفات اليوم
  Future<void> _onLoadTodayExpenses(
    LoadTodayExpenses event,
    Emitter<ExpensesState> emit,
  ) async {
    try {
      emit(ExpensesLoading());
      final expenses = await getTodayExpenses(event.date);
      emit(ExpensesLoaded(expenses));
    } catch (e) {
      emit(ExpensesError('فشل تحميل مصروفات اليوم: ${e.toString()}'));
    }
  }

  /// معالج تحميل مصروفات حسب النوع
  Future<void> _onLoadExpensesByType(
    LoadExpensesByType event,
    Emitter<ExpensesState> emit,
  ) async {
    try {
      emit(ExpensesLoading());
      final expenses = await getExpensesByType(event.type);
      emit(ExpensesLoaded(expenses));
    } catch (e) {
      emit(ExpensesError('فشل تحميل مصروفات النوع: ${e.toString()}'));
    }
  }

  /// معالج إضافة مصروف جديد
  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    try {
      await addExpense(event.expense);

      // إبطال إحصائيات اليوم
      await _invalidateTodayStats(event.expense.date);

      emit(ExpenseOperationSuccess('تم إضافة المصروف بنجاح'));
      add(LoadExpenses());
    } catch (e) {
      emit(ExpensesError('فشل إضافة المصروف: ${e.toString()}'));
    }
  }

  /// معالج تحديث مصروف
  Future<void> _onUpdateExpense(
    UpdateExpenseEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    try {
      await updateExpense(event.expense);

      // إبطال إحصائيات اليوم
      await _invalidateTodayStats(event.expense.date);

      emit(ExpenseOperationSuccess('تم تحديث المصروف بنجاح'));
      add(LoadExpenses());
    } catch (e) {
      emit(ExpensesError('فشل تحديث المصروف: ${e.toString()}'));
    }
  }

  /// معالج حذف مصروف
  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    try {
      await deleteExpense(event.id);

      // إبطال إحصائيات اليوم
      await _invalidateTodayStats(
        DateTime.now().toIso8601String().split('T')[0],
      );

      emit(ExpenseOperationSuccess('تم حذف المصروف بنجاح'));
      add(LoadExpenses());
    } catch (e) {
      emit(ExpensesError('فشل حذف المصروف: ${e.toString()}'));
    }
  }

  /// إبطال إحصائيات يوم محدد
  Future<void> _invalidateTodayStats(String date) async {
    if (invalidateStatistics != null) {
      try {
        await invalidateStatistics!(
          InvalidateDailyStatisticsParams(date: date),
        );
      } catch (e) {
        // تجاهل الأخطاء في إبطال الإحصائيات
        emit(ExpensesError('فشل حذف المصروف: ${e.toString()}'));
      }
    }
  }
}
