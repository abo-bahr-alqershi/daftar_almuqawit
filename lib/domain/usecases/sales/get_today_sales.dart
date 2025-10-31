// ignore_for_file: public_member_api_docs

import '../../entities/sale.dart';
import '../../repositories/sales_repository.dart';
import '../base/base_usecase.dart';

class GetTodaySales implements UseCase<List<Sale>, String> {
  final SalesRepository repo;
  GetTodaySales(this.repo);
  @override
  Future<List<Sale>> call(String date) => repo.getTodaySales(date);
}
