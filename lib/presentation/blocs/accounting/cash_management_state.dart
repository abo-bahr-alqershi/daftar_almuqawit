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
  final double totalIncome;
  final double totalExpenses;
  
  CashBalanceLoaded({
    required this.balance,
    this.totalIncome = 0.0,
    this.totalExpenses = 0.0,
  });
  
  @override
  List<Object?> get props => [balance, totalIncome, totalExpenses];
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
