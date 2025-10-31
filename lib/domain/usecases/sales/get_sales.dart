// ignore_for_file: public_member_api_docs

import '../../entities/sale.dart';
import '../../repositories/sales_repository.dart';
import '../base/base_usecase.dart';

class GetSales implements UseCase<List<Sale>, NoParams> {
  final SalesRepository repo;
  GetSales(this.repo);
  @override
  Future<List<Sale>> call(NoParams params) => repo.getAll();
}
