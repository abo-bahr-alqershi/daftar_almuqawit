/// جدول البضاعة التالفة (damaged_items)
/// 
/// يسجل جميع حالات التلف في المخزون مع التفاصيل الكاملة
class DamagedItemsTable {
  DamagedItemsTable._();
  
  static const String table = 'damaged_items';

  // الأعمدة الأساسية
  static const String cId = 'id';
  static const String cDamageDate = 'damage_date';
  static const String cDamageTime = 'damage_time';
  static const String cDamageNumber = 'damage_number';
  
  // معلومات المنتج
  static const String cQatTypeId = 'qat_type_id';
  static const String cQatTypeName = 'qat_type_name';
  static const String cUnit = 'unit';
  static const String cQuantity = 'quantity';
  static const String cUnitCost = 'unit_cost';
  static const String cTotalCost = 'total_cost';
  
  // تفاصيل التلف
  static const String cDamageReason = 'damage_reason';
  static const String cDamageType = 'damage_type'; // تلف_طبيعي، تلف_بشري، تلف_خارجي، انتهاء_صلاحية
  static const String cSeverityLevel = 'severity_level'; // طفيف، متوسط، كبير، كارثي
  static const String cNotes = 'notes';
  static const String cActionTaken = 'action_taken';
  
  // معلومات التأمين والمسؤولية
  static const String cIsInsuranceCovered = 'is_insurance_covered';
  static const String cInsuranceAmount = 'insurance_amount';
  static const String cResponsiblePerson = 'responsible_person';
  
  // حالة ومعلومات إضافية
  static const String cStatus = 'status'; // تحت_المراجعة، مؤكد، تم_التعامل_معه
  static const String cWarehouseId = 'warehouse_id';
  static const String cWarehouseName = 'warehouse_name';
  static const String cBatchNumber = 'batch_number';
  static const String cExpiryDate = 'expiry_date';
  static const String cDiscoveredBy = 'discovered_by';
  
  // معلومات التتبع
  static const String cCreatedBy = 'created_by';
  static const String cCreatedAt = 'created_at';
  static const String cUpdatedAt = 'updated_at';
  static const String cSyncStatus = 'sync_status';
  static const String cFirebaseId = 'firebase_id';

  static const String create = '''
    CREATE TABLE $table (
      $cId INTEGER PRIMARY KEY AUTOINCREMENT,
      $cDamageDate TEXT NOT NULL,
      $cDamageTime TEXT NOT NULL,
      $cDamageNumber TEXT NOT NULL UNIQUE,
      $cQatTypeId INTEGER NOT NULL,
      $cQatTypeName TEXT NOT NULL,
      $cUnit TEXT NOT NULL,
      $cQuantity REAL NOT NULL,
      $cUnitCost REAL NOT NULL,
      $cTotalCost REAL NOT NULL,
      $cDamageReason TEXT NOT NULL,
      $cDamageType TEXT NOT NULL,
      $cSeverityLevel TEXT DEFAULT 'متوسط',
      $cNotes TEXT,
      $cActionTaken TEXT,
      $cIsInsuranceCovered INTEGER DEFAULT 0,
      $cInsuranceAmount REAL,
      $cResponsiblePerson TEXT,
      $cStatus TEXT NOT NULL DEFAULT 'تحت_المراجعة',
      $cWarehouseId INTEGER DEFAULT 1,
      $cWarehouseName TEXT DEFAULT 'المخزن الرئيسي',
      $cBatchNumber TEXT,
      $cExpiryDate TEXT,
      $cDiscoveredBy TEXT,
      $cCreatedBy TEXT,
      $cCreatedAt TEXT NOT NULL,
      $cUpdatedAt TEXT NOT NULL,
      $cSyncStatus TEXT DEFAULT 'pending',
      $cFirebaseId TEXT
    )
  ''';

  static const List<String> indexes = [
    'CREATE INDEX idx_damaged_date ON $table($cDamageDate)',
    'CREATE INDEX idx_damaged_type ON $table($cDamageType)',
    'CREATE INDEX idx_damaged_qat_type ON $table($cQatTypeId)',
    'CREATE INDEX idx_damaged_status ON $table($cStatus)',
    'CREATE INDEX idx_damaged_severity ON $table($cSeverityLevel)',
    'CREATE INDEX idx_damaged_warehouse ON $table($cWarehouseId)',
    'CREATE INDEX idx_damaged_discovered_by ON $table($cDiscoveredBy)',
    'CREATE INDEX idx_damaged_date_type ON $table($cDamageDate, $cDamageType)',
    'CREATE INDEX idx_damaged_expiry ON $table($cExpiryDate)',
  ];
}
