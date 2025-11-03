/// حالات Bloc الدفعات
import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}
class PaymentProcessing extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final String message;
  PaymentSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class PaymentHistoryLoaded extends PaymentState {
  final List<Map<String, dynamic>> payments;
  PaymentHistoryLoaded(this.payments);
  @override
  List<Object?> get props => [payments];
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError(this.message);
  @override
  List<Object?> get props => [message];
}
