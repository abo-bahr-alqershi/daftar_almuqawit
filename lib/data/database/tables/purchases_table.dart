// ignore_for_file: public_member_api_docs

/// تعريف جدول المشتريات purchases
/// 
/// الوظائف المطلوبة:
/// - تسجيل المشتريات
/// - ربط الموردين والأصناف
/// - حساب التكاليف
/// - تتبع المدفوعات
class PurchasesTable {
  PurchasesTable._();
  
  /// اسم الجدول
  static const String table = 'purchases';

  // الأعمدة الأساسية
  static const String cId = 'id';
  static const String cDate = 'date';
  static const String cTime = 'time';
  static const String cSupplierId = 'supplier_id';
  static const String cSupplierName = 'supplier_name'; // للتخزين المؤقت
  static const String cQatTypeId = 'qat_type_id';
  static const String cQatTypeName = 'qat_type_name'; // للتخزين المؤقت
  
  // تفاصيل الكمية والسعر
  static const String cQuantity = 'quantity';
  static const String cUnit = 'unit';
  static const String cUnitPrice = 'unit_price';
  static const String cTotalAmount = 'total_amount';
  
  // معلومات الدفع
  static const String cPaymentMethod = 'payment_method'; // نقد، آجل، تحويل
  static const String cPaymentStatus = 'payment_status'; // مدفوع، معلق، جزئي
  static const String cPaidAmount = 'paid_amount';
  static const String cRemainingAmount = 'remaining_amount';
  static const String cDueDate = 'due_date'; // تاريخ الاستحقاق للآجل
  
  // معلومات إضافية
  static const String cInvoiceNumber = 'invoice_number'; // رقم الفاتورة
  static const String cNotes = 'notes';
  static const String cStatus = 'status'; // نشط، ملغي، مرتجع
  
  // معلومات المزامنة والتتبع
  static const String cCreatedAt = 'created_at';
  static const String cUpdatedAt = 'updated_at';
  static const String cSyncStatus = 'sync_status'; // synced، pending، failed
  static const String cFirebaseId = 'firebase_id'; // معرف Firebase

  /// جملة إنشاء الجدول
  static const String create = '''
CREATE TABLE $table (
  $cId INTEGER PRIMARY KEY AUTOINCREMENT,
  $cDate TEXT NOT NULL,
  $cTime TEXT NOT NULL,
  $cSupplierId INTEGER,
  $cSupplierName TEXT,
  $cQatTypeId INTEGER,
  $cQatTypeName TEXT,
  $cQuantity REAL NOT NULL,
  $cUnit TEXT DEFAULT 'ربطة',
  $cUnitPrice REAL NOT NULL,
  $cTotalAmount REAL NOT NULL,
  $cPaymentMethod TEXT DEFAULT 'نقد',
  $cPaymentStatus TEXT DEFAULT 'مدفوع',
  $cPaidAmount REAL DEFAULT 0,
  $cRemainingAmount REAL DEFAULT 0,
  $cDueDate TEXT,
  $cInvoiceNumber TEXT,
  $cNotes TEXT,
  $cStatus TEXT DEFAULT 'نشط',
  $cCreatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
  $cUpdatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
  $cSyncStatus TEXT DEFAULT 'pending',
  $cFirebaseId TEXT,
  FOREIGN KEY ($cSupplierId) REFERENCES suppliers(id) ON DELETE SET NULL,
  FOREIGN KEY ($cQatTypeId) REFERENCES qat_types(id) ON DELETE SET NULL
);
''';

  /// إنشاء فهارس لتحسين الأداء
  static const List<String> indexes = [
    'CREATE INDEX idx_purchases_date ON $table($cDate DESC);',
    'CREATE INDEX idx_purchases_supplier ON $table($cSupplierId);',
    'CREATE INDEX idx_purchases_qat_type ON $table($cQatTypeId);',
    'CREATE INDEX idx_purchases_status ON $table($cStatus);',
    'CREATE INDEX idx_purchases_payment_status ON $table($cPaymentStatus);',
    'CREATE INDEX idx_purchases_sync ON $table($cSyncStatus);',
  ];

  /// استعلام جلب المشتريات مع تفاصيل المورد والصنف
  static const String queryWithDetails = '''
SELECT 
  p.*,
  s.name as supplier_full_name,
  s.phone as supplier_phone,
  q.name as qat_type_full_name,
  q.unit_price as qat_current_price
FROM $table p
LEFT JOIN suppliers s ON p.$cSupplierId = s.id
LEFT JOIN qat_types q ON p.$cQatTypeId = q.id
''';

  /// استعلام حساب إجمالي المشتريات لمورد معين
  static String queryTotalBySupplier(int supplierId) => '''
SELECT 
  COUNT(*) as total_count,
  SUM($cTotalAmount) as total_amount,
  SUM($cPaidAmount) as total_paid,
  SUM($cRemainingAmount) as total_remaining
FROM $table
WHERE $cSupplierId = $supplierId AND $cStatus = 'نشط'
''';

  /// استعلام المشتريات المعلقة (غير المدفوعة بالكامل)
  static const String queryPending = '''
SELECT * FROM $table
WHERE $cPaymentStatus IN ('معلق', 'جزئي') 
  AND $cStatus = 'نشط'
ORDER BY $cDate DESC, $cTime DESC
''';

  /// استعلام مشتريات اليوم
  static const String queryToday = '''
SELECT * FROM $table
WHERE DATE($cDate) = DATE('now', 'localtime')
  AND $cStatus = 'نشط'
ORDER BY $cTime DESC
''';

  /// استعلام المشتريات حسب فترة زمنية
  static String queryByDateRange(String startDate, String endDate) => '''
SELECT * FROM $table
WHERE $cDate BETWEEN '$startDate' AND '$endDate'
  AND $cStatus = 'نشط'
ORDER BY $cDate DESC, $cTime DESC
''';
}
