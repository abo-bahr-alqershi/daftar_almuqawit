// ignore_for_file: public_member_api_docs

import '../../../domain/entities/sale.dart';

abstract class SalesEvent {}

class LoadSales extends SalesEvent {}

class LoadTodaySales extends SalesEvent {
  final String date;
  LoadTodaySales(this.date);
}

class LoadSalesByCustomer extends SalesEvent {
  final int customerId;
  LoadSalesByCustomer(this.customerId);
}

class AddSaleEvent extends SalesEvent {
  final Sale sale;
  AddSaleEvent(this.sale);
}

class UpdateSaleEvent extends SalesEvent {
  final Sale sale;
  UpdateSaleEvent(this.sale);
}

class DeleteSaleEvent extends SalesEvent {
  final int id;
  DeleteSaleEvent(this.id);
}

class CancelSaleEvent extends SalesEvent {
  final int id;
  CancelSaleEvent(this.id);
}
