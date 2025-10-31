// ignore_for_file: public_member_api_docs

import 'package:sqflite/sqflite.dart';
import '../../database/tables/suppliers_table.dart';
import '../../models/supplier_model.dart';
import 'base_local_datasource.dart';

/// مصدر بيانات محلي للموردين (SQLite)
class SupplierLocalDataSource extends BaseLocalDataSource {
  SupplierLocalDataSource(super.dbHelper);

  Future<int> insert(SupplierModel model) async {
    final database = await db;
    return database.insert(
      SuppliersTable.table,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(SupplierModel model) async {
    final database = await db;
    await database.update(
      SuppliersTable.table,
      model.toMap(),
      where: '${SuppliersTable.cId} = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> delete(int id) async {
    final database = await db;
    await database.delete(
      SuppliersTable.table,
      where: '${SuppliersTable.cId} = ?',
      whereArgs: [id],
    );
  }

  Future<SupplierModel?> getById(int id) async {
    final database = await db;
    final rows = await database.query(
      SuppliersTable.table,
      where: '${SuppliersTable.cId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return SupplierModel.fromMap(rows.first);
  }

  Future<List<SupplierModel>> getAll() async {
    final database = await db;
    final rows = await database.query(SuppliersTable.table, orderBy: '${SuppliersTable.cName} COLLATE NOCASE');
    return rows.map((e) => SupplierModel.fromMap(e)).toList();
  }

  Future<List<SupplierModel>> searchByName(String query) async {
    final database = await db;
    final rows = await database.query(
      SuppliersTable.table,
      where: '${SuppliersTable.cName} LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: '${SuppliersTable.cName} COLLATE NOCASE',
    );
    return rows.map((e) => SupplierModel.fromMap(e)).toList();
  }
}
