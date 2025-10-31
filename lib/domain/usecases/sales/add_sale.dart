// ignore_for_file: public_member_api_docs

import '../../entities/sale.dart';
import '../../repositories/sales_repository.dart';
import '../base/base_usecase.dart';

class AddSale implements UseCase<int, Sale> {
  final SalesRepository repo;
  AddSale(this.repo);
  @override
  Future<int> call(Sale params) => repo.add(params);
}
