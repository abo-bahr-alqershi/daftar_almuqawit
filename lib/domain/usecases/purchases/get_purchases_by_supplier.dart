// ignore_for_file: public_member_api_docs

import '../../entities/purchase.dart';
import '../../repositories/purchase_repository.dart';
import '../base/base_usecase.dart';

class GetPurchasesBySupplier implements UseCase<List<Purchase>, int> {
  final PurchaseRepository repo;
  GetPurchasesBySupplier(this.repo);
  @override
  Future<List<Purchase>> call(int supplierId) => repo.getBySupplier(supplierId);
}
