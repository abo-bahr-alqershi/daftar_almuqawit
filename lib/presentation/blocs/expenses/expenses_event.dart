/// أحداث Bloc المصروفات
/// تحتوي على جميع الأحداث المتعلقة بإدارة المصروفات

import '../../../domain/entities/expense.dart';

/// الحدث الأساسي للمصروفات
abstract class ExpensesEvent {}

/// حدث تحميل جميع المصروفات
class LoadExpenses extends ExpensesEvent {}

/// حدث تحميل مصروفات اليوم
class LoadTodayExpenses extends ExpensesEvent {
  final String date;
  LoadTodayExpenses(this.date);
}

/// حدث تحميل مصروفات حسب النوع
class LoadExpensesByType extends ExpensesEvent {
  final String type;
  LoadExpensesByType(this.type);
}

/// حدث إضافة مصروف جديد
class AddExpenseEvent extends ExpensesEvent {
  final Expense expense;
  AddExpenseEvent(this.expense);
}

/// حدث تحديث مصروف
class UpdateExpenseEvent extends ExpensesEvent {
  final Expense expense;
  UpdateExpenseEvent(this.expense);
}

/// حدث حذف مصروف
class DeleteExpenseEvent extends ExpensesEvent {
  final int id;
  DeleteExpenseEvent(this.id);
}
