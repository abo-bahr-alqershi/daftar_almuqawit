// ignore_for_file: public_member_api_docs

import '../../entities/sale.dart';
import '../../repositories/sales_repository.dart';
import '../base/base_usecase.dart';

class UpdateSale implements UseCase<void, Sale> {
  final SalesRepository repo;
  UpdateSale(this.repo);
  @override
  Future<void> call(Sale params) => repo.update(params);
}
