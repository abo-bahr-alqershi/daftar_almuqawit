/// حالات Bloc الدفعات
import 'package:equatable/equatable.dart';
import '../../../domain/entities/debt_payment.dart';

abstract class PaymentState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class PaymentInitial extends PaymentState {}

/// حالة التحميل أو المعالجة
class PaymentLoading extends PaymentState {}

/// حالة نجاح إضافة دفعة
class PaymentAdded extends PaymentState {
  final String message;
  PaymentAdded(this.message);
  @override
  List<Object?> get props => [message];
}

/// حالة نجاح تحديث دفعة
class PaymentUpdated extends PaymentState {
  final String message;
  PaymentUpdated(this.message);
  @override
  List<Object?> get props => [message];
}

/// حالة نجاح حذف دفعة
class PaymentDeleted extends PaymentState {
  final String message;
  PaymentDeleted(this.message);
  @override
  List<Object?> get props => [message];
}

/// حالة تحميل قائمة الدفعات
class PaymentsLoaded extends PaymentState {
  final List<DebtPayment> payments;
  PaymentsLoaded(this.payments);
  @override
  List<Object?> get props => [payments];
}

/// حالة الخطأ
class PaymentError extends PaymentState {
  final String message;
  PaymentError(this.message);
  @override
  List<Object?> get props => [message];
}
