// ignore_for_file: public_member_api_docs

import '../entities/supplier.dart';
import 'base/base_repository.dart';

abstract class SupplierRepository extends BaseRepository<Supplier> {
  Future<List<Supplier>> searchByName(String query);
}
