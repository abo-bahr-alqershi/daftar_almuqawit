// ignore_for_file: public_member_api_docs

import '../../repositories/customer_repository.dart';
import '../base/base_usecase.dart';

class DeleteCustomer implements UseCase<void, int> {
  final CustomerRepository repo;
  DeleteCustomer(this.repo);
  @override
  Future<void> call(int id) => repo.delete(id);
}
