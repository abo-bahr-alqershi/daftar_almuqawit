/// حالات Bloc إدارة الصندوق
import 'package:equatable/equatable.dart';

abstract class CashManagementState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CashManagementInitial extends CashManagementState {}
class CashManagementLoading extends CashManagementState {}

class CashBalanceLoaded extends CashManagementState {
  final double balance;
  CashBalanceLoaded(this.balance);
  @override
  List<Object?> get props => [balance];
}

class CashTransactionsLoaded extends CashManagementState {
  final List<Map<String, dynamic>> transactions;
  CashTransactionsLoaded(this.transactions);
  @override
  List<Object?> get props => [transactions];
}

class CashTransactionSuccess extends CashManagementState {
  final String message;
  CashTransactionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class CashManagementError extends CashManagementState {
  final String message;
  CashManagementError(this.message);
  @override
  List<Object?> get props => [message];
}
