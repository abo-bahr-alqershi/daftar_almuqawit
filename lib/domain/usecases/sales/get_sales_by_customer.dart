// ignore_for_file: public_member_api_docs

import '../../entities/sale.dart';
import '../../repositories/sales_repository.dart';
import '../base/base_usecase.dart';

class GetSalesByCustomer implements UseCase<List<Sale>, int> {
  final SalesRepository repo;
  GetSalesByCustomer(this.repo);
  @override
  Future<List<Sale>> call(int customerId) => repo.getByCustomer(customerId);
}
