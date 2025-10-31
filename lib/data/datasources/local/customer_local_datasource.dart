// ignore_for_file: public_member_api_docs

import 'package:sqflite/sqflite.dart';
import '../../database/tables/customers_table.dart';
import '../../models/customer_model.dart';
import 'base_local_datasource.dart';

/// مصدر بيانات محلي للعملاء
class CustomerLocalDataSource extends BaseLocalDataSource {
  CustomerLocalDataSource(super.dbHelper);

  Future<int> insert(CustomerModel model) async {
    final database = await db;
    return database.insert(CustomersTable.table, model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(CustomerModel model) async {
    final database = await db;
    await database.update(
      CustomersTable.table,
      model.toMap(),
      where: '${CustomersTable.cId} = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> delete(int id) async {
    final database = await db;
    await database.delete(CustomersTable.table, where: '${CustomersTable.cId} = ?', whereArgs: [id]);
  }

  Future<CustomerModel?> getById(int id) async {
    final database = await db;
    final rows = await database.query(CustomersTable.table, where: '${CustomersTable.cId} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return CustomerModel.fromMap(rows.first);
  }

  Future<List<CustomerModel>> getAll() async {
    final database = await db;
    final rows = await database.query(CustomersTable.table, orderBy: '${CustomersTable.cName} COLLATE NOCASE');
    return rows.map((e) => CustomerModel.fromMap(e)).toList();
  }

  Future<List<CustomerModel>> searchByName(String query) async {
    final database = await db;
    final rows = await database.query(
      CustomersTable.table,
      where: '${CustomersTable.cName} LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: '${CustomersTable.cName} COLLATE NOCASE',
    );
    return rows.map((e) => CustomerModel.fromMap(e)).toList();
  }

  Future<List<CustomerModel>> getBlocked() async {
    final database = await db;
    final rows = await database.query(
      CustomersTable.table,
      where: '${CustomersTable.cIsBlocked} = 1',
      orderBy: '${CustomersTable.cName} COLLATE NOCASE',
    );
    return rows.map((e) => CustomerModel.fromMap(e)).toList();
  }
}
