// ignore_for_file: public_member_api_docs

/// تعريف جدول الموردين suppliers
class SuppliersTable {
  SuppliersTable._();
  static const String table = 'suppliers';

  // الأعمدة
  static const String cId = 'id';
  static const String cName = 'name';
  static const String cPhone = 'phone';
  static const String cArea = 'area';
  static const String cQualityRating = 'quality_rating';
  static const String cTrustLevel = 'trust_level';
  static const String cTotalPurchases = 'total_purchases';
  static const String cTotalDebtToHim = 'total_debt_to_him';
  static const String cNotes = 'notes';
  static const String cCreatedAt = 'created_at';

  /// جملة إنشاء الجدول
  static const String create = '''
CREATE TABLE $table (
  $cId INTEGER PRIMARY KEY AUTOINCREMENT,
  $cName TEXT NOT NULL,
  $cPhone TEXT,
  $cArea TEXT,
  $cQualityRating INTEGER DEFAULT 3,
  $cTrustLevel TEXT DEFAULT 'جديد',
  $cTotalPurchases REAL DEFAULT 0,
  $cTotalDebtToHim REAL DEFAULT 0,
  $cNotes TEXT,
  $cCreatedAt TEXT DEFAULT CURRENT_TIMESTAMP
);
''';
}
