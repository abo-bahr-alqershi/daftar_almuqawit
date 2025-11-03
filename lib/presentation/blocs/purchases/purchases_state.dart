/// حالات Bloc المشتريات
/// تحتوي على جميع الحالات الممكنة لإدارة المشتريات

import 'package:equatable/equatable.dart';
import '../../../domain/entities/purchase.dart';

/// الحالة الأساسية للمشتريات
abstract class PurchasesState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class PurchasesInitial extends PurchasesState {}

/// حالة التحميل
class PurchasesLoading extends PurchasesState {}

/// حالة تحميل المشتريات بنجاح
class PurchasesLoaded extends PurchasesState {
  final List<Purchase> purchases;
  PurchasesLoaded(this.purchases);
  
  @override
  List<Object?> get props => [purchases];
}

/// حالة حدوث خطأ
class PurchasesError extends PurchasesState {
  final String message;
  PurchasesError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// حالة نجاح العملية
class PurchaseOperationSuccess extends PurchasesState {
  final String message;
  PurchaseOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
