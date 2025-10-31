// ignore_for_file: public_member_api_docs

/// تعريف جدول المصروفات expenses
class ExpensesTable {
  ExpensesTable._();
  static const String table = 'expenses';

  static const String cId = 'id';
  static const String cDate = 'date';
  static const String cTime = 'time';
  static const String cCategory = 'category';
  static const String cAmount = 'amount';
  static const String cDescription = 'description';
  static const String cPaymentMethod = 'payment_method';
  static const String cRecurring = 'recurring';
  static const String cNotes = 'notes';

  static const String create = '''
CREATE TABLE $table (
  $cId INTEGER PRIMARY KEY AUTOINCREMENT,
  $cDate TEXT NOT NULL,
  $cTime TEXT NOT NULL,
  $cCategory TEXT NOT NULL,
  $cAmount REAL NOT NULL,
  $cDescription TEXT,
  $cPaymentMethod TEXT DEFAULT 'نقد',
  $cRecurring INTEGER DEFAULT 0,
  $cNotes TEXT
);
''';
}
