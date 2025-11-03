/// حالات Bloc نموذج المبيعات
/// تحتوي على جميع الحالات الممكنة لنموذج المبيعات

import 'package:equatable/equatable.dart';

/// الحالة الأساسية لنموذج المبيعات
abstract class SaleFormState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class SaleFormInitial extends SaleFormState {}

/// حالة جاري التحميل
class SaleFormLoading extends SaleFormState {}

/// حالة النموذج جاهز للإدخال
class SaleFormReady extends SaleFormState {
  final String customerId;
  final double amount;
  final List<Map<String, dynamic>> products;
  final bool isValid;
  
  SaleFormReady({
    this.customerId = '',
    this.amount = 0.0,
    this.products = const [],
    this.isValid = false,
  });
  
  @override
  List<Object?> get props => [customerId, amount, products, isValid];
  
  SaleFormReady copyWith({
    String? customerId,
    double? amount,
    List<Map<String, dynamic>>? products,
    bool? isValid,
  }) {
    return SaleFormReady(
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      products: products ?? this.products,
      isValid: isValid ?? this.isValid,
    );
  }
}

/// حالة حفظ ناجح
class SaleFormSuccess extends SaleFormState {
  final String message;
  SaleFormSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// حالة حدوث خطأ
class SaleFormError extends SaleFormState {
  final String message;
  SaleFormError(this.message);
  
  @override
  List<Object?> get props => [message];
}
