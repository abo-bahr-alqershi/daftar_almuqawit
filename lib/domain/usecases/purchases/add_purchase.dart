// ignore_for_file: public_member_api_docs

import '../../entities/purchase.dart';
import '../../repositories/purchase_repository.dart';
import '../base/base_usecase.dart';

class AddPurchase implements UseCase<int, Purchase> {
  final PurchaseRepository repo;
  AddPurchase(this.repo);
  @override
  Future<int> call(Purchase params) => repo.add(params);
}
