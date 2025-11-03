// ignore_for_file: public_member_api_docs

import '../../database/tables/journal_entries_table.dart';
import '../../database/tables/journal_entry_details_table.dart';
import '../../models/journal_entry_model.dart';
import '../../models/journal_entry_detail_model.dart';
import 'base_local_datasource.dart';

/// مصدر بيانات محلي للمحاسبة (قيود اليومية وتفاصيلها)
class AccountingLocalDataSource extends BaseLocalDataSource<JournalEntryModel> {
  AccountingLocalDataSource(super.dbHelper);

  @override
  String get tableName => JournalEntriesTable.table;

  @override
  JournalEntryModel fromMap(Map<String, dynamic> map) => JournalEntryModel.fromMap(map);

  Future<int> insertEntry(JournalEntryModel model) async {
    final database = await db;
    return database.insert(JournalEntriesTable.table, model.toMap());
  }

  Future<int> insertDetail(JournalEntryDetailModel model) async {
    final database = await db;
    return database.insert(JournalEntryDetailsTable.table, model.toMap());
  }

  Future<List<JournalEntryDetailModel>> getDetails(int entryId) async {
    final database = await db;
    final rows = await database.query(
      JournalEntryDetailsTable.table,
      where: '${JournalEntryDetailsTable.cEntryId} = ?',
      whereArgs: [entryId],
    );
    return rows.map((e) => JournalEntryDetailModel.fromMap(e)).toList();
  }

  Future<double> getCashBalance() async {
    // مبدئيًا: قراءة رصيد الصندوق من جدول الإحصائيات اليومية إن وجد آخر سطر
    final database = await db;
    final rows = await database.rawQuery(
        'SELECT cash_balance FROM daily_stats ORDER BY date DESC LIMIT 1');
    if (rows.isEmpty) return 0;
    final v = rows.first['cash_balance'] as num?;
    return (v ?? 0).toDouble();
  }
}
