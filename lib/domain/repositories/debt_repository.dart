// ignore_for_file: public_member_api_docs

import '../entities/debt.dart';
import 'base/base_repository.dart';

abstract class DebtRepository extends BaseRepository<Debt> {
  Future<List<Debt>> getPending();
  Future<List<Debt>> getOverdue(String today);
  Future<List<Debt>> getByPerson(String personType, int personId);
}
