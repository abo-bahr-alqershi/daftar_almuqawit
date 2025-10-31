// ignore_for_file: public_member_api_docs

import '../../entities/purchase.dart';
import '../../repositories/purchase_repository.dart';
import '../base/base_usecase.dart';

class GetTodayPurchases implements UseCase<List<Purchase>, String> {
  final PurchaseRepository repo;
  GetTodayPurchases(this.repo);
  @override
  Future<List<Purchase>> call(String date) => repo.getTodayPurchases(date);
}
