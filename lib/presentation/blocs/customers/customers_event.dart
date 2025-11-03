// ignore_for_file: public_member_api_docs

import '../../../domain/entities/customer.dart';

abstract class CustomersEvent {}

class LoadCustomers extends CustomersEvent {}

class AddCustomerEvent extends CustomersEvent {
  final Customer customer;
  AddCustomerEvent(this.customer);
}

class UpdateCustomerEvent extends CustomersEvent {
  final Customer customer;
  UpdateCustomerEvent(this.customer);
}

class DeleteCustomerEvent extends CustomersEvent {
  final int id;
  DeleteCustomerEvent(this.id);
}

class BlockCustomerEvent extends CustomersEvent {
  final int id;
  final bool block;
  BlockCustomerEvent(this.id, this.block);
}

class SearchCustomersEvent extends CustomersEvent {
  final String query;
  SearchCustomersEvent(this.query);
}
