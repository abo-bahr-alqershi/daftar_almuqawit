// ignore_for_file: public_member_api_docs

import '../../entities/debt.dart';
import '../../repositories/debt_repository.dart';
import '../base/base_usecase.dart';

class GetDebtsByPerson implements UseCase<List<Debt>, ({String personType, int personId})> {
  final DebtRepository repo;
  GetDebtsByPerson(this.repo);
  @override
  Future<List<Debt>> call(({String personType, int personId}) params) =>
      repo.getByPerson(params.personType, params.personId);
}
