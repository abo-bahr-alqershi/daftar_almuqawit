// ignore_for_file: public_member_api_docs

/// تعريف جدول الحسابات المالية accounts
class AccountsTable {
  AccountsTable._();
  static const String table = 'accounts';

  static const String cId = 'id';
  static const String cName = 'name';
  static const String cType = 'type';
  static const String cBalance = 'balance';
  static const String cIcon = 'icon';
  static const String cColor = 'color';

  static const String create = '''
CREATE TABLE $table (
  $cId INTEGER PRIMARY KEY AUTOINCREMENT,
  $cName TEXT NOT NULL,
  $cType TEXT NOT NULL,
  $cBalance REAL DEFAULT 0,
  $cIcon TEXT,
  $cColor TEXT
);
''';
}
