/// حالات Bloc نموذج العميل
/// تحتوي على جميع الحالات الممكنة لنموذج العميل

import 'package:equatable/equatable.dart';

/// الحالة الأساسية لنموذج العميل
abstract class CustomerFormState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class CustomerFormInitial extends CustomerFormState {}

/// حالة جاري التحميل
class CustomerFormLoading extends CustomerFormState {}

/// حالة النموذج جاهز للإدخال
class CustomerFormReady extends CustomerFormState {
  final String name;
  final String phone;
  final String address;
  final bool isValid;
  
  CustomerFormReady({
    this.name = '',
    this.phone = '',
    this.address = '',
    this.isValid = false,
  });
  
  @override
  List<Object?> get props => [name, phone, address, isValid];
  
  CustomerFormReady copyWith({
    String? name,
    String? phone,
    String? address,
    bool? isValid,
  }) {
    return CustomerFormReady(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isValid: isValid ?? this.isValid,
    );
  }
}

/// حالة حفظ ناجح
class CustomerFormSuccess extends CustomerFormState {
  final String message;
  CustomerFormSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// حالة حدوث خطأ
class CustomerFormError extends CustomerFormState {
  final String message;
  CustomerFormError(this.message);
  
  @override
  List<Object?> get props => [message];
}
