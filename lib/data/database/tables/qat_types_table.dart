// ignore_for_file: public_member_api_docs

/// تعريف جدول أنواع القات qat_types
class QatTypesTable {
  QatTypesTable._();
  static const String table = 'qat_types';

  static const String cId = 'id';
  static const String cName = 'name';
  static const String cQualityGrade = 'quality_grade';
  static const String cDefaultBuyPrice = 'default_buy_price';
  static const String cDefaultSellPrice = 'default_sell_price';
  static const String cColor = 'color';
  static const String cIcon = 'icon';

  static const String create = '''
CREATE TABLE $table (
  $cId INTEGER PRIMARY KEY AUTOINCREMENT,
  $cName TEXT NOT NULL,
  $cQualityGrade TEXT,
  $cDefaultBuyPrice REAL,
  $cDefaultSellPrice REAL,
  $cColor TEXT,
  $cIcon TEXT
);
''';
}
