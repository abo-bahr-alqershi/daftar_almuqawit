/// جدول المردودات (returns)
/// 
/// يسجل جميع عمليات المردود سواء من العملاء أو للموردين
class ReturnsTable {
  ReturnsTable._();
  
  static const String table = 'returns';

  // الأعمدة الأساسية
  static const String cId = 'id';
  static const String cReturnDate = 'return_date';
  static const String cReturnTime = 'return_time';
  static const String cReturnType = 'return_type'; // مردود_مبيعات، مردود_مشتريات
  static const String cReturnNumber = 'return_number';
  
  // معلومات الأشخاص المرتبطين
  static const String cCustomerId = 'customer_id';
  static const String cCustomerName = 'customer_name';
  static const String cSupplierId = 'supplier_id';
  static const String cSupplierName = 'supplier_name';
  
  // معلومات المنتج
  static const String cQatTypeId = 'qat_type_id';
  static const String cQatTypeName = 'qat_type_name';
  static const String cUnit = 'unit';
  static const String cQuantity = 'quantity';
  static const String cUnitPrice = 'unit_price';
  static const String cTotalAmount = 'total_amount';
  
  // تفاصيل المردود
  static const String cReturnReason = 'return_reason';
  static const String cNotes = 'notes';
  static const String cStatus = 'status'; // معلق، مؤكد، ملغي
  
  // ربط بالعمليات الأصلية
  static const String cOriginalSaleId = 'original_sale_id';
  static const String cOriginalPurchaseId = 'original_purchase_id';
  static const String cOriginalInvoiceNumber = 'original_invoice_number';
  
  // معلومات التتبع
  static const String cCreatedBy = 'created_by';
  static const String cCreatedAt = 'created_at';
  static const String cUpdatedAt = 'updated_at';
  static const String cSyncStatus = 'sync_status';
  static const String cFirebaseId = 'firebase_id';

  static const String create = '''
    CREATE TABLE $table (
      $cId INTEGER PRIMARY KEY AUTOINCREMENT,
      $cReturnDate TEXT NOT NULL,
      $cReturnTime TEXT NOT NULL,
      $cReturnType TEXT NOT NULL,
      $cReturnNumber TEXT NOT NULL UNIQUE,
      $cCustomerId INTEGER,
      $cCustomerName TEXT,
      $cSupplierId INTEGER,
      $cSupplierName TEXT,
      $cQatTypeId INTEGER NOT NULL,
      $cQatTypeName TEXT NOT NULL,
      $cUnit TEXT NOT NULL,
      $cQuantity REAL NOT NULL,
      $cUnitPrice REAL NOT NULL,
      $cTotalAmount REAL NOT NULL,
      $cReturnReason TEXT NOT NULL,
      $cNotes TEXT,
      $cStatus TEXT NOT NULL DEFAULT 'معلق',
      $cOriginalSaleId INTEGER,
      $cOriginalPurchaseId INTEGER,
      $cOriginalInvoiceNumber TEXT,
      $cCreatedBy TEXT,
      $cCreatedAt TEXT NOT NULL,
      $cUpdatedAt TEXT NOT NULL,
      $cSyncStatus TEXT DEFAULT 'pending',
      $cFirebaseId TEXT
    )
  ''';

  static const List<String> indexes = [
    'CREATE INDEX idx_returns_date ON $table($cReturnDate)',
    'CREATE INDEX idx_returns_type ON $table($cReturnType)',
    'CREATE INDEX idx_returns_customer ON $table($cCustomerId)',
    'CREATE INDEX idx_returns_supplier ON $table($cSupplierId)',
    'CREATE INDEX idx_returns_qat_type ON $table($cQatTypeId)',
    'CREATE INDEX idx_returns_status ON $table($cStatus)',
    'CREATE INDEX idx_returns_original_sale ON $table($cOriginalSaleId)',
    'CREATE INDEX idx_returns_original_purchase ON $table($cOriginalPurchaseId)',
    'CREATE INDEX idx_returns_date_type ON $table($cReturnDate, $cReturnType)',
  ];
}
