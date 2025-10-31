// ignore_for_file: public_member_api_docs

import '../../entities/qat_type.dart';
import '../../repositories/qat_type_repository.dart';
import '../base/base_usecase.dart';

class GetQatTypeById implements UseCase<QatType?, int> {
  final QatTypeRepository repo;
  GetQatTypeById(this.repo);
  @override
  Future<QatType?> call(int id) => repo.getById(id);
}
