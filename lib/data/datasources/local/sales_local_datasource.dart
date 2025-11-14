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

  /// توليد رقم فاتورة تلقائي رقمي فقط
  /// النمط: YYYYMMDDXXXX (رقم السنة + الشهر + اليوم + رقم تسلسلي يومي)
  /// مثال: 202501150001 (الفاتورة الأولى في 2025-01-15)
  Future<String> generateInvoiceNumber() async {
    final db = await dbHelper.database;
    final today = DateTime.now();
    final dateStr = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
    
    // جلب عدد الفواتير اليوم
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count 
      FROM ${SalesTable.table} 
      WHERE ${SalesTable.cDate} = ?
      ''',
      [today.toIso8601String().split('T')[0]],
    );
    
    final count = (result.first['count'] as int?) ?? 0;
    final sequenceNumber = (count + 1).toString().padLeft(4, '0');
    
    return '$dateStr$sequenceNumber';
  }

  /// التحقق من توفر رقم فاتورة
  Future<bool> isInvoiceNumberAvailable(String invoiceNumber) async {
    if (invoiceNumber.trim().isEmpty) return true;
    
    final result = await getWhere(
      where: '${SalesTable.cInvoiceNumber} = ?',
      whereArgs: [invoiceNumber],
    );
    
    return result.isEmpty;
  }

  /// جلب آخر رقم فاتورة
  Future<String?> getLastInvoiceNumber() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT ${SalesTable.cInvoiceNumber} 
      FROM ${SalesTable.table} 
      WHERE ${SalesTable.cInvoiceNumber} IS NOT NULL
      ORDER BY ${SalesTable.cId} DESC 
      LIMIT 1
      ''',
    );
    
    if (result.isEmpty) return null;
    return result.first[SalesTable.cInvoiceNumber] as String?;
  }
}
