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
      FROM ${PurchasesTable.table} 
      WHERE ${PurchasesTable.cDate} = ?
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
      where: '${PurchasesTable.cInvoiceNumber} = ?',
      whereArgs: [invoiceNumber],
    );
    
    return result.isEmpty;
  }

  /// جلب آخر رقم فاتورة
  Future<String?> getLastInvoiceNumber() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT ${PurchasesTable.cInvoiceNumber} 
      FROM ${PurchasesTable.table} 
      WHERE ${PurchasesTable.cInvoiceNumber} IS NOT NULL
      ORDER BY ${PurchasesTable.cId} DESC 
      LIMIT 1
      ''',
    );
    
    if (result.isEmpty) return null;
    return result.first[PurchasesTable.cInvoiceNumber] as String?;
  }
}
