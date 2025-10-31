// ignore_for_file: public_member_api_docs

import '../../entities/customer.dart';
import '../../repositories/customer_repository.dart';
import '../base/base_usecase.dart';

class UpdateCustomer implements UseCase<void, Customer> {
  final CustomerRepository repo;
  UpdateCustomer(this.repo);
  @override
  Future<void> call(Customer params) => repo.update(params);
}
