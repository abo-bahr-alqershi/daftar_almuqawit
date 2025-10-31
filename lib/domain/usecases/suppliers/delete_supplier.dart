// ignore_for_file: public_member_api_docs

import '../../repositories/supplier_repository.dart';
import '../base/base_usecase.dart';

class DeleteSupplier implements UseCase<void, int> {
  final SupplierRepository repo;
  DeleteSupplier(this.repo);
  @override
  Future<void> call(int id) => repo.delete(id);
}
