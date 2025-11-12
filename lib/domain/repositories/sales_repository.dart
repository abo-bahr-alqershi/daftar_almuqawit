// ignore_for_file: public_member_api_docs

import '../entities/sale.dart';
import 'base/base_repository.dart';

abstract class SalesRepository extends BaseRepository<Sale> {
  Future<List<Sale>> getByCustomer(int customerId);
  Future<List<Sale>> getByDate(String date);
  Future<List<Sale>> getTodaySales(String date);
  Future<List<Sale>> getByQatType(int qatTypeId);
  Future<int> add(Sale sale);
  Future<void> update(Sale sale);
  Future<void> delete(int id);
}
