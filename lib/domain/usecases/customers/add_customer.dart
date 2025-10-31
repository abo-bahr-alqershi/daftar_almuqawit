// ignore_for_file: public_member_api_docs

import '../../entities/customer.dart';
import '../../repositories/customer_repository.dart';
import '../base/base_usecase.dart';

class AddCustomer implements UseCase<int, Customer> {
  final CustomerRepository repo;
  AddCustomer(this.repo);
  @override
  Future<int> call(Customer params) => repo.add(params);
}
