import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/damaged_item.dart';
import '../../database/database_helper.dart';
import '../../database/tables/damaged_items_table.dart';

/// مصدر البيانات المحلي للبضاعة التالفة
class DamagedItemsLocalDataSource {
  final DatabaseHelper _databaseHelper;

  DamagedItemsLocalDataSource(this._databaseHelper);

  // ================= العمليات الأساسية =================

  /// الحصول على جميع البضاعة التالفة
  Future<List<DamagedItem>> getAllDamagedItems() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DamagedItemsTable.table,
      orderBy: '${DamagedItemsTable.cDamageDate} DESC, ${DamagedItemsTable.cDamageTime} DESC',
    );

    return maps.map((map) => _mapToDamagedItem(map)).toList();
  }

  /// الحصول على عنصر تالف بالمعرف
  Future<DamagedItem?> getDamagedItemById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DamagedItemsTable.table,
      where: '${DamagedItemsTable.cId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToDamagedItem(maps.first);
  }

  /// الحصول على البضاعة التالفة حسب النوع
  Future<List<DamagedItem>> getDamagedItemsByType(String damageType) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DamagedItemsTable.table,
      where: '${DamagedItemsTable.cDamageType} = ?',
      whereArgs: [damageType],
      orderBy: '${DamagedItemsTable.cDamageDate} DESC',
    );

    return maps.map((map) => _mapToDamagedItem(map)).toList();
  }

  /// الحصول على البضاعة التالفة حسب الحالة
  Future<List<DamagedItem>> getDamagedItemsByStatus(String status) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DamagedItemsTable.table,
      where: '${DamagedItemsTable.cStatus} = ?',
      whereArgs: [status],
      orderBy: '${DamagedItemsTable.cDamageDate} DESC',
    );

    return maps.map((map) => _mapToDamagedItem(map)).toList();
  }

  /// الحصول على البضاعة التالفة حسب مستوى الخطورة
  Future<List<DamagedItem>> getDamagedItemsBySeverity(String severityLevel) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DamagedItemsTable.table,
      where: '${DamagedItemsTable.cSeverityLevel} = ?',
      whereArgs: [severityLevel],
      orderBy: '${DamagedItemsTable.cDamageDate} DESC',
    );

    return maps.map((map) => _mapToDamagedItem(map)).toList();
  }

  /// الحصول على البضاعة التالفة الحرجة
  Future<List<DamagedItem>> getCriticalDamagedItems() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DamagedItemsTable.table,
      where: '${DamagedItemsTable.cSeverityLevel} IN (?, ?)',
      whereArgs: ['كبير', 'كارثي'],
      orderBy: '${DamagedItemsTable.cDamageDate} DESC',
    );

    return maps.map((map) => _mapToDamagedItem(map)).toList();
  }

  /// الحصول على البضاعة التالفة في فترة زمنية
  Future<List<DamagedItem>> getDamagedItemsByDateRange(String startDate, String endDate) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DamagedItemsTable.table,
      where: '${DamagedItemsTable.cDamageDate} BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: '${DamagedItemsTable.cDamageDate} DESC',
    );

    return maps.map((map) => _mapToDamagedItem(map)).toList();
  }

  /// الحصول على البضاعة التالفة حسب المخزن
  Future<List<DamagedItem>> getDamagedItemsByWarehouse(int warehouseId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DamagedItemsTable.table,
      where: '${DamagedItemsTable.cWarehouseId} = ?',
      whereArgs: [warehouseId],
      orderBy: '${DamagedItemsTable.cDamageDate} DESC',
    );

    return maps.map((map) => _mapToDamagedItem(map)).toList();
  }

  /// الحصول على البضاعة المنتهية الصلاحية
  Future<List<DamagedItem>> getExpiredItems() async {
    final db = await _databaseHelper.database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    final maps = await db.query(
      DamagedItemsTable.table,
      where: '${DamagedItemsTable.cExpiryDate} IS NOT NULL AND ${DamagedItemsTable.cExpiryDate} < ?',
      whereArgs: [today],
      orderBy: '${DamagedItemsTable.cExpiryDate} ASC',
    );

    return maps.map((map) => _mapToDamagedItem(map)).toList();
  }

  /// الحصول على البضاعة التي ستنتهي صلاحيتها خلال أيام محددة
  Future<List<DamagedItem>> getItemsExpiringInDays(int days) async {
    final db = await _databaseHelper.database;
    final today = DateTime.now();
    final futureDate = today.add(Duration(days: days));
    
    final maps = await db.query(
      DamagedItemsTable.table,
      where: '''
        ${DamagedItemsTable.cExpiryDate} IS NOT NULL AND 
        ${DamagedItemsTable.cExpiryDate} BETWEEN ? AND ?
      ''',
      whereArgs: [
        today.toIso8601String().split('T')[0],
        futureDate.toIso8601String().split('T')[0],
      ],
      orderBy: '${DamagedItemsTable.cExpiryDate} ASC',
    );

    return maps.map((map) => _mapToDamagedItem(map)).toList();
  }

  /// البحث في البضاعة التالفة
  Future<List<DamagedItem>> searchDamagedItems(String query) async {
    final db = await _databaseHelper.database;
    final searchQuery = '%$query%';
    final maps = await db.query(
      DamagedItemsTable.table,
      where: '''
        ${DamagedItemsTable.cDamageNumber} LIKE ? OR 
        ${DamagedItemsTable.cQatTypeName} LIKE ? OR 
        ${DamagedItemsTable.cDamageReason} LIKE ? OR
        ${DamagedItemsTable.cResponsiblePerson} LIKE ? OR
        ${DamagedItemsTable.cDiscoveredBy} LIKE ?
      ''',
      whereArgs: [searchQuery, searchQuery, searchQuery, searchQuery, searchQuery],
      orderBy: '${DamagedItemsTable.cDamageDate} DESC',
    );

    return maps.map((map) => _mapToDamagedItem(map)).toList();
  }

  /// الحصول على البضاعة المشمولة بالتأمين
  Future<List<DamagedItem>> getInsuranceCoveredItems() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DamagedItemsTable.table,
      where: '${DamagedItemsTable.cIsInsuranceCovered} = ?',
      whereArgs: [1],
      orderBy: '${DamagedItemsTable.cDamageDate} DESC',
    );

    return maps.map((map) => _mapToDamagedItem(map)).toList();
  }

  // ================= عمليات التحديث =================

  /// إضافة عنصر تالف جديد
  Future<int> addDamagedItem(DamagedItem damagedItem) async {
    final db = await _databaseHelper.database;
    try {
      return await db.insert(
        DamagedItemsTable.table,
        _damagedItemToMap(damagedItem),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error adding damaged item: $e');
      rethrow;
    }
  }

  /// تحديث عنصر تالف
  Future<bool> updateDamagedItem(DamagedItem damagedItem) async {
    final db = await _databaseHelper.database;
    try {
      final count = await db.update(
        DamagedItemsTable.table,
        _damagedItemToMap(damagedItem),
        where: '${DamagedItemsTable.cId} = ?',
        whereArgs: [damagedItem.id],
      );
      return count > 0;
    } catch (e) {
      print('Error updating damaged item: $e');
      return false;
    }
  }

  /// حذف عنصر تالف
  Future<bool> deleteDamagedItem(int id) async {
    final db = await _databaseHelper.database;
    try {
      final count = await db.delete(
        DamagedItemsTable.table,
        where: '${DamagedItemsTable.cId} = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      print('Error deleting damaged item: $e');
      return false;
    }
  }

  // ================= الإحصائيات =================

  /// الحصول على إحصائيات البضاعة التالفة
  Future<Map<String, dynamic>> getDamageStatistics() async {
    final db = await _databaseHelper.database;
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as totalDamaged,
        COUNT(CASE WHEN ${DamagedItemsTable.cStatus} = 'تحت_المراجعة' THEN 1 END) as underReview,
        COUNT(CASE WHEN ${DamagedItemsTable.cStatus} = 'مؤكد' THEN 1 END) as confirmed,
        COUNT(CASE WHEN ${DamagedItemsTable.cStatus} = 'تم_التعامل_معه' THEN 1 END) as handled,
        COUNT(CASE WHEN ${DamagedItemsTable.cSeverityLevel} IN ('كبير', 'كارثي') THEN 1 END) as critical,
        COUNT(CASE WHEN ${DamagedItemsTable.cIsInsuranceCovered} = 1 THEN 1 END) as insuranceCovered,
        SUM(${DamagedItemsTable.cTotalCost}) as totalValue,
        SUM(CASE WHEN ${DamagedItemsTable.cIsInsuranceCovered} = 1 THEN ${DamagedItemsTable.cInsuranceAmount} ELSE 0 END) as totalInsuranceAmount
      FROM ${DamagedItemsTable.table}
    ''');

    final map = result.first;
    return {
      'totalDamaged': map['totalDamaged'] ?? 0,
      'underReview': map['underReview'] ?? 0,
      'confirmed': map['confirmed'] ?? 0,
      'handled': map['handled'] ?? 0,
      'critical': map['critical'] ?? 0,
      'insuranceCovered': map['insuranceCovered'] ?? 0,
      'totalValue': (map['totalValue'] as num?)?.toDouble() ?? 0.0,
      'totalInsuranceAmount': (map['totalInsuranceAmount'] as num?)?.toDouble() ?? 0.0,
    };
  }

  /// تحليل أسباب التلف
  Future<Map<String, int>> getDamageReasonAnalysis() async {
    final db = await _databaseHelper.database;
    
    final result = await db.rawQuery('''
      SELECT ${DamagedItemsTable.cDamageReason}, COUNT(*) as count
      FROM ${DamagedItemsTable.table}
      GROUP BY ${DamagedItemsTable.cDamageReason}
      ORDER BY count DESC
    ''');

    final Map<String, int> analysis = {};
    for (final row in result) {
      analysis[row['${DamagedItemsTable.cDamageReason}'] as String] = row['count'] as int;
    }
    
    return analysis;
  }

  /// تحليل التلف حسب النوع
  Future<Map<String, double>> getDamageValueByType() async {
    final db = await _databaseHelper.database;
    
    final result = await db.rawQuery('''
      SELECT ${DamagedItemsTable.cDamageType}, SUM(${DamagedItemsTable.cTotalCost}) as totalValue
      FROM ${DamagedItemsTable.table}
      GROUP BY ${DamagedItemsTable.cDamageType}
      ORDER BY totalValue DESC
    ''');

    final Map<String, double> analysis = {};
    for (final row in result) {
      analysis[row['${DamagedItemsTable.cDamageType}'] as String] = 
          (row['totalValue'] as num?)?.toDouble() ?? 0.0;
    }
    
    return analysis;
  }

  // ================= Helper Methods =================

  /// تحويل Map إلى DamagedItem
  DamagedItem _mapToDamagedItem(Map<String, dynamic> map) {
    return DamagedItem(
      id: map[DamagedItemsTable.cId],
      damageDate: map[DamagedItemsTable.cDamageDate],
      damageTime: map[DamagedItemsTable.cDamageTime],
      damageNumber: map[DamagedItemsTable.cDamageNumber],
      qatTypeId: map[DamagedItemsTable.cQatTypeId],
      qatTypeName: map[DamagedItemsTable.cQatTypeName],
      unit: map[DamagedItemsTable.cUnit],
      quantity: (map[DamagedItemsTable.cQuantity] as num).toDouble(),
      unitCost: (map[DamagedItemsTable.cUnitCost] as num).toDouble(),
      totalCost: (map[DamagedItemsTable.cTotalCost] as num).toDouble(),
      damageReason: map[DamagedItemsTable.cDamageReason],
      damageType: map[DamagedItemsTable.cDamageType],
      severityLevel: map[DamagedItemsTable.cSeverityLevel] ?? 'متوسط',
      notes: map[DamagedItemsTable.cNotes],
      actionTaken: map[DamagedItemsTable.cActionTaken],
      isInsuranceCovered: (map[DamagedItemsTable.cIsInsuranceCovered] as int) == 1,
      insuranceAmount: (map[DamagedItemsTable.cInsuranceAmount] as num?)?.toDouble(),
      responsiblePerson: map[DamagedItemsTable.cResponsiblePerson],
      status: map[DamagedItemsTable.cStatus] ?? 'تحت_المراجعة',
      warehouseId: map[DamagedItemsTable.cWarehouseId] ?? 1,
      warehouseName: map[DamagedItemsTable.cWarehouseName] ?? 'المخزن الرئيسي',
      batchNumber: map[DamagedItemsTable.cBatchNumber],
      expiryDate: map[DamagedItemsTable.cExpiryDate],
      discoveredBy: map[DamagedItemsTable.cDiscoveredBy],
      createdBy: map[DamagedItemsTable.cCreatedBy],
      createdAt: map[DamagedItemsTable.cCreatedAt],
      updatedAt: map[DamagedItemsTable.cUpdatedAt],
      syncStatus: map[DamagedItemsTable.cSyncStatus] ?? 'pending',
      firebaseId: map[DamagedItemsTable.cFirebaseId],
    );
  }

  /// تحويل DamagedItem إلى Map
  Map<String, dynamic> _damagedItemToMap(DamagedItem damagedItem) {
    return {
      if (damagedItem.id != null) DamagedItemsTable.cId: damagedItem.id,
      DamagedItemsTable.cDamageDate: damagedItem.damageDate,
      DamagedItemsTable.cDamageTime: damagedItem.damageTime,
      DamagedItemsTable.cDamageNumber: damagedItem.damageNumber,
      DamagedItemsTable.cQatTypeId: damagedItem.qatTypeId,
      DamagedItemsTable.cQatTypeName: damagedItem.qatTypeName,
      DamagedItemsTable.cUnit: damagedItem.unit,
      DamagedItemsTable.cQuantity: damagedItem.quantity,
      DamagedItemsTable.cUnitCost: damagedItem.unitCost,
      DamagedItemsTable.cTotalCost: damagedItem.totalCost,
      DamagedItemsTable.cDamageReason: damagedItem.damageReason,
      DamagedItemsTable.cDamageType: damagedItem.damageType,
      DamagedItemsTable.cSeverityLevel: damagedItem.severityLevel,
      DamagedItemsTable.cNotes: damagedItem.notes,
      DamagedItemsTable.cActionTaken: damagedItem.actionTaken,
      DamagedItemsTable.cIsInsuranceCovered: damagedItem.isInsuranceCovered ? 1 : 0,
      DamagedItemsTable.cInsuranceAmount: damagedItem.insuranceAmount,
      DamagedItemsTable.cResponsiblePerson: damagedItem.responsiblePerson,
      DamagedItemsTable.cStatus: damagedItem.status,
      DamagedItemsTable.cWarehouseId: damagedItem.warehouseId,
      DamagedItemsTable.cWarehouseName: damagedItem.warehouseName,
      DamagedItemsTable.cBatchNumber: damagedItem.batchNumber,
      DamagedItemsTable.cExpiryDate: damagedItem.expiryDate,
      DamagedItemsTable.cDiscoveredBy: damagedItem.discoveredBy,
      DamagedItemsTable.cCreatedBy: damagedItem.createdBy,
      DamagedItemsTable.cCreatedAt: damagedItem.createdAt ?? DateTime.now().toIso8601String(),
      DamagedItemsTable.cUpdatedAt: damagedItem.updatedAt ?? DateTime.now().toIso8601String(),
      DamagedItemsTable.cSyncStatus: damagedItem.syncStatus ?? 'pending',
      DamagedItemsTable.cFirebaseId: damagedItem.firebaseId,
    };
  }
}
