// ignore_for_file: public_member_api_docs

import '../../entities/customer.dart';
import '../../repositories/customer_repository.dart';
import '../base/base_usecase.dart';

class GetCustomers implements UseCase<List<Customer>, NoParams> {
  final CustomerRepository repo;
  GetCustomers(this.repo);
  @override
  Future<List<Customer>> call(NoParams params) => repo.getAll();
}
