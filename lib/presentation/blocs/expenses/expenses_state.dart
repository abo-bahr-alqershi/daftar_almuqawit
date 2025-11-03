/// حالات Bloc المصروفات
/// تحتوي على جميع الحالات الممكنة لإدارة المصروفات

import 'package:equatable/equatable.dart';
import '../../../domain/entities/expense.dart';

/// الحالة الأساسية للمصروفات
abstract class ExpensesState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class ExpensesInitial extends ExpensesState {}

/// حالة التحميل
class ExpensesLoading extends ExpensesState {}

/// حالة تحميل المصروفات بنجاح
class ExpensesLoaded extends ExpensesState {
  final List<Expense> expenses;
  ExpensesLoaded(this.expenses);
  
  @override
  List<Object?> get props => [expenses];
}

/// حالة حدوث خطأ
class ExpensesError extends ExpensesState {
  final String message;
  ExpensesError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// حالة نجاح العملية
class ExpenseOperationSuccess extends ExpensesState {
  final String message;
  ExpenseOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
