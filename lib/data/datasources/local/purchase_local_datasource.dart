// ignore_for_file: public_member_api_docs

import '../../database/tables/purchases_table.dart';
import '../../models/purchase_model.dart';
import 'base_local_datasource.dart';

class PurchaseLocalDataSource extends BaseLocalDataSource<PurchaseModel> {
  PurchaseLocalDataSource(super.dbHelper);

  @override
  String get tableName => PurchasesTable.table;

  @override
  PurchaseModel fromMap(Map<String, dynamic> map) => PurchaseModel.fromMap(map);

  /// جلب مشتريات اليوم
  Future<List<PurchaseModel>> getToday(String date) async {
    return await getWhere(
      where: '${PurchasesTable.cDate} = ?',
      whereArgs: [date],
      orderBy: '${PurchasesTable.cTime} DESC',
    );
  }

  /// جلب المشتريات حسب المورد
  Future<List<PurchaseModel>> getBySupplier(int supplierId) async {
    return await getWhere(
      where: '${PurchasesTable.cSupplierId} = ?',
      whereArgs: [supplierId],
      orderBy: '${PurchasesTable.cDate} DESC, ${PurchasesTable.cTime} DESC',
    );
  }

  /// جلب المشتريات المعلقة
  Future<List<PurchaseModel>> getPending() async {
    return await getWhere(
      where: "${PurchasesTable.cPaymentStatus} IN ('معلق', 'جزئي')",
      whereArgs: [],
      orderBy: '${PurchasesTable.cDate} DESC',
    );
  }

  /// جلب المشتريات حسب فترة زمنية
  Future<List<PurchaseModel>> getByDateRange(String startDate, String endDate) async {
    return await getWhere(
      where: '${PurchasesTable.cDate} BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: '${PurchasesTable.cDate} DESC',
    );
  }
  
  /// جلب المشتريات حسب التاريخ
  Future<List<PurchaseModel>> getByDate(String date) async {
    return await getWhere(
      where: '${PurchasesTable.cDate} = ?',
      whereArgs: [date],
      orderBy: '${PurchasesTable.cTime} DESC',
    );
  }

  /// جلب المشتريات حسب نوع القات
  Future<List<PurchaseModel>> getByQatType(int qatTypeId) async {
    return await getWhere(
      where: '${PurchasesTable.cQatTypeId} = ? AND ${PurchasesTable.cStatus} = ?',
      whereArgs: [qatTypeId, 'نشط'],
      orderBy: '${PurchasesTable.cDate} DESC, ${PurchasesTable.cTime} DESC',
    );
  }
}
