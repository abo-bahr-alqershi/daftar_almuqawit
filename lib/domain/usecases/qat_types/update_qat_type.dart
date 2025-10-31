// ignore_for_file: public_member_api_docs

import '../../entities/qat_type.dart';
import '../../repositories/qat_type_repository.dart';
import '../base/base_usecase.dart';

class UpdateQatType implements UseCase<void, QatType> {
  final QatTypeRepository repo;
  UpdateQatType(this.repo);
  @override
  Future<void> call(QatType params) => repo.update(params);
}
