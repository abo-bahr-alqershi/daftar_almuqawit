// ignore_for_file: public_member_api_docs

import 'package:sqflite/sqflite.dart';
import '../../database/tables/purchases_table.dart';
import '../../models/purchase_model.dart';
import 'base_local_datasource.dart';

class PurchaseLocalDataSource extends BaseLocalDataSource {
  PurchaseLocalDataSource(super.dbHelper);

  Future<int> insert(PurchaseModel model) async {
    final database = await db;
    return database.insert(PurchasesTable.table, model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(PurchaseModel model) async {
    final database = await db;
    await database.update(PurchasesTable.table, model.toMap(), where: '${PurchasesTable.cId} = ?', whereArgs: [model.id]);
  }

  Future<void> delete(int id) async {
    final database = await db;
    await database.delete(PurchasesTable.table, where: '${PurchasesTable.cId} = ?', whereArgs: [id]);
  }

  Future<PurchaseModel?> getById(int id) async {
    final database = await db;
    final rows = await database.query(PurchasesTable.table, where: '${PurchasesTable.cId} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return PurchaseModel.fromMap(rows.first);
  }

  Future<List<PurchaseModel>> getAll() async {
    final database = await db;
    final rows = await database.query(PurchasesTable.table, orderBy: '${PurchasesTable.cDate} DESC, ${PurchasesTable.cTime} DESC');
    return rows.map((e) => PurchaseModel.fromMap(e)).toList();
  }

  Future<List<PurchaseModel>> getToday(String date) async {
    final database = await db;
    final rows = await database.query(PurchasesTable.table, where: '${PurchasesTable.cDate} = ?', whereArgs: [date]);
    return rows.map((e) => PurchaseModel.fromMap(e)).toList();
  }

  Future<List<PurchaseModel>> getBySupplier(int supplierId) async {
    final database = await db;
    final rows = await database.query(PurchasesTable.table, where: '${PurchasesTable.cSupplierId} = ?', whereArgs: [supplierId]);
    return rows.map((e) => PurchaseModel.fromMap(e)).toList();
  }
}
