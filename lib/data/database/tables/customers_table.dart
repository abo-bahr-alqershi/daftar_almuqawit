// ignore_for_file: public_member_api_docs

/// تعريف جدول العملاء customers
class CustomersTable {
  CustomersTable._();
  static const String table = 'customers';

  static const String cId = 'id';
  static const String cName = 'name';
  static const String cPhone = 'phone';
  static const String cNickname = 'nickname';
  static const String cCustomerType = 'customer_type';
  static const String cCreditLimit = 'credit_limit';
  static const String cTotalPurchases = 'total_purchases';
  static const String cCurrentDebt = 'current_debt';
  static const String cIsBlocked = 'is_blocked';
  static const String cNotes = 'notes';
  static const String cCreatedAt = 'created_at';

  static const String create = '''
CREATE TABLE $table (
  $cId INTEGER PRIMARY KEY AUTOINCREMENT,
  $cName TEXT NOT NULL,
  $cPhone TEXT,
  $cNickname TEXT,
  $cCustomerType TEXT DEFAULT 'عادي',
  $cCreditLimit REAL DEFAULT 0,
  $cTotalPurchases REAL DEFAULT 0,
  $cCurrentDebt REAL DEFAULT 0,
  $cIsBlocked INTEGER DEFAULT 0,
  $cNotes TEXT,
  $cCreatedAt TEXT DEFAULT CURRENT_TIMESTAMP
);
''';
}
