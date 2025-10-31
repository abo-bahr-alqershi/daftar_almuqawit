// ignore_for_file: public_member_api_docs

import '../../entities/expense.dart';
import '../../repositories/expense_repository.dart';
import '../base/base_usecase.dart';

class GetDailyExpenses implements UseCase<List<Expense>, String> {
  final ExpenseRepository repo;
  GetDailyExpenses(this.repo);
  @override
  Future<List<Expense>> call(String date) => repo.getDaily(date);
}
