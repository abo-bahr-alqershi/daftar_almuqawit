/// جدول المخزون الرئيسي (inventory)
/// 
/// يحتفظ بالكمية الحالية لكل نوع قات وكل وحدة
/// يتم تحديثه تلقائياً عند كل عملية شراء/بيع
class InventoryTable {
  InventoryTable._();
  
  static const String table = 'inventory';

  // الأعمدة الأساسية
  static const String cId = 'id';
  static const String cQatTypeId = 'qat_type_id';
  static const String cQatTypeName = 'qat_type_name';
  static const String cUnit = 'unit'; // ربطة، كيس، كرتون، قطعة
  
  // الكميات
  static const String cCurrentQuantity = 'current_quantity'; // الكمية الحالية
  static const String cReservedQuantity = 'reserved_quantity'; // الكمية المحجوزة
  static const String cAvailableQuantity = 'available_quantity'; // الكمية المتاحة للبيع
  static const String cMinimumQuantity = 'minimum_quantity'; // الحد الأدنى للتنبيه
  static const String cMaximumQuantity = 'maximum_quantity'; // الحد الأقصى
  
  // معلومات المخزن
  static const String cWarehouseId = 'warehouse_id';
  static const String cWarehouseName = 'warehouse_name';
  
  // معلومات إضافية
  static const String cLastPurchaseDate = 'last_purchase_date';
  static const String cLastSaleDate = 'last_sale_date';
  static const String cAverageCost = 'average_cost'; // متوسط سعر التكلفة
  static const String cNotes = 'notes';
  
  // معلومات التتبع
  static const String cCreatedAt = 'created_at';
  static const String cUpdatedAt = 'updated_at';
  static const String cLastUpdatedBy = 'last_updated_by';

  static const String create = '''
    CREATE TABLE $table (
      $cId INTEGER PRIMARY KEY AUTOINCREMENT,
      $cQatTypeId INTEGER NOT NULL,
      $cQatTypeName TEXT NOT NULL,
      $cUnit TEXT NOT NULL,
      $cCurrentQuantity REAL NOT NULL DEFAULT 0,
      $cReservedQuantity REAL NOT NULL DEFAULT 0,
      $cAvailableQuantity REAL NOT NULL DEFAULT 0,
      $cMinimumQuantity REAL DEFAULT 0,
      $cMaximumQuantity REAL DEFAULT 0,
      $cWarehouseId INTEGER DEFAULT 1,
      $cWarehouseName TEXT DEFAULT 'المخزن الرئيسي',
      $cLastPurchaseDate TEXT,
      $cLastSaleDate TEXT,
      $cAverageCost REAL DEFAULT 0,
      $cNotes TEXT,
      $cCreatedAt TEXT NOT NULL,
      $cUpdatedAt TEXT NOT NULL,
      $cLastUpdatedBy TEXT,
      UNIQUE($cQatTypeId, $cUnit, $cWarehouseId)
    )
  ''';

  static const List<String> indexes = [
    'CREATE INDEX idx_inventory_qat_type ON $table($cQatTypeId)',
    'CREATE INDEX idx_inventory_unit ON $table($cUnit)',
    'CREATE INDEX idx_inventory_available ON $table($cAvailableQuantity)',
    'CREATE INDEX idx_inventory_qat_unit ON $table($cQatTypeId, $cUnit)',
  ];
}
