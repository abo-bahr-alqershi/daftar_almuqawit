/// حالات Bloc نموذج المصروفات
import 'package:equatable/equatable.dart';

abstract class ExpenseFormState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExpenseFormInitial extends ExpenseFormState {}
class ExpenseFormLoading extends ExpenseFormState {}

class ExpenseFormReady extends ExpenseFormState {
  final double amount;
  final String description;
  final bool isValid;
  
  ExpenseFormReady({this.amount = 0.0, this.description = '', this.isValid = false});
  
  @override
  List<Object?> get props => [amount, description, isValid];
  
  ExpenseFormReady copyWith({double? amount, String? description, bool? isValid}) {
    return ExpenseFormReady(
      amount: amount ?? this.amount,
      description: description ?? this.description,
      isValid: isValid ?? this.isValid,
    );
  }
}

class ExpenseFormSuccess extends ExpenseFormState {
  final String message;
  ExpenseFormSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ExpenseFormError extends ExpenseFormState {
  final String message;
  ExpenseFormError(this.message);
  @override
  List<Object?> get props => [message];
}
