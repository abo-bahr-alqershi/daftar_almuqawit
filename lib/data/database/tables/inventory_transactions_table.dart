/// جدول حركات المخزون (inventory_transactions)
/// 
/// يسجل كل حركة على المخزون بالتفصيل
/// أنواع الحركات: شراء، بيع، جرد، تالف، مرتجع
class InventoryTransactionsTable {
  InventoryTransactionsTable._();
  
  static const String table = 'inventory_transactions';

  // الأعمدة الأساسية
  static const String cId = 'id';
  static const String cTransactionDate = 'transaction_date';
  static const String cTransactionTime = 'transaction_time';
  static const String cTransactionType = 'transaction_type'; // شراء، بيع، جرد، تالف، مرتجع
  static const String cTransactionNumber = 'transaction_number'; // رقم العملية الفريد
  
  // معلومات الصنف
  static const String cQatTypeId = 'qat_type_id';
  static const String cQatTypeName = 'qat_type_name';
  static const String cUnit = 'unit';
  
  // معلومات المخزن
  static const String cWarehouseId = 'warehouse_id';
  static const String cWarehouseName = 'warehouse_name';
  static const String cToWarehouseId = 'to_warehouse_id'; // للتحويلات
  static const String cToWarehouseName = 'to_warehouse_name';
  
  // الكميات والأسعار
  static const String cQuantityBefore = 'quantity_before'; // الكمية قبل العملية
  static const String cQuantityChange = 'quantity_change'; // التغيير (+/-)
  static const String cQuantityAfter = 'quantity_after'; // الكمية بعد العملية
  static const String cUnitCost = 'unit_cost'; // تكلفة الوحدة
  static const String cTotalCost = 'total_cost'; // التكلفة الإجمالية
  
  // الربط بالعمليات الأصلية
  static const String cReferenceType = 'reference_type'; // purchase، sale، transfer، adjustment
  static const String cReferenceId = 'reference_id'; // معرف العملية الأصلية
  static const String cReferencePerson = 'reference_person'; // اسم المورد/العميل
  
  // معلومات إضافية
  static const String cReason = 'reason'; // سبب الحركة (للتالف/المرتجع/الجرد)
  static const String cNotes = 'notes';
  static const String cStatus = 'status'; // مؤكد، معلق، ملغي
  
  // معلومات التتبع
  static const String cCreatedBy = 'created_by'; // من أنشأ الحركة
  static const String cCreatedAt = 'created_at';
  static const String cUpdatedAt = 'updated_at';
  static const String cSyncStatus = 'sync_status';
  static const String cFirebaseId = 'firebase_id';

  static const String create = '''
    CREATE TABLE $table (
      $cId INTEGER PRIMARY KEY AUTOINCREMENT,
      $cTransactionDate TEXT NOT NULL,
      $cTransactionTime TEXT NOT NULL,
      $cTransactionType TEXT NOT NULL,
      $cTransactionNumber TEXT NOT NULL,
      $cQatTypeId INTEGER NOT NULL,
      $cQatTypeName TEXT NOT NULL,
      $cUnit TEXT NOT NULL,
      $cWarehouseId INTEGER DEFAULT 1,
      $cWarehouseName TEXT DEFAULT 'المخزن الرئيسي',
      $cToWarehouseId INTEGER,
      $cToWarehouseName TEXT,
      $cQuantityBefore REAL NOT NULL,
      $cQuantityChange REAL NOT NULL,
      $cQuantityAfter REAL NOT NULL,
      $cUnitCost REAL DEFAULT 0,
      $cTotalCost REAL DEFAULT 0,
      $cReferenceType TEXT,
      $cReferenceId INTEGER,
      $cReferencePerson TEXT,
      $cReason TEXT,
      $cNotes TEXT,
      $cStatus TEXT NOT NULL DEFAULT 'مؤكد',
      $cCreatedBy TEXT,
      $cCreatedAt TEXT NOT NULL,
      $cUpdatedAt TEXT NOT NULL,
      $cSyncStatus TEXT DEFAULT 'pending',
      $cFirebaseId TEXT,
      UNIQUE($cTransactionNumber)
    )
  ''';

  static const List<String> indexes = [
    'CREATE INDEX idx_inv_trans_date ON $table($cTransactionDate)',
    'CREATE INDEX idx_inv_trans_type ON $table($cTransactionType)',
    'CREATE INDEX idx_inv_trans_qat_type ON $table($cQatTypeId)',
    'CREATE INDEX idx_inv_trans_warehouse ON $table($cWarehouseId)',
    'CREATE INDEX idx_inv_trans_reference ON $table($cReferenceType, $cReferenceId)',
    'CREATE INDEX idx_inv_trans_status ON $table($cStatus)',
    'CREATE INDEX idx_inv_trans_date_type ON $table($cTransactionDate, $cTransactionType)',
  ];
}
