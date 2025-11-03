/// أحداث Bloc المحاسبة
/// تحتوي على جميع الأحداث المتعلقة بإدارة المحاسبة

/// الحدث الأساسي للمحاسبة
abstract class AccountingEvent {}

/// حدث تحميل الحسابات
class LoadAccounts extends AccountingEvent {}

/// حدث تحميل المعاملات
class LoadTransactions extends AccountingEvent {
  final String? accountId;
  final String? startDate;
  final String? endDate;
  LoadTransactions({this.accountId, this.startDate, this.endDate});
}

/// حدث إضافة معاملة
class AddTransaction extends AccountingEvent {
  final String type;
  final double amount;
  final String description;
  AddTransaction(this.type, this.amount, this.description);
}

/// حدث حساب الرصيد
class CalculateBalance extends AccountingEvent {}
