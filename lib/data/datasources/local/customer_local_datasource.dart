// ignore_for_file: public_member_api_docs

import '../../database/tables/customers_table.dart';
import '../../models/customer_model.dart';
import 'base_local_datasource.dart';

/// مصدر بيانات محلي للعملاء
class CustomerLocalDataSource extends BaseLocalDataSource<CustomerModel> {
  CustomerLocalDataSource(super.dbHelper);

  @override
  String get tableName => CustomersTable.table;

  @override
  CustomerModel fromMap(Map<String, dynamic> map) => CustomerModel.fromMap(map);

  /// البحث في العملاء بالاسم
  Future<List<CustomerModel>> searchByName(String query) async {
    return await search(
      column: CustomersTable.cName,
      query: query,
      orderBy: '${CustomersTable.cName} COLLATE NOCASE',
    );
  }

  /// جلب العملاء المحظورين
  Future<List<CustomerModel>> getBlocked() async {
    return await getWhere(
      where: '${CustomersTable.cIsBlocked} = 1',
      whereArgs: [],
      orderBy: '${CustomersTable.cName} COLLATE NOCASE',
    );
  }

  /// جلب العملاء غير المحظورين
  Future<List<CustomerModel>> getActive() async {
    return await getWhere(
      where: '${CustomersTable.cIsBlocked} = 0',
      whereArgs: [],
      orderBy: '${CustomersTable.cName} COLLATE NOCASE',
    );
  }

  /// جلب العملاء الذين لديهم ديون
  Future<List<CustomerModel>> getCustomersWithDebts() async {
    return await getWhere(
      where: '${CustomersTable.cCurrentDebt} > ?',
      whereArgs: [0],
      orderBy: '${CustomersTable.cCurrentDebt} DESC',
    );
  }

  /// جلب العملاء حسب نوع العميل
  Future<List<CustomerModel>> getByType(String type) async {
    return await getWhere(
      where: '${CustomersTable.cCustomerType} = ?',
      whereArgs: [type],
      orderBy: '${CustomersTable.cName} COLLATE NOCASE',
    );
  }

  /// حظر عميل
  Future<int> blockCustomer(int id) async {
    final database = await db;
    return await database.update(
      CustomersTable.table,
      {CustomersTable.cIsBlocked: 1},
      where: '${CustomersTable.cId} = ?',
      whereArgs: [id],
    );
  }

  /// إلغاء حظر عميل
  Future<int> unblockCustomer(int id) async {
    final database = await db;
    return await database.update(
      CustomersTable.table,
      {CustomersTable.cIsBlocked: 0},
      where: '${CustomersTable.cId} = ?',
      whereArgs: [id],
    );
  }

  /// تحديث دين العميل
  Future<int> updateDebt(int id, double amount) async {
    final database = await db;
    return await database.rawUpdate(
      'UPDATE ${CustomersTable.table} SET ${CustomersTable.cCurrentDebt} = ${CustomersTable.cCurrentDebt} + ? WHERE ${CustomersTable.cId} = ?',
      [amount, id],
    );
  }

  /// تحديث إجمالي المشتريات
  Future<int> updateTotalPurchases(int id, double amount) async {
    final database = await db;
    return await database.rawUpdate(
      'UPDATE ${CustomersTable.table} SET ${CustomersTable.cTotalPurchases} = ${CustomersTable.cTotalPurchases} + ? WHERE ${CustomersTable.cId} = ?',
      [amount, id],
    );
  }
}
