import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/return_item.dart';
import '../../database/database_helper.dart';
import '../../database/tables/returns_table.dart';

/// مصدر البيانات المحلي للمردودات
class ReturnsLocalDataSource {
  final DatabaseHelper _databaseHelper;

  ReturnsLocalDataSource(this._databaseHelper);

  // ================= العمليات الأساسية =================

  /// الحصول على جميع المردودات
  Future<List<ReturnItem>> getAllReturns() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      ReturnsTable.table,
      orderBy: '${ReturnsTable.cReturnDate} DESC, ${ReturnsTable.cReturnTime} DESC',
    );

    return maps.map((map) => _mapToReturnItem(map)).toList();
  }

  /// الحصول على مردود بالمعرف
  Future<ReturnItem?> getReturnById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      ReturnsTable.table,
      where: '${ReturnsTable.cId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToReturnItem(maps.first);
  }

  /// الحصول على المردودات حسب النوع
  Future<List<ReturnItem>> getReturnsByType(String returnType) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      ReturnsTable.table,
      where: '${ReturnsTable.cReturnType} = ?',
      whereArgs: [returnType],
      orderBy: '${ReturnsTable.cReturnDate} DESC',
    );

    return maps.map((map) => _mapToReturnItem(map)).toList();
  }

  /// الحصول على المردودات حسب الحالة
  Future<List<ReturnItem>> getReturnsByStatus(String status) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      ReturnsTable.table,
      where: '${ReturnsTable.cStatus} = ?',
      whereArgs: [status],
      orderBy: '${ReturnsTable.cReturnDate} DESC',
    );

    return maps.map((map) => _mapToReturnItem(map)).toList();
  }

  /// الحصول على المردودات في فترة زمنية
  Future<List<ReturnItem>> getReturnsByDateRange(String startDate, String endDate) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      ReturnsTable.table,
      where: '${ReturnsTable.cReturnDate} BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: '${ReturnsTable.cReturnDate} DESC',
    );

    return maps.map((map) => _mapToReturnItem(map)).toList();
  }

  /// الحصول على مردود العملاء
  Future<List<ReturnItem>> getSalesReturns() async {
    return await getReturnsByType('مردود_مبيعات');
  }

  /// الحصول على مردود المشتريات
  Future<List<ReturnItem>> getPurchaseReturns() async {
    return await getReturnsByType('مردود_مشتريات');
  }

  /// الحصول على مردود عميل معين
  Future<List<ReturnItem>> getReturnsByCustomer(int customerId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      ReturnsTable.table,
      where: '${ReturnsTable.cCustomerId} = ?',
      whereArgs: [customerId],
      orderBy: '${ReturnsTable.cReturnDate} DESC',
    );

    return maps.map((map) => _mapToReturnItem(map)).toList();
  }

  /// الحصول على مردود مورد معين
  Future<List<ReturnItem>> getReturnsBySupplier(int supplierId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      ReturnsTable.table,
      where: '${ReturnsTable.cSupplierId} = ?',
      whereArgs: [supplierId],
      orderBy: '${ReturnsTable.cReturnDate} DESC',
    );

    return maps.map((map) => _mapToReturnItem(map)).toList();
  }

  /// البحث في المردودات
  Future<List<ReturnItem>> searchReturns(String query) async {
    final db = await _databaseHelper.database;
    final searchQuery = '%$query%';
    final maps = await db.query(
      ReturnsTable.table,
      where: '''
        ${ReturnsTable.cReturnNumber} LIKE ? OR 
        ${ReturnsTable.cQatTypeName} LIKE ? OR 
        ${ReturnsTable.cCustomerName} LIKE ? OR 
        ${ReturnsTable.cSupplierName} LIKE ? OR
        ${ReturnsTable.cReturnReason} LIKE ?
      ''',
      whereArgs: [searchQuery, searchQuery, searchQuery, searchQuery, searchQuery],
      orderBy: '${ReturnsTable.cReturnDate} DESC',
    );

    return maps.map((map) => _mapToReturnItem(map)).toList();
  }

  // ================= عمليات التحديث =================

  /// إضافة مردود جديد
  Future<int> addReturn(ReturnItem returnItem) async {
    final db = await _databaseHelper.database;
    try {
      return await db.insert(
        ReturnsTable.table,
        _returnItemToMap(returnItem),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error adding return: $e');
      rethrow;
    }
  }

  /// تحديث مردود
  Future<bool> updateReturn(ReturnItem returnItem) async {
    final db = await _databaseHelper.database;
    try {
      final count = await db.update(
        ReturnsTable.table,
        _returnItemToMap(returnItem),
        where: '${ReturnsTable.cId} = ?',
        whereArgs: [returnItem.id],
      );
      return count > 0;
    } catch (e) {
      print('Error updating return: $e');
      return false;
    }
  }

  /// حذف مردود
  Future<bool> deleteReturn(int id) async {
    final db = await _databaseHelper.database;
    try {
      final count = await db.delete(
        ReturnsTable.table,
        where: '${ReturnsTable.cId} = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      print('Error deleting return: $e');
      return false;
    }
  }

  // ================= الإحصائيات =================

  /// الحصول على إحصائيات المردود
  Future<Map<String, dynamic>> getReturnsStatistics() async {
    final db = await _databaseHelper.database;
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as totalReturns,
        COUNT(CASE WHEN ${ReturnsTable.cReturnType} = 'مردود_مبيعات' THEN 1 END) as salesReturns,
        COUNT(CASE WHEN ${ReturnsTable.cReturnType} = 'مردود_مشتريات' THEN 1 END) as purchaseReturns,
        COUNT(CASE WHEN ${ReturnsTable.cStatus} = 'معلق' THEN 1 END) as pendingReturns,
        COUNT(CASE WHEN ${ReturnsTable.cStatus} = 'مؤكد' THEN 1 END) as confirmedReturns,
        SUM(${ReturnsTable.cTotalAmount}) as totalValue,
        SUM(CASE WHEN ${ReturnsTable.cReturnType} = 'مردود_مبيعات' THEN ${ReturnsTable.cTotalAmount} ELSE 0 END) as salesReturnValue,
        SUM(CASE WHEN ${ReturnsTable.cReturnType} = 'مردود_مشتريات' THEN ${ReturnsTable.cTotalAmount} ELSE 0 END) as purchaseReturnValue
      FROM ${ReturnsTable.table}
    ''');

    final map = result.first;
    return {
      'totalReturns': map['totalReturns'] ?? 0,
      'salesReturns': map['salesReturns'] ?? 0,
      'purchaseReturns': map['purchaseReturns'] ?? 0,
      'pendingReturns': map['pendingReturns'] ?? 0,
      'confirmedReturns': map['confirmedReturns'] ?? 0,
      'totalValue': (map['totalValue'] as num?)?.toDouble() ?? 0.0,
      'salesReturnValue': (map['salesReturnValue'] as num?)?.toDouble() ?? 0.0,
      'purchaseReturnValue': (map['purchaseReturnValue'] as num?)?.toDouble() ?? 0.0,
    };
  }

  /// الحصول على ملخص المردود في فترة
  Future<Map<String, dynamic>> getReturnsSummaryByPeriod(String startDate, String endDate) async {
    final db = await _databaseHelper.database;
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as totalReturns,
        SUM(${ReturnsTable.cTotalAmount}) as totalValue,
        AVG(${ReturnsTable.cTotalAmount}) as averageValue
      FROM ${ReturnsTable.table}
      WHERE ${ReturnsTable.cReturnDate} BETWEEN ? AND ?
    ''', [startDate, endDate]);

    final map = result.first;
    return {
      'totalReturns': map['totalReturns'] ?? 0,
      'totalValue': (map['totalValue'] as num?)?.toDouble() ?? 0.0,
      'averageValue': (map['averageValue'] as num?)?.toDouble() ?? 0.0,
    };
  }

  /// تحليل أسباب المردود
  Future<Map<String, int>> getReturnReasonAnalysis() async {
    final db = await _databaseHelper.database;
    
    final result = await db.rawQuery('''
      SELECT ${ReturnsTable.cReturnReason}, COUNT(*) as count
      FROM ${ReturnsTable.table}
      GROUP BY ${ReturnsTable.cReturnReason}
      ORDER BY count DESC
    ''');

    final Map<String, int> analysis = {};
    for (final row in result) {
      analysis[row['${ReturnsTable.cReturnReason}'] as String] = row['count'] as int;
    }
    
    return analysis;
  }

  // ================= Helper Methods =================

  /// تحويل Map إلى ReturnItem
  ReturnItem _mapToReturnItem(Map<String, dynamic> map) {
    return ReturnItem(
      id: map[ReturnsTable.cId],
      returnDate: map[ReturnsTable.cReturnDate],
      returnTime: map[ReturnsTable.cReturnTime],
      returnType: map[ReturnsTable.cReturnType],
      returnNumber: map[ReturnsTable.cReturnNumber],
      customerId: map[ReturnsTable.cCustomerId],
      customerName: map[ReturnsTable.cCustomerName],
      supplierId: map[ReturnsTable.cSupplierId],
      supplierName: map[ReturnsTable.cSupplierName],
      qatTypeId: map[ReturnsTable.cQatTypeId],
      qatTypeName: map[ReturnsTable.cQatTypeName],
      unit: map[ReturnsTable.cUnit],
      quantity: (map[ReturnsTable.cQuantity] as num).toDouble(),
      unitPrice: (map[ReturnsTable.cUnitPrice] as num).toDouble(),
      totalAmount: (map[ReturnsTable.cTotalAmount] as num).toDouble(),
      returnReason: map[ReturnsTable.cReturnReason],
      notes: map[ReturnsTable.cNotes],
      status: map[ReturnsTable.cStatus] ?? 'معلق',
      originalSaleId: map[ReturnsTable.cOriginalSaleId],
      originalPurchaseId: map[ReturnsTable.cOriginalPurchaseId],
      originalInvoiceNumber: map[ReturnsTable.cOriginalInvoiceNumber],
      createdBy: map[ReturnsTable.cCreatedBy],
      createdAt: map[ReturnsTable.cCreatedAt],
      updatedAt: map[ReturnsTable.cUpdatedAt],
      syncStatus: map[ReturnsTable.cSyncStatus] ?? 'pending',
      firebaseId: map[ReturnsTable.cFirebaseId],
    );
  }

  /// تحويل ReturnItem إلى Map
  Map<String, dynamic> _returnItemToMap(ReturnItem returnItem) {
    return {
      if (returnItem.id != null) ReturnsTable.cId: returnItem.id,
      ReturnsTable.cReturnDate: returnItem.returnDate,
      ReturnsTable.cReturnTime: returnItem.returnTime,
      ReturnsTable.cReturnType: returnItem.returnType,
      ReturnsTable.cReturnNumber: returnItem.returnNumber,
      ReturnsTable.cCustomerId: returnItem.customerId,
      ReturnsTable.cCustomerName: returnItem.customerName,
      ReturnsTable.cSupplierId: returnItem.supplierId,
      ReturnsTable.cSupplierName: returnItem.supplierName,
      ReturnsTable.cQatTypeId: returnItem.qatTypeId,
      ReturnsTable.cQatTypeName: returnItem.qatTypeName,
      ReturnsTable.cUnit: returnItem.unit,
      ReturnsTable.cQuantity: returnItem.quantity,
      ReturnsTable.cUnitPrice: returnItem.unitPrice,
      ReturnsTable.cTotalAmount: returnItem.totalAmount,
      ReturnsTable.cReturnReason: returnItem.returnReason,
      ReturnsTable.cNotes: returnItem.notes,
      ReturnsTable.cStatus: returnItem.status,
      ReturnsTable.cOriginalSaleId: returnItem.originalSaleId,
      ReturnsTable.cOriginalPurchaseId: returnItem.originalPurchaseId,
      ReturnsTable.cOriginalInvoiceNumber: returnItem.originalInvoiceNumber,
      ReturnsTable.cCreatedBy: returnItem.createdBy,
      ReturnsTable.cCreatedAt: returnItem.createdAt ?? DateTime.now().toIso8601String(),
      ReturnsTable.cUpdatedAt: returnItem.updatedAt ?? DateTime.now().toIso8601String(),
      ReturnsTable.cSyncStatus: returnItem.syncStatus ?? 'pending',
      ReturnsTable.cFirebaseId: returnItem.firebaseId,
    };
  }
}
