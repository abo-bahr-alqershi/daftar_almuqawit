import 'package:sqflite/sqflite.dart';
import '../tables/inventory_table.dart';
import '../tables/inventory_transactions_table.dart';
import '../tables/returns_table.dart';
import '../tables/damaged_items_table.dart';

/// Migration لإضافة جداول المخزون والمردودات والتالف
class AddInventoryTablesMigration {
  static Future<void> migrate(Database db) async {
    // التحقق من وجود الجداول أولاً
    final tables = await _getExistingTables(db);
    
    final batch = db.batch();
    
    // إنشاء الجداول المفقودة
    if (!tables.contains('inventory')) {
      batch.execute(InventoryTable.create);
      print('إنشاء جدول المخزون...');
    }
    
    if (!tables.contains('inventory_transactions')) {
      batch.execute(InventoryTransactionsTable.create);
      print('إنشاء جدول حركات المخزون...');
    }
    
    if (!tables.contains('returns')) {
      batch.execute(ReturnsTable.create);
      print('إنشاء جدول المردودات...');
    }
    
    if (!tables.contains('damaged_items')) {
      batch.execute(DamagedItemsTable.create);
      print('إنشاء جدول البضاعة التالفة...');
    }
    
    await batch.commit(noResult: true);
    
    // إضافة الفهارس
    await _addIndexes(db, tables);
  }
  
  static Future<List<String>> _getExistingTables(Database db) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    return result.map((row) => row['name'] as String).toList();
  }
  
  static Future<void> _addIndexes(Database db, List<String> existingTables) async {
    final indexBatch = db.batch();
    
    if (!existingTables.contains('inventory')) {
      for (final index in InventoryTable.indexes) {
        indexBatch.execute(index);
      }
    }
    
    if (!existingTables.contains('inventory_transactions')) {
      for (final index in InventoryTransactionsTable.indexes) {
        indexBatch.execute(index);
      }
    }
    
    if (!existingTables.contains('returns')) {
      for (final index in ReturnsTable.indexes) {
        indexBatch.execute(index);
      }
    }
    
    if (!existingTables.contains('damaged_items')) {
      for (final index in DamagedItemsTable.indexes) {
        indexBatch.execute(index);
      }
    }
    
    await indexBatch.commit(noResult: true);
  }
}
