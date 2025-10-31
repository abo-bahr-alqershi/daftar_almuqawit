// ignore_for_file: public_member_api_docs

/// تعريف جدول الديون debts
class DebtsTable {
  DebtsTable._();
  static const String table = 'debts';

  static const String cId = 'id';
  static const String cPersonType = 'person_type';
  static const String cPersonId = 'person_id';
  static const String cPersonName = 'person_name';
  static const String cTransactionType = 'transaction_type';
  static const String cTransactionId = 'transaction_id';
  static const String cOriginalAmount = 'original_amount';
  static const String cPaidAmount = 'paid_amount';
  static const String cRemainingAmount = 'remaining_amount';
  static const String cDate = 'date';
  static const String cDueDate = 'due_date';
  static const String cStatus = 'status';
  static const String cLastPaymentDate = 'last_payment_date';
  static const String cNotes = 'notes';

  static const String create = '''
CREATE TABLE $table (
  $cId INTEGER PRIMARY KEY AUTOINCREMENT,
  $cPersonType TEXT NOT NULL,
  $cPersonId INTEGER NOT NULL,
  $cPersonName TEXT NOT NULL,
  $cTransactionType TEXT,
  $cTransactionId INTEGER,
  $cOriginalAmount REAL NOT NULL,
  $cPaidAmount REAL DEFAULT 0,
  $cRemainingAmount REAL NOT NULL,
  $cDate TEXT NOT NULL,
  $cDueDate TEXT,
  $cStatus TEXT DEFAULT 'غير مسدد',
  $cLastPaymentDate TEXT,
  $cNotes TEXT
);
''';
}
