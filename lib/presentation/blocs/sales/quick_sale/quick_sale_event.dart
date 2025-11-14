// ignore_for_file: public_member_api_docs

import '../../../../domain/entities/qat_type.dart';

abstract class QuickSaleEvent {}

class InitializeQuickSale extends QuickSaleEvent {}

class AddItemToSale extends QuickSaleEvent {
  final QatType qatType;
  final double quantity;
  final double price;
  AddItemToSale(this.qatType, this.quantity, this.price);
}

class RemoveItemFromSale extends QuickSaleEvent {
  final int index;
  RemoveItemFromSale(this.index);
}

class UpdateQuantity extends QuickSaleEvent {
  final int index;
  final double quantity;
  UpdateQuantity(this.index, this.quantity);
}

class SelectPaymentMethod extends QuickSaleEvent {
  final String method;
  SelectPaymentMethod(this.method);
}

class SetPaidAmount extends QuickSaleEvent {
  final double amount;
  SetPaidAmount(this.amount);
}

class CompleteSale extends QuickSaleEvent {
  final int? customerId;
  CompleteSale({this.customerId});
}

class SubmitQuickSale extends QuickSaleEvent {
  final int qatTypeId;
  final String unit;
  final double quantity;
  final double price;
  final int? customerId;
  final String? notes;
  
  SubmitQuickSale({
    required this.qatTypeId,
    required this.unit,
    required this.quantity,
    required this.price,
    this.customerId,
    this.notes,
  });
}

class CancelSale extends QuickSaleEvent {}
