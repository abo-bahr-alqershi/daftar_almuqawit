// ignore_for_file: public_member_api_docs

/// تعريف جدول المبيعات sales
/// 
/// الوظائف المطلوبة:
/// - تسجيل المبيعات
/// - ربط العملاء والأصناف
/// - حساب الأرباح
/// - تتبع المدفوعات
/// - دعم البيع السريع
class SalesTable {
  SalesTable._();
  
  /// اسم الجدول
  static const String table = 'sales';

  // الأعمدة الأساسية
  static const String cId = 'id';
  static const String cDate = 'date';
  static const String cTime = 'time';
  static const String cCustomerId = 'customer_id';
  static const String cCustomerName = 'customer_name'; // للتخزين المؤقت
  static const String cQatTypeId = 'qat_type_id';
  static const String cQatTypeName = 'qat_type_name'; // للتخزين المؤقت
  
  // تفاصيل الكمية والسعر
  static const String cQuantity = 'quantity';
  static const String cUnit = 'unit';
  static const String cUnitPrice = 'unit_price';
  static const String cCostPrice = 'cost_price'; // سعر التكلفة لحساب الربح
  static const String cTotalAmount = 'total_amount';
  static const String cProfit = 'profit'; // الربح المحقق
  static const String cProfitMargin = 'profit_margin'; // نسبة الربح
  
  // معلومات الدفع
  static const String cPaymentMethod = 'payment_method'; // نقد، آجل، تحويل، بطاقة
  static const String cPaymentStatus = 'payment_status'; // مدفوع، معلق، جزئي
  static const String cPaidAmount = 'paid_amount';
  static const String cRemainingAmount = 'remaining_amount';
  static const String cDueDate = 'due_date'; // تاريخ الاستحقاق للآجل
  
  // معلومات إضافية
  static const String cInvoiceNumber = 'invoice_number'; // رقم الفاتورة
  static const String cSaleType = 'sale_type'; // عادي، سريع، جملة
  static const String cDiscount = 'discount'; // الخصم
  static const String cDiscountType = 'discount_type'; // نسبة، قيمة
  static const String cNotes = 'notes';
  static const String cStatus = 'status'; // نشط، ملغي، مرتجع
  
  // معلومات المزامنة والتتبع
  static const String cCreatedAt = 'created_at';
  static const String cUpdatedAt = 'updated_at';
  static const String cSyncStatus = 'sync_status'; // synced، pending، failed
  static const String cFirebaseId = 'firebase_id'; // معرف Firebase
  
  // معلومات إضافية للتحليل
  static const String cSoldBy = 'sold_by'; // البائع (للمستقبل)
  static const String cIsQuickSale = 'is_quick_sale'; // بيع سريع

  /// جملة إنشاء الجدول
  static const String create = '''
CREATE TABLE $table (
  $cId INTEGER PRIMARY KEY AUTOINCREMENT,
  $cDate TEXT NOT NULL,
  $cTime TEXT NOT NULL,
  $cCustomerId INTEGER,
  $cCustomerName TEXT,
  $cQatTypeId INTEGER,
  $cQatTypeName TEXT,
  $cQuantity REAL NOT NULL,
  $cUnit TEXT DEFAULT 'ربطة',
  $cUnitPrice REAL NOT NULL,
  $cCostPrice REAL DEFAULT 0,
  $cTotalAmount REAL NOT NULL,
  $cProfit REAL DEFAULT 0,
  $cProfitMargin REAL DEFAULT 0,
  $cPaymentMethod TEXT DEFAULT 'نقد',
  $cPaymentStatus TEXT DEFAULT 'مدفوع',
  $cPaidAmount REAL DEFAULT 0,
  $cRemainingAmount REAL DEFAULT 0,
  $cDueDate TEXT,
  $cInvoiceNumber TEXT,
  $cSaleType TEXT DEFAULT 'عادي',
  $cDiscount REAL DEFAULT 0,
  $cDiscountType TEXT DEFAULT 'قيمة',
  $cNotes TEXT,
  $cStatus TEXT DEFAULT 'نشط',
  $cCreatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
  $cUpdatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
  $cSyncStatus TEXT DEFAULT 'pending',
  $cFirebaseId TEXT,
  $cSoldBy TEXT,
  $cIsQuickSale INTEGER DEFAULT 0,
  FOREIGN KEY ($cCustomerId) REFERENCES customers(id) ON DELETE SET NULL,
  FOREIGN KEY ($cQatTypeId) REFERENCES qat_types(id) ON DELETE SET NULL
);
''';

