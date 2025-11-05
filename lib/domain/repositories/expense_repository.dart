// ignore_for_file: public_member_api_docs

import '../entities/expense.dart';
import 'base/base_repository.dart';

abstract class ExpenseRepository extends BaseRepository<Expense> {
  Future<List<Expense>> getByCategory(String category);
  Future<List<Expense>> getByDate(String date);
  Future<List<Expense>> getDaily(String date);
}
