// ignore_for_file: public_member_api_docs

import '../entities/purchase.dart';
import 'base/base_repository.dart';

abstract class PurchaseRepository extends BaseRepository<Purchase> {
  Future<List<Purchase>> getBySupplier(int supplierId);
  Future<List<Purchase>> getByDate(String date);
  Future<List<Purchase>> getTodayPurchases(String date);
}
