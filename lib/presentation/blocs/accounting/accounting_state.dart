/// حالات Bloc المحاسبة
/// تحتوي على جميع الحالات الممكنة لإدارة المحاسبة

import 'package:equatable/equatable.dart';

/// الحالة الأساسية للمحاسبة
abstract class AccountingState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class AccountingInitial extends AccountingState {}

/// حالة التحميل
class AccountingLoading extends AccountingState {}

/// حالة تحميل البيانات بنجاح
class AccountingLoaded extends AccountingState {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final List<Map<String, dynamic>> transactions;
  
  AccountingLoaded({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.transactions,
  });
  
  @override
  List<Object?> get props => [totalIncome, totalExpenses, balance, transactions];
}

/// حالة حدوث خطأ
class AccountingError extends AccountingState {
  final String message;
  AccountingError(this.message);
  
  @override
  List<Object?> get props => [message];
}
