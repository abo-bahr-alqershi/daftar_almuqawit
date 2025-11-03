// ignore_for_file: public_member_api_docs

import '../../database/tables/suppliers_table.dart';
import '../../models/supplier_model.dart';
import 'base_local_datasource.dart';

/// مصدر بيانات محلي للموردين (SQLite)
class SupplierLocalDataSource extends BaseLocalDataSource<SupplierModel> {
  SupplierLocalDataSource(super.dbHelper);

  @override
  String get tableName => SuppliersTable.table;

  @override
  SupplierModel fromMap(Map<String, dynamic> map) => SupplierModel.fromMap(map);

  /// البحث في الموردين بالاسم
  Future<List<SupplierModel>> searchByName(String query) async {
    return await search(
      column: SuppliersTable.cName,
      query: query,
      orderBy: '${SuppliersTable.cName} COLLATE NOCASE',
    );
  }

  /// جلب الموردين حسب المنطقة
  Future<List<SupplierModel>> getByArea(String area) async {
    return await getWhere(
      where: '${SuppliersTable.cArea} = ?',
      whereArgs: [area],
      orderBy: '${SuppliersTable.cName} COLLATE NOCASE',
    );
  }

  /// جلب الموردين حسب التقييم
  Future<List<SupplierModel>> getByRating(int minRating) async {
    return await getWhere(
      where: '${SuppliersTable.cQualityRating} >= ?',
      whereArgs: [minRating],
      orderBy: '${SuppliersTable.cQualityRating} DESC',
    );
  }

  /// جلب الموردين الذين لديهم ديون
  Future<List<SupplierModel>> getSuppliersWithDebts() async {
    return await getWhere(
      where: '${SuppliersTable.cTotalDebtToHim} > ?',
      whereArgs: [0],
      orderBy: '${SuppliersTable.cTotalDebtToHim} DESC',
    );
  }

  /// تحديث إجمالي المشتريات
  Future<int> updateTotalPurchases(int id, double amount) async {
    final database = await db;
    return await database.rawUpdate(
      'UPDATE ${SuppliersTable.table} SET ${SuppliersTable.cTotalPurchases} = ${SuppliersTable.cTotalPurchases} + ? WHERE ${SuppliersTable.cId} = ?',
      [amount, id],
    );
  }

  /// تحديث إجمالي الديون
  Future<int> updateTotalDebt(int id, double amount) async {
    final database = await db;
    return await database.rawUpdate(
      'UPDATE ${SuppliersTable.table} SET ${SuppliersTable.cTotalDebtToHim} = ${SuppliersTable.cTotalDebtToHim} + ? WHERE ${SuppliersTable.cId} = ?',
      [amount, id],
    );
  }
}