  /// إنشاء فهارس لتحسين الأداء
  static const List<String> indexes = [
    'CREATE INDEX idx_sales_date ON $table($cDate DESC);',
    'CREATE INDEX idx_sales_customer ON $table($cCustomerId);',
    'CREATE INDEX idx_sales_qat_type ON $table($cQatTypeId);',
    'CREATE INDEX idx_sales_status ON $table($cStatus);',
    'CREATE INDEX idx_sales_payment_status ON $table($cPaymentStatus);',
    'CREATE INDEX idx_sales_sync ON $table($cSyncStatus);',
    'CREATE INDEX idx_sales_type ON $table($cSaleType);',
    'CREATE INDEX idx_sales_quick ON $table($cIsQuickSale);',
  ];

  /// استعلام جلب المبيعات مع تفاصيل العميل والصنف
  static const String queryWithDetails = '''
SELECT 
  s.*,
  c.name as customer_full_name,
  c.phone as customer_phone,
  c.balance as customer_balance,
  q.name as qat_type_full_name,
  q.unit_price as qat_current_price
FROM $table s
LEFT JOIN customers c ON s.$cCustomerId = c.id
LEFT JOIN qat_types q ON s.$cQatTypeId = q.id
''';

  /// استعلام حساب إجمالي المبيعات لعميل معين
  static String queryTotalByCustomer(int customerId) => '''
SELECT 
  COUNT(*) as total_count,
  SUM($cTotalAmount) as total_amount,
  SUM($cPaidAmount) as total_paid,
  SUM($cRemainingAmount) as total_remaining,
  SUM($cProfit) as total_profit
FROM $table
WHERE $cCustomerId = $customerId AND $cStatus = 'نشط'
''';

  /// استعلام المبيعات المعلقة (غير المدفوعة بالكامل)
  static const String queryPending = '''
SELECT * FROM $table
WHERE $cPaymentStatus IN ('معلق', 'جزئي') 
  AND $cStatus = 'نشط'
ORDER BY $cDate DESC, $cTime DESC
''';

  /// استعلام مبيعات اليوم
  static const String queryToday = '''
SELECT * FROM $table
WHERE DATE($cDate) = DATE('now', 'localtime')
  AND $cStatus = 'نشط'
ORDER BY $cTime DESC
''';

  /// استعلام المبيعات السريعة
  static const String queryQuickSales = '''
SELECT * FROM $table
WHERE $cIsQuickSale = 1
  AND $cStatus = 'نشط'
ORDER BY $cDate DESC, $cTime DESC
''';

  /// استعلام المبيعات حسب فترة زمنية
  static String queryByDateRange(String startDate, String endDate) => '''
SELECT * FROM $table
WHERE $cDate BETWEEN '$startDate' AND '$endDate'
  AND $cStatus = 'نشط'
ORDER BY $cDate DESC, $cTime DESC
''';

  /// استعلام أفضل المبيعات (الأكثر ربحاً)
  static const String queryTopProfitable = '''
SELECT * FROM $table
WHERE $cStatus = 'نشط'
ORDER BY $cProfit DESC
LIMIT 10
''';

  /// استعلام إحصائيات المبيعات اليومية
  static const String queryDailyStats = '''
SELECT 
  DATE($cDate) as sale_date,
  COUNT(*) as total_sales,
  SUM($cQuantity) as total_quantity,
  SUM($cTotalAmount) as total_revenue,
  SUM($cProfit) as total_profit,
  AVG($cProfitMargin) as avg_profit_margin
FROM $table
WHERE $cStatus = 'نشط'
GROUP BY DATE($cDate)
ORDER BY sale_date DESC
''';
}
