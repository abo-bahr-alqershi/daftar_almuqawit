// ignore_for_file: public_member_api_docs

import '../../entities/supplier.dart';
import '../../repositories/supplier_repository.dart';
import '../base/base_usecase.dart';

class UpdateSupplier implements UseCase<void, Supplier> {
  final SupplierRepository repo;
  UpdateSupplier(this.repo);
  @override
  Future<void> call(Supplier params) => repo.update(params);
}
