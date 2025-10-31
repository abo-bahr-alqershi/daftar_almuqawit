// ignore_for_file: public_member_api_docs

/// تعريف جدول الإحصائيات اليومية daily_stats
class DailyStatsTable {
  DailyStatsTable._();
  static const String table = 'daily_stats';

  static const String cId = 'id';
  static const String cDate = 'date';
  static const String cTotalPurchases = 'total_purchases';
  static const String cTotalSales = 'total_sales';
  static const String cTotalExpenses = 'total_expenses';
  static const String cCashSales = 'cash_sales';
  static const String cCreditSales = 'credit_sales';
  static const String cGrossProfit = 'gross_profit';
  static const String cNetProfit = 'net_profit';
  static const String cNewDebts = 'new_debts';
  static const String cCollectedDebts = 'collected_debts';
  static const String cCashBalance = 'cash_balance';

  static const String create = '''
CREATE TABLE $table (
  $cId INTEGER PRIMARY KEY AUTOINCREMENT,
  $cDate TEXT NOT NULL UNIQUE,
  $cTotalPurchases REAL DEFAULT 0,
  $cTotalSales REAL DEFAULT 0,
  $cTotalExpenses REAL DEFAULT 0,
  $cCashSales REAL DEFAULT 0,
  $cCreditSales REAL DEFAULT 0,
  $cGrossProfit REAL DEFAULT 0,
  $cNetProfit REAL DEFAULT 0,
  $cNewDebts REAL DEFAULT 0,
  $cCollectedDebts REAL DEFAULT 0,
  $cCashBalance REAL DEFAULT 0
);
''';
}
