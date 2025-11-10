/// أحداث Bloc الدفعات
import '../../../domain/entities/debt_payment.dart';
import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// حدث: إضافة دفعة جديدة
class AddPaymentEvent extends PaymentEvent {
  final DebtPayment payment;
  AddPaymentEvent(this.payment);
  @override
  List<Object?> get props => [payment];
}

/// حدث: تحديث دفعة موجودة
class UpdatePaymentEvent extends PaymentEvent {
  final DebtPayment payment;
  UpdatePaymentEvent(this.payment);
  @override
  List<Object?> get props => [payment];
}

/// حدث: حذف دفعة
class DeletePaymentEvent extends PaymentEvent {
  final int paymentId;
  DeletePaymentEvent(this.paymentId);
  @override
  List<Object?> get props => [paymentId];
}

/// حدث: تحميل سجل دفعات دين معين
class LoadPaymentsByDebtEvent extends PaymentEvent {
  final int debtId;
  LoadPaymentsByDebtEvent(this.debtId);
  @override
  List<Object?> get props => [debtId];
}

/// حدث: إعادة تعيين الحالة
class ResetPaymentStateEvent extends PaymentEvent {}
