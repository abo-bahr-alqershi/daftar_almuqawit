// ignore_for_file: public_member_api_docs

import '../entities/customer.dart';
import 'base/base_repository.dart';

abstract class CustomerRepository extends BaseRepository<Customer> {
  Future<List<Customer>> searchByName(String query);
  Future<List<Customer>> getBlocked();
  Future<void> updateDebt(int id, double amount);
}
