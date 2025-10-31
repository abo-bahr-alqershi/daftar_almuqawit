// ignore_for_file: public_member_api_docs

import '../../entities/supplier.dart';
import '../../repositories/supplier_repository.dart';
import '../base/base_usecase.dart';

class AddSupplier implements UseCase<int, Supplier> {
  final SupplierRepository repo;
  AddSupplier(this.repo);
  @override
  Future<int> call(Supplier params) => repo.add(params);
}
