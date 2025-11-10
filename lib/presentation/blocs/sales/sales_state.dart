// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import '../../../domain/entities/sale.dart';

abstract class SalesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesLoaded extends SalesState {
  final List<Sale> sales;
  SalesLoaded(this.sales);
  
  @override
  List<Object?> get props => [sales];
}

class SalesError extends SalesState {
  final String message;
  SalesError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class SaleOperationSuccess extends SalesState {
  final String message;
  SaleOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// حالة نجاح إضافة مبيعة
class SalesSuccess extends SalesState {
  final String message;
  SalesSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
