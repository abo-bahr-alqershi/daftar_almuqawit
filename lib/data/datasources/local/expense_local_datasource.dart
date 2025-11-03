// ignore_for_file: public_member_api_docs

import '../../database/tables/expenses_table.dart';
import '../../models/expense_model.dart';
import 'base_local_datasource.dart';

class ExpenseLocalDataSource extends BaseLocalDataSource<ExpenseModel> {
  ExpenseLocalDataSource(super.dbHelper);

  @override
  String get tableName => ExpensesTable.table;

  @override
  ExpenseModel fromMap(Map<String, dynamic> map) => ExpenseModel.fromMap(map);

  /// جلب المصروفات اليومية
  Future<List<ExpenseModel>> getDaily(String date) async {
    return await getWhere(
      where: '${ExpensesTable.cDate} = ?',
      whereArgs: [date],
      orderBy: '${ExpensesTable.cDate} DESC',
    );
  }

  /// جلب المصروفات حسب الفئة
  Future<List<ExpenseModel>> getByCategory(String category) async {
    return await getWhere(
      where: '${ExpensesTable.cCategory} = ?',
      whereArgs: [category],
      orderBy: '${ExpensesTable.cDate} DESC',
    );
  }
}
