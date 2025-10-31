// ignore_for_file: public_member_api_docs

import '../../repositories/sales_repository.dart';
import '../base/base_usecase.dart';

class DeleteSale implements UseCase<void, int> {
  final SalesRepository repo;
  DeleteSale(this.repo);
  @override
  Future<void> call(int id) => repo.delete(id);
}
