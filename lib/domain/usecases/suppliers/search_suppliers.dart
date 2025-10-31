// ignore_for_file: public_member_api_docs

import '../../entities/supplier.dart';
import '../../repositories/supplier_repository.dart';
import '../base/base_usecase.dart';

class SearchSuppliers implements UseCase<List<Supplier>, String> {
  final SupplierRepository repo;
  SearchSuppliers(this.repo);
  @override
  Future<List<Supplier>> call(String query) => repo.searchByName(query);
}
