// ignore_for_file: public_member_api_docs

import '../../database/tables/sales_table.dart';
import '../../models/sale_model.dart';
import 'base_local_datasource.dart';

class SalesLocalDataSource extends BaseLocalDataSource<SaleModel> {
  SalesLocalDataSource(super.dbHelper);

  @override
  String get tableName => SalesTable.table;

  @override
  SaleModel fromMap(Map<String, dynamic> map) => SaleModel.fromMap(map);

  /// جلب مبيعات اليوم
  Future<List<SaleModel>> getToday(String date) async {
    return await getWhere(
      where: '${SalesTable.cDate} = ?',
      whereArgs: [date],
      orderBy: '${SalesTable.cTime} DESC',
    );
  }

  /// جلب المبيعات حسب العميل
  Future<List<SaleModel>> getByCustomer(int customerId) async {
    return await getWhere(
      where: '${SalesTable.cCustomerId} = ?',
      whereArgs: [customerId],
      orderBy: '${SalesTable.cDate} DESC, ${SalesTable.cTime} DESC',
    );
  }

  /// جلب المبيعات المعلقة
  Future<List<SaleModel>> getPending() async {
    return await getWhere(
      where: "${SalesTable.cPaymentStatus} IN ('معلق', 'جزئي')",
      whereArgs: [],
      orderBy: '${SalesTable.cDate} DESC',
    );
  }

  /// جلب المبيعات السريعة
  Future<List<SaleModel>> getQuickSales() async {
    return await getWhere(
      where: '${SalesTable.cIsQuickSale} = 1',
      whereArgs: [],
      orderBy: '${SalesTable.cDate} DESC',
    );
  }
  
  /// جلب المبيعات حسب التاريخ
  Future<List<SaleModel>> getByDate(String date) async {
    return await getWhere(
      where: '${SalesTable.cDate} = ?',
      whereArgs: [date],
      orderBy: '${SalesTable.cTime} DESC',
    );
  }

  /// جلب المبيعات حسب فترة زمنية
  Future<List<SaleModel>> getByDateRange(String startDate, String endDate) async {
    return await getWhere(
      where: '${SalesTable.cDate} BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: '${SalesTable.cDate} DESC',
    );
  }

  /// جلب المبيعات حسب نوع القات
  Future<List<SaleModel>> getByQatType(int qatTypeId) async {
    return await getWhere(
      where: '${SalesTable.cQatTypeId} = ? AND ${SalesTable.cStatus} = ?',
      whereArgs: [qatTypeId, 'نشط'],
      orderBy: '${SalesTable.cDate} DESC, ${SalesTable.cTime} DESC',
    );
  }
}
