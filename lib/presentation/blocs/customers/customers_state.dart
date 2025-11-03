// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import '../../../domain/entities/customer.dart';

abstract class CustomersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CustomersInitial extends CustomersState {}

class CustomersLoading extends CustomersState {}

class CustomersLoaded extends CustomersState {
  final List<Customer> customers;
  CustomersLoaded(this.customers);
  
  @override
  List<Object?> get props => [customers];
}

class CustomersError extends CustomersState {
  final String message;
  CustomersError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class CustomerOperationSuccess extends CustomersState {
  final String message;
  CustomerOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
