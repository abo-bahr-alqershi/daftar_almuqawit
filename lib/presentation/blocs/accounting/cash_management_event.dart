/// أحداث Bloc إدارة الصندوق
import 'package:equatable/equatable.dart';

abstract class CashManagementEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCashBalance extends CashManagementEvent {}

class AddCashTransaction extends CashManagementEvent {
  final String type;
  final double amount;
  final String description;
  
  AddCashTransaction(this.type, this.amount, this.description);
  
  @override
  List<Object?> get props => [type, amount, description];
}

class LoadCashTransactions extends CashManagementEvent {
  final String? startDate;
  final String? endDate;
  
  LoadCashTransactions({this.startDate, this.endDate});
  
  @override
  List<Object?> get props => [startDate, endDate];
}
