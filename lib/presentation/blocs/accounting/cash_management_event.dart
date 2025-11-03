/// أحداث Bloc إدارة الصندوق
abstract class CashManagementEvent {}

class LoadCashBalance extends CashManagementEvent {}

class AddCashTransaction extends CashManagementEvent {
  final String type;
  final double amount;
  final String description;
  AddCashTransaction(this.type, this.amount, this.description);
}

class LoadCashTransactions extends CashManagementEvent {}
