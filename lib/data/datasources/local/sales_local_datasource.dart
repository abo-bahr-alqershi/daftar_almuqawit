// ignore_for_file: public_member_api_docs

import 'package:sqflite/sqflite.dart';
import '../../database/tables/sales_table.dart';
import '../../models/sale_model.dart';
import 'base_local_datasource.dart';

class SalesLocalDataSource extends BaseLocalDataSource {
  SalesLocalDataSource(super.dbHelper);

  Future<int> insert(SaleModel model) async {
    final database = await db;
    return database.insert(SalesTable.table, model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(SaleModel model) async {
    final database = await db;
    await database.update(
      SalesTable.table,
      model.toMap(),
      where: '${SalesTable.cId} = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> delete(int id) async {
    final database = await db;
    await database.delete(SalesTable.table, where: '${SalesTable.cId} = ?', whereArgs: [id]);
  }

  Future<SaleModel?> getById(int id) async {
    final database = await db;
    final rows = await database.query(SalesTable.table, where: '${SalesTable.cId} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return SaleModel.fromMap(rows.first);
  }

  Future<List<SaleModel>> getAll() async {
    final database = await db;
    final rows = await database.query(SalesTable.table, orderBy: '${SalesTable.cDate} DESC, ${SalesTable.cTime} DESC');
    return rows.map((e) => SaleModel.fromMap(e)).toList();
  }

  Future<List<SaleModel>> getToday(String date) async {
    final database = await db;
    final rows = await database.query(SalesTable.table, where: '${SalesTable.cDate} = ?', whereArgs: [date]);
    return rows.map((e) => SaleModel.fromMap(e)).toList();
  }

  Future<List<SaleModel>> getByCustomer(int customerId) async {
    final database = await db;
    final rows = await database.query(
      SalesTable.table,
      where: '${SalesTable.cCustomerId} = ?',
      whereArgs: [customerId],
      orderBy: '${SalesTable.cDate} DESC, ${SalesTable.cTime} DESC',
    );
    return rows.map((e) => SaleModel.fromMap(e)).toList();
  }
}
