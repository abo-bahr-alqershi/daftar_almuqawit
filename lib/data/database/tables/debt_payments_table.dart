// ignore_for_file: public_member_api_docs

/// تعريف جدول سداد الديون debt_payments
class DebtPaymentsTable {
  DebtPaymentsTable._();
  static const String table = 'debt_payments';

  static const String cId = 'id';
  static const String cDebtId = 'debt_id';
  static const String cAmount = 'amount';
  static const String cPaymentDate = 'payment_date';
  static const String cPaymentTime = 'payment_time';
  static const String cPaymentMethod = 'payment_method';
  static const String cNotes = 'notes';

  static const String create = '''
CREATE TABLE $table (
  $cId INTEGER PRIMARY KEY AUTOINCREMENT,
  $cDebtId INTEGER NOT NULL,
  $cAmount REAL NOT NULL,
  $cPaymentDate TEXT NOT NULL,
  $cPaymentTime TEXT NOT NULL,
  $cPaymentMethod TEXT DEFAULT 'نقد',
  $cNotes TEXT,
  FOREIGN KEY ($cDebtId) REFERENCES debts(id)
);
''';
}
