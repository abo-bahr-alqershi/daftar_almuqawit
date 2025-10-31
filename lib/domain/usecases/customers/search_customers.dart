// ignore_for_file: public_member_api_docs

import '../../entities/customer.dart';
import '../../repositories/customer_repository.dart';
import '../base/base_usecase.dart';

class SearchCustomers implements UseCase<List<Customer>, String> {
  final CustomerRepository repo;
  SearchCustomers(this.repo);
  @override
  Future<List<Customer>> call(String query) => repo.searchByName(query);
}
