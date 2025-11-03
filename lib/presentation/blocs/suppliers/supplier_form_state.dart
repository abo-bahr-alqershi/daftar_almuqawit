/// حالات Bloc نموذج المورد
/// تحتوي على جميع الحالات الممكنة لنموذج المورد

import 'package:equatable/equatable.dart';

/// الحالة الأساسية لنموذج المورد
abstract class SupplierFormState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class SupplierFormInitial extends SupplierFormState {}

/// حالة جاري التحميل
class SupplierFormLoading extends SupplierFormState {}

/// حالة النموذج جاهز للإدخال
class SupplierFormReady extends SupplierFormState {
  final String name;
  final String phone;
  final String address;
  final bool isValid;
  
  SupplierFormReady({
    this.name = '',
    this.phone = '',
    this.address = '',
    this.isValid = false,
  });
  
  @override
  List<Object?> get props => [name, phone, address, isValid];
  
  SupplierFormReady copyWith({
    String? name,
    String? phone,
    String? address,
    bool? isValid,
  }) {
    return SupplierFormReady(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isValid: isValid ?? this.isValid,
    );
  }
}

/// حالة حفظ ناجح
class SupplierFormSuccess extends SupplierFormState {
  final String message;
  SupplierFormSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// حالة حدوث خطأ
class SupplierFormError extends SupplierFormState {
  final String message;
  SupplierFormError(this.message);
  
  @override
  List<Object?> get props => [message];
}
