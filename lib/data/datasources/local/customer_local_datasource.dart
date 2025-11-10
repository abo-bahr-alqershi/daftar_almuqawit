// ignore_for_file: public_member_api_docs

import '../../database/tables/customers_table.dart';
import '../../database/queries/base_queries.dart';
import '../../models/customer_model.dart';
import 'base_local_datasource.dart';

class CustomerLocalDataSource extends BaseLocalDataSource<CustomerModel> {
  CustomerLocalDataSource(super.dbHelper);

  @override
  String get tableName => CustomersTable.table;

  @override
  CustomerModel fromMap(Map<String, dynamic> map) => CustomerModel.fromMap(map);

  Future<List<CustomerModel>> searchByName(String query) async {
    final sql = BaseQueries.search(
      tableName,
      [CustomersTable.cName, CustomersTable.cPhone, CustomersTable.cAddress],
      query,
    );
    final results = await rawQuery(sql, ['%$query%', '%$query%', '%$query%']);
    return results.map((map) => fromMap(map)).toList();
  }

  Future<List<CustomerModel>> getBlocked() async {
    return await getWhere(
      where: '${CustomersTable.cIsBlocked} = 1',
      whereArgs: [],
      orderBy: '${CustomersTable.cName} COLLATE NOCASE',
    );
  }

  Future<List<CustomerModel>> getActive() async {
    final sql = BaseQueries.activeOnly(tableName);
    final results = await rawQuery(sql);
    return results.map((map) => fromMap(map)).toList();
  }

  Future<List<CustomerModel>> getCustomersWithDebts() async {
    return await getWhere(
      where: '${CustomersTable.cCurrentDebt} > ?',
      whereArgs: [0],
      orderBy: '${CustomersTable.cCurrentDebt} DESC',
    );
  }

  Future<List<CustomerModel>> getByType(String type) async {
    return await getWhere(
      where: '${CustomersTable.cCustomerType} = ?',
      whereArgs: [type],
      orderBy: '${CustomersTable.cName} COLLATE NOCASE',
    );
  }

  Future<int> blockCustomer(int id) async {
    final database = await db;
    return await database.update(
      CustomersTable.table,
      {CustomersTable.cIsBlocked: 1},
      where: '${CustomersTable.cId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> unblockCustomer(int id) async {
    final database = await db;
    return await database.update(
      CustomersTable.table,
      {CustomersTable.cIsBlocked: 0},
      where: '${CustomersTable.cId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateDebt(int id, double amount) async {
    final sql = BaseQueries.updateSyncStatus(tableName);
    return await rawUpdate(
      'UPDATE ${CustomersTable.table} SET ${CustomersTable.cCurrentDebt} = ${CustomersTable.cCurrentDebt} + ? WHERE ${CustomersTable.cId} = ?',
      [amount, id],
    );
  }

  Future<int> updateTotalPurchases(int id, double amount) async {
    return await rawUpdate(
      'UPDATE ${CustomersTable.table} SET ${CustomersTable.cTotalPurchases} = ${CustomersTable.cTotalPurchases} + ? WHERE ${CustomersTable.cId} = ?',
      [amount, id],
    );
  }
}
