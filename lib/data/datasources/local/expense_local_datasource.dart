// ignore_for_file: public_member_api_docs

import 'package:sqflite/sqflite.dart';
import '../../database/tables/expenses_table.dart';
import '../../models/expense_model.dart';
import 'base_local_datasource.dart';

class ExpenseLocalDataSource extends BaseLocalDataSource {
  ExpenseLocalDataSource(super.dbHelper);

  Future<int> insert(ExpenseModel model) async {
    final database = await db;
    return database.insert(ExpensesTable.table, model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(ExpenseModel model) async {
    final database = await db;
    await database.update(ExpensesTable.table, model.toMap(), where: '${ExpensesTable.cId} = ?', whereArgs: [model.id]);
  }

  Future<void> delete(int id) async {
    final database = await db;
    await database.delete(ExpensesTable.table, where: '${ExpensesTable.cId} = ?', whereArgs: [id]);
  }

  Future<List<ExpenseModel>> getDaily(String date) async {
    final database = await db;
    final rows = await database.query(ExpensesTable.table, where: '${ExpensesTable.cDate} = ?', whereArgs: [date]);
    return rows.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  Future<List<ExpenseModel>> getByCategory(String category) async {
    final database = await db;
    final rows = await database.query(ExpensesTable.table, where: '${ExpensesTable.cCategory} = ?', whereArgs: [category]);
    return rows.map((e) => ExpenseModel.fromMap(e)).toList();
  }
}
