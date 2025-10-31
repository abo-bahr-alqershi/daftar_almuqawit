// ignore_for_file: public_member_api_docs

import 'dart:async';
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

/// مساعد إدارة قاعدة البيانات
/// مسؤول عن إنشاء الجداول وترقية الإصدارات
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;

  /// الحصول على مرجع قاعدة البيانات المفتوحة
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  /// تهيئة القاعدة قبل تشغيل التطبيق
  static Future<void> init() async {
    await instance.database;
  }

  Future<Database> _open() async {
    final path = await DatabaseConfig.databasePath;
    return openDatabase(
      path,
      version: DatabaseConfig.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
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

  Future<void> close() async {
    final db = _db;
    if (db != null && db.isOpen) {
      await db.close();
      _db = null;
    }
  }
}
