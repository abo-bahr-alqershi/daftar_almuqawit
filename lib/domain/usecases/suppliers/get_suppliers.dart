// ignore_for_file: public_member_api_docs

import '../../entities/supplier.dart';
import '../../repositories/supplier_repository.dart';
import '../base/base_usecase.dart';

class GetSuppliers implements UseCase<List<Supplier>, NoParams> {
  final SupplierRepository repo;
  GetSuppliers(this.repo);
  @override
  Future<List<Supplier>> call(NoParams params) => repo.getAll();
}
