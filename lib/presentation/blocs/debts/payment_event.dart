/// أحداث Bloc الدفعات
abstract class PaymentEvent {}

class ProcessPayment extends PaymentEvent {
  final String debtId;
  final double amount;
  ProcessPayment(this.debtId, this.amount);
}

class LoadPaymentHistory extends PaymentEvent {
  final String debtId;
  LoadPaymentHistory(this.debtId);
}
