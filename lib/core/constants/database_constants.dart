// ignore_for_file: public_member_api_docs

/// ثوابت قاعدة البيانات SQLite
class DatabaseConstants {
  DatabaseConstants._();

  static const String dbName = 'daftar_almuqawit.db';
  static const int dbVersion = 1;

  // أسماء الجداول
  static const String suppliers = 'suppliers';
  static const String customers = 'customers';
  static const String qatTypes = 'qat_types';
  static const String purchases = 'purchases';
  static const String sales = 'sales';
  static const String debts = 'debts';
  static const String debtPayments = 'debt_payments';
  static const String accounts = 'accounts';
  static const String journalEntries = 'journal_entries';
  static const String journalEntryDetails = 'journal_entry_details';
  static const String expenses = 'expenses';
  static const String dailyStats = 'daily_stats';
  static const String syncQueue = 'sync_queue';
  static const String metadata = 'metadata';
}
