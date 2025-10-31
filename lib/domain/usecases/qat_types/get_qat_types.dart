// ignore_for_file: public_member_api_docs

import '../../entities/qat_type.dart';
import '../../repositories/qat_type_repository.dart';
import '../base/base_usecase.dart';

class GetQatTypes implements UseCase<List<QatType>, NoParams> {
  final QatTypeRepository repo;
  GetQatTypes(this.repo);
  @override
  Future<List<QatType>> call(NoParams params) => repo.getAll();
}
