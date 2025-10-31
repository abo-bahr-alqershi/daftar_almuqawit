// ignore_for_file: public_member_api_docs

import '../../repositories/qat_type_repository.dart';
import '../base/base_usecase.dart';

class DeleteQatType implements UseCase<void, int> {
  final QatTypeRepository repo;
  DeleteQatType(this.repo);
  @override
  Future<void> call(int id) => repo.delete(id);
}
