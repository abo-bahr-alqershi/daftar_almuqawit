import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/inventory.dart';
import '../../../domain/entities/inventory_transaction.dart';
import '../../database/database_helper.dart';
import '../../database/tables/inventory_table.dart';
import '../../database/tables/inventory_transactions_table.dart';

/// مصدر البيانات المحلي للمخزون
class InventoryLocalDataSource {
  final DatabaseHelper _databaseHelper;

  InventoryLocalDataSource(this._databaseHelper);

  // ================= عمليات المخزون الأساسية =================

  /// الحصول على جميع عناصر المخزون
  Future<List<Inventory>> getAllInventory() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      InventoryTable.table,
      orderBy: '${InventoryTable.cQatTypeName}, ${InventoryTable.cUnit}',
    );

    return maps.map((map) => _mapToInventory(map)).toList();
  }

  /// الحصول على عنصر مخزون بالمعرف
  Future<Inventory?> getInventoryById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      InventoryTable.table,
      where: '${InventoryTable.cId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToInventory(maps.first);
  }

  /// الحصول على عنصر مخزون بنوع القات والوحدة
  Future<Inventory?> getInventoryByQatType(int qatTypeId, String unit, {int warehouseId = 1}) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      InventoryTable.table,
      where: '${InventoryTable.cQatTypeId} = ? AND ${InventoryTable.cUnit} = ? AND ${InventoryTable.cWarehouseId} = ?',
      whereArgs: [qatTypeId, unit, warehouseId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToInventory(maps.first);
  }

  /// الحصول على مخزون مخزن معين
  Future<List<Inventory>> getInventoryByWarehouse(int warehouseId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      InventoryTable.table,
      where: '${InventoryTable.cWarehouseId} = ?',
      whereArgs: [warehouseId],
      orderBy: '${InventoryTable.cQatTypeName}, ${InventoryTable.cUnit}',
    );

    return maps.map((map) => _mapToInventory(map)).toList();
  }

  /// الحصول على المخزون المنخفض
  Future<List<Inventory>> getLowStockInventory() async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT * FROM ${InventoryTable.table}
      WHERE ${InventoryTable.cCurrentQuantity} <= ${InventoryTable.cMinimumQuantity}
      AND ${InventoryTable.cMinimumQuantity} > 0
      ORDER BY ${InventoryTable.cQatTypeName}, ${InventoryTable.cUnit}
    ''');

    return maps.map((map) => _mapToInventory(map)).toList();
  }

  /// الحصول على المخزون الزائد
  Future<List<Inventory>> getOverStockInventory() async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT * FROM ${InventoryTable.table}
      WHERE ${InventoryTable.cCurrentQuantity} >= ${InventoryTable.cMaximumQuantity}
      AND ${InventoryTable.cMaximumQuantity} > 0
      ORDER BY ${InventoryTable.cQatTypeName}, ${InventoryTable.cUnit}
    ''');

    return maps.map((map) => _mapToInventory(map)).toList();
  }

  /// البحث في المخزون
  Future<List<Inventory>> searchInventory(String query) async {
    final db = await _databaseHelper.database;
    final searchQuery = '%$query%';
    final maps = await db.query(
      InventoryTable.table,
      where: '${InventoryTable.cQatTypeName} LIKE ? OR ${InventoryTable.cUnit} LIKE ? OR ${InventoryTable.cNotes} LIKE ?',
      whereArgs: [searchQuery, searchQuery, searchQuery],
      orderBy: '${InventoryTable.cQatTypeName}, ${InventoryTable.cUnit}',
    );

    return maps.map((map) => _mapToInventory(map)).toList();
  }

  // ================= عمليات تحديث المخزون =================

  /// إضافة عنصر مخزون جديد
  Future<bool> addInventoryItem(Inventory inventory) async {
    final db = await _databaseHelper.database;
    try {
      await db.insert(
        InventoryTable.table,
        _inventoryToMap(inventory),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print('Error adding inventory item: $e');
      return false;
    }
  }

  /// تحديث عنصر مخزون
  Future<bool> updateInventory(Inventory inventory) async {
    final db = await _databaseHelper.database;
    try {
      final count = await db.update(
        InventoryTable.table,
        _inventoryToMap(inventory),
        where: '${InventoryTable.cId} = ?',
        whereArgs: [inventory.id],
      );
      return count > 0;
    } catch (e) {
      print('Error updating inventory: $e');
      return false;
    }
  }

  /// حذف عنصر من المخزون
  Future<bool> removeInventoryItem(int id) async {
    final db = await _databaseHelper.database;
    try {
      final count = await db.delete(
        InventoryTable.table,
        where: '${InventoryTable.cId} = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      print('Error removing inventory item: $e');
      return false;
    }
  }

  /// تعديل كمية المخزون مع إضافة حركة
  Future<bool> adjustInventoryQuantity(int qatTypeId, String unit, double newQuantity, String reason, {int warehouseId = 1}) async {
    final db = await _databaseHelper.database;
    
    return await db.transaction((txn) async {
      try {
        // الحصول على الكمية الحالية
        final current = await getInventoryByQatType(qatTypeId, unit, warehouseId: warehouseId);
        final currentQuantity = current?.currentQuantity ?? 0;
        final quantityChange = newQuantity - currentQuantity;

        // تحديث المخزون أو إضافته إذا لم يكن موجوداً
        if (current != null) {
          final updatedInventory = current.copyWith(
            currentQuantity: newQuantity,
            availableQuantity: newQuantity - (current.reservedQuantity),
            updatedAt: DateTime.now().toIso8601String(),
          );
          
          await txn.update(
            InventoryTable.table,
            _inventoryToMap(updatedInventory),
            where: '${InventoryTable.cId} = ?',
            whereArgs: [current.id],
          );
        } else {
          // إنشاء عنصر مخزون جديد
          final newInventory = Inventory(
            qatTypeId: qatTypeId,
            unit: unit,
            warehouseId: warehouseId,
            currentQuantity: newQuantity,
            availableQuantity: newQuantity,
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          );
          
          await txn.insert(
            InventoryTable.table,
            _inventoryToMap(newInventory),
          );
        }

        // إضافة حركة المخزون
        final transaction = InventoryTransaction(
          transactionDate: DateTime.now().toIso8601String().split('T')[0],
          transactionTime: DateTime.now().toIso8601String().split('T')[1].split('.')[0],
          transactionType: 'تعديل',
          transactionNumber: 'ADJ-${DateTime.now().millisecondsSinceEpoch}',
          qatTypeId: qatTypeId,
          qatTypeName: current?.qatTypeName ?? '',
          unit: unit,
          warehouseId: warehouseId,
          warehouseName: current?.warehouseName ?? 'المخزن الرئيسي',
          quantityBefore: currentQuantity,
          quantityChange: quantityChange,
          quantityAfter: newQuantity,
          reason: reason,
          createdAt: DateTime.now().toIso8601String(),
        );

        await txn.insert(
          InventoryTransactionsTable.table,
          _transactionToMap(transaction),
        );

        return true;
      } catch (e) {
        print('Error adjusting inventory quantity: $e');
        return false;
      }
    });
  }

  // ================= عمليات حركات المخزون =================

  /// الحصول على جميع حركات المخزون
  Future<List<InventoryTransaction>> getAllTransactions() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      InventoryTransactionsTable.table,
      orderBy: '${InventoryTransactionsTable.cTransactionDate} DESC, ${InventoryTransactionsTable.cTransactionTime} DESC',
    );

    return maps.map((map) => _mapToTransaction(map)).toList();
  }

  /// الحصول على حركات نوع قات معين
  Future<List<InventoryTransaction>> getTransactionsByQatType(int qatTypeId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      InventoryTransactionsTable.table,
      where: '${InventoryTransactionsTable.cQatTypeId} = ?',
      whereArgs: [qatTypeId],
      orderBy: '${InventoryTransactionsTable.cTransactionDate} DESC, ${InventoryTransactionsTable.cTransactionTime} DESC',
    );

    return maps.map((map) => _mapToTransaction(map)).toList();
  }

  /// الحصول على حركات في فترة زمنية
  Future<List<InventoryTransaction>> getTransactionsByDateRange(String startDate, String endDate) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      InventoryTransactionsTable.table,
      where: '${InventoryTransactionsTable.cTransactionDate} BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: '${InventoryTransactionsTable.cTransactionDate} DESC, ${InventoryTransactionsTable.cTransactionTime} DESC',
    );

    return maps.map((map) => _mapToTransaction(map)).toList();
  }

  /// الحصول على حركات بنوع معين
  Future<List<InventoryTransaction>> getTransactionsByType(String transactionType) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      InventoryTransactionsTable.table,
      where: '${InventoryTransactionsTable.cTransactionType} = ?',
      whereArgs: [transactionType],
      orderBy: '${InventoryTransactionsTable.cTransactionDate} DESC, ${InventoryTransactionsTable.cTransactionTime} DESC',
    );

    return maps.map((map) => _mapToTransaction(map)).toList();
  }

  /// إضافة حركة مخزون
  Future<bool> addTransaction(InventoryTransaction transaction) async {
    final db = await _databaseHelper.database;
    try {
      await db.insert(
        InventoryTransactionsTable.table,
        _transactionToMap(transaction),
      );
      return true;
    } catch (e) {
      print('Error adding inventory transaction: $e');
      return false;
    }
  }

  // ================= عمليات متقدمة =================

  /// الحصول على الكمية المتاحة لنوع قات ووحدة
  Future<double> getAvailableQuantity(int qatTypeId, String unit, {int warehouseId = 1}) async {
    final inventory = await getInventoryByQatType(qatTypeId, unit, warehouseId: warehouseId);
    return inventory?.availableQuantity ?? 0;
  }

  /// الحصول على ملخص المخزون
  Future<Map<String, double>> getStockSummary() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(${InventoryTable.cCurrentQuantity}) as totalQuantity,
        COUNT(*) as totalItems,
        SUM(CASE WHEN ${InventoryTable.cCurrentQuantity} <= ${InventoryTable.cMinimumQuantity} THEN 1 ELSE 0 END) as lowStockItems,
        SUM(CASE WHEN ${InventoryTable.cCurrentQuantity} >= ${InventoryTable.cMaximumQuantity} AND ${InventoryTable.cMaximumQuantity} > 0 THEN 1 ELSE 0 END) as overStockItems
      FROM ${InventoryTable.table}
    ''');

    final map = result.first;
    return {
      'totalQuantity': (map['totalQuantity'] as num?)?.toDouble() ?? 0,
      'totalItems': (map['totalItems'] as num?)?.toDouble() ?? 0,
      'lowStockItems': (map['lowStockItems'] as num?)?.toDouble() ?? 0,
      'overStockItems': (map['overStockItems'] as num?)?.toDouble() ?? 0,
    };
  }

  // ================= Helper Methods =================

  /// تحويل Map إلى Inventory
  Inventory _mapToInventory(Map<String, dynamic> map) {
    return Inventory(
      id: map[InventoryTable.cId],
      qatTypeId: map[InventoryTable.cQatTypeId],
      qatTypeName: map[InventoryTable.cQatTypeName],
      unit: map[InventoryTable.cUnit],
      warehouseId: map[InventoryTable.cWarehouseId] ?? 1,
      warehouseName: map[InventoryTable.cWarehouseName] ?? 'المخزن الرئيسي',
      currentQuantity: (map[InventoryTable.cCurrentQuantity] as num).toDouble(),
      reservedQuantity: (map[InventoryTable.cReservedQuantity] as num?)?.toDouble() ?? 0,
      availableQuantity: (map[InventoryTable.cAvailableQuantity] as num).toDouble(),
      minimumQuantity: (map[InventoryTable.cMinimumQuantity] as num?)?.toDouble() ?? 0,
      maximumQuantity: (map[InventoryTable.cMaximumQuantity] as num?)?.toDouble(),
      lastPurchaseDate: map[InventoryTable.cLastPurchaseDate],
      lastSaleDate: map[InventoryTable.cLastSaleDate],
      averageCost: (map[InventoryTable.cAverageCost] as num?)?.toDouble(),
      notes: map[InventoryTable.cNotes],
      createdAt: map[InventoryTable.cCreatedAt],
      updatedAt: map[InventoryTable.cUpdatedAt],
      lastUpdatedBy: map[InventoryTable.cLastUpdatedBy],
    );
  }

  /// تحويل Inventory إلى Map
  Map<String, dynamic> _inventoryToMap(Inventory inventory) {
    return {
      if (inventory.id != null) InventoryTable.cId: inventory.id,
      InventoryTable.cQatTypeId: inventory.qatTypeId,
      InventoryTable.cQatTypeName: inventory.qatTypeName,
      InventoryTable.cUnit: inventory.unit,
      InventoryTable.cWarehouseId: inventory.warehouseId,
      InventoryTable.cWarehouseName: inventory.warehouseName,
      InventoryTable.cCurrentQuantity: inventory.currentQuantity,
      InventoryTable.cReservedQuantity: inventory.reservedQuantity,
      InventoryTable.cAvailableQuantity: inventory.availableQuantity,
      InventoryTable.cMinimumQuantity: inventory.minimumQuantity,
      InventoryTable.cMaximumQuantity: inventory.maximumQuantity,
      InventoryTable.cLastPurchaseDate: inventory.lastPurchaseDate,
      InventoryTable.cLastSaleDate: inventory.lastSaleDate,
      InventoryTable.cAverageCost: inventory.averageCost,
      InventoryTable.cNotes: inventory.notes,
      InventoryTable.cCreatedAt: inventory.createdAt ?? DateTime.now().toIso8601String(),
      InventoryTable.cUpdatedAt: inventory.updatedAt ?? DateTime.now().toIso8601String(),
      InventoryTable.cLastUpdatedBy: inventory.lastUpdatedBy,
    };
  }

  /// تحويل Map إلى InventoryTransaction
  InventoryTransaction _mapToTransaction(Map<String, dynamic> map) {
    return InventoryTransaction(
      id: map[InventoryTransactionsTable.cId],
      transactionDate: map[InventoryTransactionsTable.cTransactionDate],
      transactionTime: map[InventoryTransactionsTable.cTransactionTime],
      transactionType: map[InventoryTransactionsTable.cTransactionType],
      transactionNumber: map[InventoryTransactionsTable.cTransactionNumber],
      qatTypeId: map[InventoryTransactionsTable.cQatTypeId],
      qatTypeName: map[InventoryTransactionsTable.cQatTypeName],
      unit: map[InventoryTransactionsTable.cUnit],
      warehouseId: map[InventoryTransactionsTable.cWarehouseId] ?? 1,
      warehouseName: map[InventoryTransactionsTable.cWarehouseName] ?? 'المخزن الرئيسي',
      quantityBefore: (map[InventoryTransactionsTable.cQuantityBefore] as num).toDouble(),
      quantityChange: (map[InventoryTransactionsTable.cQuantityChange] as num).toDouble(),
      quantityAfter: (map[InventoryTransactionsTable.cQuantityAfter] as num).toDouble(),
      unitCost: (map[InventoryTransactionsTable.cUnitCost] as num?)?.toDouble(),
      totalCost: (map[InventoryTransactionsTable.cTotalCost] as num?)?.toDouble(),
      referenceType: map[InventoryTransactionsTable.cReferenceType],
      referenceId: map[InventoryTransactionsTable.cReferenceId],
      referencePerson: map[InventoryTransactionsTable.cReferencePerson],
      reason: map[InventoryTransactionsTable.cReason],
      notes: map[InventoryTransactionsTable.cNotes],
      status: map[InventoryTransactionsTable.cStatus] ?? 'مؤكد',
      createdBy: map[InventoryTransactionsTable.cCreatedBy],
      createdAt: map[InventoryTransactionsTable.cCreatedAt],
      updatedAt: map[InventoryTransactionsTable.cUpdatedAt],
    );
  }

  /// تحويل InventoryTransaction إلى Map
  Map<String, dynamic> _transactionToMap(InventoryTransaction transaction) {
    return {
      if (transaction.id != null) InventoryTransactionsTable.cId: transaction.id,
      InventoryTransactionsTable.cTransactionDate: transaction.transactionDate,
      InventoryTransactionsTable.cTransactionTime: transaction.transactionTime,
      InventoryTransactionsTable.cTransactionType: transaction.transactionType,
      InventoryTransactionsTable.cTransactionNumber: transaction.transactionNumber,
      InventoryTransactionsTable.cQatTypeId: transaction.qatTypeId,
      InventoryTransactionsTable.cQatTypeName: transaction.qatTypeName,
      InventoryTransactionsTable.cUnit: transaction.unit,
      InventoryTransactionsTable.cWarehouseId: transaction.warehouseId,
      InventoryTransactionsTable.cWarehouseName: transaction.warehouseName,
      InventoryTransactionsTable.cQuantityBefore: transaction.quantityBefore,
      InventoryTransactionsTable.cQuantityChange: transaction.quantityChange,
      InventoryTransactionsTable.cQuantityAfter: transaction.quantityAfter,
      InventoryTransactionsTable.cUnitCost: transaction.unitCost,
      InventoryTransactionsTable.cTotalCost: transaction.totalCost,
      InventoryTransactionsTable.cReferenceType: transaction.referenceType,
      InventoryTransactionsTable.cReferenceId: transaction.referenceId,
      InventoryTransactionsTable.cReferencePerson: transaction.referencePerson,
      InventoryTransactionsTable.cReason: transaction.reason,
      InventoryTransactionsTable.cNotes: transaction.notes,
      InventoryTransactionsTable.cStatus: transaction.status,
      InventoryTransactionsTable.cCreatedBy: transaction.createdBy,
      InventoryTransactionsTable.cCreatedAt: transaction.createdAt ?? DateTime.now().toIso8601String(),
      InventoryTransactionsTable.cUpdatedAt: transaction.updatedAt ?? DateTime.now().toIso8601String(),
    };
  }
}
