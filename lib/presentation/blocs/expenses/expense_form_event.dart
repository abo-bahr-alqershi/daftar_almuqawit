/// أحداث Bloc نموذج المصروفات
abstract class ExpenseFormEvent {}

class ExpenseAmountChanged extends ExpenseFormEvent {
  final double amount;
  ExpenseAmountChanged(this.amount);
}

class ExpenseDescriptionChanged extends ExpenseFormEvent {
  final String description;
  ExpenseDescriptionChanged(this.description);
}

class SaveExpense extends ExpenseFormEvent {}
