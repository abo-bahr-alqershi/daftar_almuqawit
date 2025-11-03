// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import '../../../domain/entities/supplier.dart';

abstract class SuppliersState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class SuppliersInitial extends SuppliersState {}

/// جاري التحميل
class SuppliersLoading extends SuppliersState {}

/// تم التحميل بنجاح
class SuppliersLoaded extends SuppliersState {
  final List<Supplier> suppliers;
  SuppliersLoaded(this.suppliers);
  
  @override
  List<Object?> get props => [suppliers];
}

/// حدث خطأ
class SuppliersError extends SuppliersState {
  final String message;
  SuppliersError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// تمت العملية بنجاح
class SupplierOperationSuccess extends SuppliersState {
  final String message;
  SupplierOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
