// ignore_for_file: public_member_api_docs

import '../../repositories/purchase_repository.dart';
import '../base/base_usecase.dart';

class DeletePurchase implements UseCase<void, int> {
  final PurchaseRepository repo;
  DeletePurchase(this.repo);
  @override
  Future<void> call(int id) => repo.delete(id);
}
