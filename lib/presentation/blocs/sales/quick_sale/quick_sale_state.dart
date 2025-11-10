// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';

class SaleItem {
  final String name;
  final double quantity;
  final double price;
  final double total;

  SaleItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });
}

abstract class QuickSaleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class QuickSaleInitial extends QuickSaleState {}

class QuickSaleLoading extends QuickSaleState {}

class QuickSaleSuccess extends QuickSaleState {
  final String message;
  QuickSaleSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class QuickSaleInProgress extends QuickSaleState {
  final List<SaleItem> items;
  final double totalAmount;
  final String paymentMethod;
  final double paidAmount;
  final double remainingAmount;

  QuickSaleInProgress({
    required this.items,
    required this.totalAmount,
    this.paymentMethod = 'نقد',
    this.paidAmount = 0,
    this.remainingAmount = 0,
  });

  @override
  List<Object?> get props => [items, totalAmount, paymentMethod, paidAmount, remainingAmount];
}

class QuickSaleCompleted extends QuickSaleState {
  final String message;
  final int saleId;
  QuickSaleCompleted(this.message, this.saleId);

  @override
  List<Object?> get props => [message, saleId];
}

class QuickSaleError extends QuickSaleState {
  final String message;
  QuickSaleError(this.message);

  @override
  List<Object?> get props => [message];
}
