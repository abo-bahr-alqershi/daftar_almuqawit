// ignore_for_file: public_member_api_docs

import '../../entities/sale.dart';
import '../../repositories/sales_repository.dart';
import '../base/base_usecase.dart';

class GetCustomerHistory implements UseCase<List<Sale>, int> {
  final SalesRepository sales;
  GetCustomerHistory(this.sales);
  @override
  Future<List<Sale>> call(int customerId) => sales.getByCustomer(customerId);
}
