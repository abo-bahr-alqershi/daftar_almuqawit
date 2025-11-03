import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'database_config.dart';
import 'tables/suppliers_table.dart';
import 'tables/customers_table.dart';
import 'tables/qat_types_table.dart';
import 'tables/purchases_table.dart';
import 'tables/sales_table.dart';
import 'tables/debts_table.dart';
import 'tables/debt_payments_table.dart';
import 'tables/accounts_table.dart';
import 'tables/journal_entries_table.dart';
import 'tables/journal_entry_details_table.dart';
import 'tables/expenses_table.dart';
import 'tables/daily_stats_table.dart';
import 'tables/sync_queue_table.dart';
import 'tables/metadata_table.dart';
import 'migrations/migration_manager.dart';

/// مساعد إدارة قاعدة البيانات المحلية
/// 
/// مسؤول عن إنشاء وترقية وإدارة قاعدة البيانات
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;
  bool _isInitialized = false;

  /// الحصول على مرجع قاعدة البيانات المفتوحة
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  /// التحقق من حالة التهيئة
  bool get isInitialized => _isInitialized;

  /// تهيئة القاعدة قبل تشغيل التطبيق
  static Future<void> init() async {
    await instance.database;
    instance._isInitialized = true;
  }

  Future<Database> _open() async {
    final path = await DatabaseConfig.databasePath;
    return openDatabase(
      path,
      version: DatabaseConfig.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// تفعيل المفاتيح الأجنبية
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    // إنشاء جميع الجداول وفق المخطط
    final batch = db.batch();
    batch.execute(SuppliersTable.create);
    batch.execute(CustomersTable.create);
    batch.execute(QatTypesTable.create);
    batch.execute(PurchasesTable.create);
    batch.execute(SalesTable.create);
    batch.execute(DebtsTable.create);
    batch.execute(DebtPaymentsTable.create);
    batch.execute(AccountsTable.create);
    batch.execute(JournalEntriesTable.create);
    batch.execute(JournalEntryDetailsTable.create);
    batch.execute(ExpensesTable.create);
    batch.execute(DailyStatsTable.create);
    batch.execute(SyncQueueTable.create);
    batch.execute(MetadataTable.create);
    await batch.commit(noResult: true);
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await MigrationManager.upgrade(db, oldVersion, newVersion);
  }

  // ========== عمليات النسخ الاحتياطي ==========

  /// إنشاء نسخة احتياطية
  Future<File> createBackup(String backupPath) async {
    final db = await database;
    await db.close();
    
    final dbPath = await DatabaseConfig.databasePath;
    final dbFile = File(dbPath);
    final backupFile = await dbFile.copy(backupPath);
    
    // إعادة فتح القاعدة
    _db = await _open();
    
    return backupFile;
  }

  /// استعادة نسخة احتياطية
  Future<void> restoreBackup(String backupPath) async {
    await close();
    
    final dbPath = await DatabaseConfig.databasePath;
    final backupFile = File(backupPath);
    await backupFile.copy(dbPath);
    
    _db = await _open();
  }

  /// حذف قاعدة البيانات
  Future<void> deleteDatabase() async {
    await close();
    final dbPath = await DatabaseConfig.databasePath;
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  }

  // ========== عمليات المعاملات ==========

  /// تنفيذ معاملة
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return db.transaction(action);
  }

  /// تنفيذ دفعة من العمليات
  Future<List<Object?>> batch(void Function(Batch batch) operations) async {
    final db = await database;
    final batch = db.batch();
    operations(batch);
    return batch.commit();
  }

  // ========== معلومات القاعدة ==========

  /// الحصول على حجم قاعدة البيانات
  Future<int> getDatabaseSize() async {
    final dbPath = await DatabaseConfig.databasePath;
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      return dbFile.length();
    }
    return 0;
  }

  /// الحصول على إصدار قاعدة البيانات
  Future<int> getDatabaseVersion() async {
    final db = await database;
    return db.getVersion();
  }

  /// إغلاق قاعدة البيانات
  Future<void> close() async {
    final db = _db;
    if (db != null && db.isOpen) {
      await db.close();
      _db = null;
      _isInitialized = false;
    }
  }
}
