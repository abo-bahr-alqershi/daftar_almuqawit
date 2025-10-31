// ignore_for_file: public_member_api_docs

import 'package:sqflite/sqflite.dart';
import '../../database/tables/debts_table.dart';
import '../../models/debt_model.dart';
import 'base_local_datasource.dart';

class DebtLocalDataSource extends BaseLocalDataSource {
  DebtLocalDataSource(super.dbHelper);

  Future<int> insert(DebtModel model) async {
    final database = await db;
    return database.insert(DebtsTable.table, model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(DebtModel model) async {
    final database = await db;
    await database.update(DebtsTable.table, model.toMap(), where: '${DebtsTable.cId} = ?', whereArgs: [model.id]);
  }

  Future<void> delete(int id) async {
    final database = await db;
    await database.delete(DebtsTable.table, where: '${DebtsTable.cId} = ?', whereArgs: [id]);
  }

  Future<DebtModel?> getById(int id) async {
    final database = await db;
    final rows = await database.query(DebtsTable.table, where: '${DebtsTable.cId} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return DebtModel.fromMap(rows.first);
  }

  Future<List<DebtModel>> getAll() async {
    final database = await db;
    final rows = await database.query(DebtsTable.table, orderBy: '${DebtsTable.cDate} DESC');
    return rows.map((e) => DebtModel.fromMap(e)).toList();
  }

  Future<List<DebtModel>> getPending() async {
    final database = await db;
    final rows = await database.query(
      DebtsTable.table,
      where: "${DebtsTable.cStatus} != ?",
      whereArgs: ['مسدد'],
      orderBy: '${DebtsTable.cDate} DESC',
    );
    return rows.map((e) => DebtModel.fromMap(e)).toList();
  }

  Future<List<DebtModel>> getOverdue(String today) async {
    final database = await db;
    final rows = await database.query(
      DebtsTable.table,
      where: "${DebtsTable.cDueDate} IS NOT NULL AND ${DebtsTable.cDueDate} < ? AND ${DebtsTable.cStatus} != ?",
      whereArgs: [today, 'مسدد'],
      orderBy: '${DebtsTable.cDueDate} ASC',
    );
    return rows.map((e) => DebtModel.fromMap(e)).toList();
  }

  Future<List<DebtModel>> getByPerson(String personType, int personId) async {
    final database = await db;
    final rows = await database.query(
      DebtsTable.table,
      where: '${DebtsTable.cPersonType} = ? AND ${DebtsTable.cPersonId} = ?',
      whereArgs: [personType, personId],
      orderBy: '${DebtsTable.cDate} DESC',
    );
    return rows.map((e) => DebtModel.fromMap(e)).toList();
  }
}
