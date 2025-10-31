// ignore_for_file: public_member_api_docs

/// تعريف جدول المشتريات purchases
class PurchasesTable {
  PurchasesTable._();
  static const String table = 'purchases';

  static const String cId = 'id';
  static const String cDate = 'date';
  static const String cTime = 'time';
  static const String cSupplierId = 'supplier_id';
  static const String cQatTypeId = 'qat_type_id';
  static const String cQuantity = 'quantity';
  static const String cUnit = 'unit';
  static const String cUnitPrice = 'unit_price';
  static const String cTotalAmount = 'total_amount';
  static const String cPaymentStatus = 'payment_status';
  static const String cPaidAmount = 'paid_amount';
  static const String cRemainingAmount = 'remaining_amount';
  static const String cNotes = 'notes';

  static const String create = '''
CREATE TABLE $table (
  $cId INTEGER PRIMARY KEY AUTOINCREMENT,
  $cDate TEXT NOT NULL,
  $cTime TEXT NOT NULL,
  $cSupplierId INTEGER,
  $cQatTypeId INTEGER,
  $cQuantity REAL NOT NULL,
  $cUnit TEXT DEFAULT 'ربطة',
  $cUnitPrice REAL NOT NULL,
  $cTotalAmount REAL NOT NULL,
  $cPaymentStatus TEXT DEFAULT 'نقد',
  $cPaidAmount REAL DEFAULT 0,
  $cRemainingAmount REAL DEFAULT 0,
  $cNotes TEXT,
  FOREIGN KEY ($cSupplierId) REFERENCES suppliers(id),
  FOREIGN KEY ($cQatTypeId) REFERENCES qat_types(id)
);
''';
}
