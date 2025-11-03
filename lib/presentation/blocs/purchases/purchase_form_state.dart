/// حالات Bloc نموذج المشتريات
import 'package:equatable/equatable.dart';

abstract class PurchaseFormState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PurchaseFormInitial extends PurchaseFormState {}
class PurchaseFormLoading extends PurchaseFormState {}

class PurchaseFormReady extends PurchaseFormState {
  final String supplierId;
  final double amount;
  final bool isValid;
  
  PurchaseFormReady({
    this.supplierId = '',
    this.amount = 0.0,
    this.isValid = false,
  });
  
  @override
  List<Object?> get props => [supplierId, amount, isValid];
  
  PurchaseFormReady copyWith({String? supplierId, double? amount, bool? isValid}) {
    return PurchaseFormReady(
      supplierId: supplierId ?? this.supplierId,
      amount: amount ?? this.amount,
      isValid: isValid ?? this.isValid,
    );
  }
}

class PurchaseFormSuccess extends PurchaseFormState {
  final String message;
  PurchaseFormSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class PurchaseFormError extends PurchaseFormState {
  final String message;
  PurchaseFormError(this.message);
  @override
  List<Object?> get props => [message];
}
