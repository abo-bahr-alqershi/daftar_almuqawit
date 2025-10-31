// ignore_for_file: public_member_api_docs

import '../../entities/purchase.dart';
import '../../repositories/purchase_repository.dart';
import '../base/base_usecase.dart';

class GetPurchases implements UseCase<List<Purchase>, NoParams> {
  final PurchaseRepository repo;
  GetPurchases(this.repo);
  @override
  Future<List<Purchase>> call(NoParams params) => repo.getAll();
}
