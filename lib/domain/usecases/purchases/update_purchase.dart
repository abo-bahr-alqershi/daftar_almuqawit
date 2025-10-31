// ignore_for_file: public_member_api_docs

import '../../entities/purchase.dart';
import '../../repositories/purchase_repository.dart';
import '../base/base_usecase.dart';

class UpdatePurchase implements UseCase<void, Purchase> {
  final PurchaseRepository repo;
  UpdatePurchase(this.repo);
  @override
  Future<void> call(Purchase params) => repo.update(params);
}
