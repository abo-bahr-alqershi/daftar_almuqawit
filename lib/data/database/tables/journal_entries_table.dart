// ignore_for_file: public_member_api_docs

/// تعريف جدول قيود اليومية journal_entries
class JournalEntriesTable {
  JournalEntriesTable._();
  static const String table = 'journal_entries';

  static const String cId = 'id';
  static const String cDate = 'date';
  static const String cTime = 'time';
  static const String cDescription = 'description';
  static const String cReferenceType = 'reference_type';
  static const String cReferenceId = 'reference_id';
  static const String cTotalAmount = 'total_amount';

  static const String create = '''
CREATE TABLE $table (
  $cId INTEGER PRIMARY KEY AUTOINCREMENT,
  $cDate TEXT NOT NULL,
  $cTime TEXT NOT NULL,
  $cDescription TEXT NOT NULL,
  $cReferenceType TEXT,
  $cReferenceId INTEGER,
  $cTotalAmount REAL NOT NULL
);
''';
}
