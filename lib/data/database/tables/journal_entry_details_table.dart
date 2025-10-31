// ignore_for_file: public_member_api_docs

/// تعريف جدول تفاصيل قيود اليومية journal_entry_details
class JournalEntryDetailsTable {
  JournalEntryDetailsTable._();
  static const String table = 'journal_entry_details';

  static const String cId = 'id';
  static const String cEntryId = 'entry_id';
  static const String cAccountId = 'account_id';
  static const String cDebit = 'debit';
  static const String cCredit = 'credit';

  static const String create = '''
CREATE TABLE $table (
  $cId INTEGER PRIMARY KEY AUTOINCREMENT,
  $cEntryId INTEGER NOT NULL,
  $cAccountId INTEGER NOT NULL,
  $cDebit REAL DEFAULT 0,
  $cCredit REAL DEFAULT 0,
  FOREIGN KEY ($cEntryId) REFERENCES journal_entries(id),
  FOREIGN KEY ($cAccountId) REFERENCES accounts(id)
);
''';
}
