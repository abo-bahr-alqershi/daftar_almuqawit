// ignore_for_file: public_member_api_docs

import '../../entities/qat_type.dart';
import '../../repositories/qat_type_repository.dart';
import '../base/base_usecase.dart';

class AddQatType implements UseCase<int, QatType> {
  final QatTypeRepository repo;
  AddQatType(this.repo);
  @override
  Future<int> call(QatType params) => repo.add(params);
}
