/// ثوابت قاعدة البيانات SQLite المحلية
/// 
/// يحتوي على أسماء الجداول والأعمدة وإعدادات قاعدة البيانات
class DatabaseConstants {
  DatabaseConstants._();

  // ========== إعدادات قاعدة البيانات ==========
  
  /// اسم قاعدة البيانات
  static const String dbName = 'daftar_almuqawit.db';
  
  /// إصدار قاعدة البيانات
  static const int dbVersion = 1;

  // ========== أسماء الجداول ==========
  
  /// جدول الموردين
  static const String tableSuppliers = 'suppliers';
  
  /// جدول العملاء
  static const String tableCustomers = 'customers';
  
  /// جدول أنواع القات
  static const String tableQatTypes = 'qat_types';
  
  /// جدول المشتريات
  static const String tablePurchases = 'purchases';
  
  /// جدول تفاصيل المشتريات
  static const String tablePurchaseItems = 'purchase_items';
  
  /// جدول المبيعات
  static const String tableSales = 'sales';
  
  /// جدول تفاصيل المبيعات
  static const String tableSaleItems = 'sale_items';
  
  /// جدول الديون
  static const String tableDebts = 'debts';
  
  /// جدول مدفوعات الديون
  static const String tableDebtPayments = 'debt_payments';
  
  /// جدول الحسابات المحاسبية
  static const String tableAccounts = 'accounts';
  
  /// جدول القيود المحاسبية
  static const String tableJournalEntries = 'journal_entries';
  
  /// جدول تفاصيل القيود المحاسبية
  static const String tableJournalEntryDetails = 'journal_entry_details';
  
  /// جدول المصروفات
  static const String tableExpenses = 'expenses';
  
  /// جدول فئات المصروفات
  static const String tableExpenseCategories = 'expense_categories';
  
  /// جدول الإحصائيات اليومية
  static const String tableDailyStats = 'daily_stats';
  
  /// جدول قائمة المزامنة
  static const String tableSyncQueue = 'sync_queue';
  
  /// جدول البيانات الوصفية
  static const String tableMetadata = 'metadata';
  
  /// جدول المستخدمين
  static const String tableUsers = 'users';
  
  /// جدول الإعدادات
  static const String tableSettings = 'settings';

  // ========== الأعمدة المشتركة ==========
  
  /// معرف السجل
  static const String columnId = 'id';
  
  /// معرف Firebase
  static const String columnFirebaseId = 'firebase_id';
  
  /// تاريخ الإنشاء
  static const String columnCreatedAt = 'created_at';
  
  /// تاريخ التحديث
  static const String columnUpdatedAt = 'updated_at';
  
  /// تاريخ الحذف (للحذف الناعم)
  static const String columnDeletedAt = 'deleted_at';
  
  /// حالة المزامنة
  static const String columnSyncStatus = 'sync_status';
  
  /// آخر مزامنة
  static const String columnLastSynced = 'last_synced';
  
  /// محذوف (للحذف الناعم)
  static const String columnIsDeleted = 'is_deleted';
  
  /// نشط
  static const String columnIsActive = 'is_active';

  // ========== أعمدة جدول الموردين ==========
  
  /// اسم المورد
  static const String columnSupplierName = 'name';
  
  /// رقم هاتف المورد
  static const String columnSupplierPhone = 'phone';
  
  /// عنوان المورد
  static const String columnSupplierAddress = 'address';
  
  /// ملاحظات المورد
  static const String columnSupplierNotes = 'notes';
  
  /// تقييم المورد
  static const String columnSupplierRating = 'rating';

  // ========== أعمدة جدول العملاء ==========
  
  /// اسم العميل
  static const String columnCustomerName = 'name';
  
  /// رقم هاتف العميل
  static const String columnCustomerPhone = 'phone';
  
  /// عنوان العميل
  static const String columnCustomerAddress = 'address';
  
  /// ملاحظات العميل
  static const String columnCustomerNotes = 'notes';
  
  /// تقييم العميل
  static const String columnCustomerRating = 'rating';
  
  /// محظور
  static const String columnCustomerIsBlocked = 'is_blocked';
  
  /// إجمالي الديون
  static const String columnCustomerTotalDebt = 'total_debt';

  // ========== أعمدة جدول أنواع القات ==========
  
  /// اسم النوع
  static const String columnQatTypeName = 'name';
  
  /// الوصف
  static const String columnQatTypeDescription = 'description';
  
  /// السعر الافتراضي
  static const String columnQatTypeDefaultPrice = 'default_price';
  
  /// الوحدة
  static const String columnQatTypeUnit = 'unit';
  
  /// الصورة
  static const String columnQatTypeImage = 'image';

  // ========== أعمدة جدول المبيعات ==========
  
  /// معرف العميل
  static const String columnSaleCustomerId = 'customer_id';
  
  /// التاريخ
  static const String columnSaleDate = 'date';
  
  /// الإجمالي (يتوافق مع عمود total_amount في جدول المبيعات)
  static const String columnSaleTotal = 'total_amount';
  
  /// المدفوع (يتوافق مع عمود paid_amount في جدول المبيعات)
  static const String columnSalePaid = 'paid_amount';
  
  /// المتبقي (يتوافق مع عمود remaining_amount في جدول المبيعات)
  static const String columnSaleRemaining = 'remaining_amount';
  
  /// طريقة الدفع
  static const String columnSalePaymentMethod = 'payment_method';
  
  /// الحالة
  static const String columnSaleStatus = 'status';
  
  /// ملاحظات
  static const String columnSaleNotes = 'notes';

  // ========== أعمدة جدول المشتريات ==========
  
  /// معرف المورد
  static const String columnPurchaseSupplierId = 'supplier_id';
  
  /// التاريخ
  static const String columnPurchaseDate = 'date';
  
  /// الإجمالي (يتوافق مع عمود total_amount في جدول المشتريات)
  static const String columnPurchaseTotal = 'total_amount';
  
  /// المدفوع (يتوافق مع عمود paid_amount في جدول المشتريات)
  static const String columnPurchasePaid = 'paid_amount';
  
  /// المتبقي (يتوافق مع عمود remaining_amount في جدول المشتريات)
  static const String columnPurchaseRemaining = 'remaining_amount';
  
  /// طريقة الدفع
  static const String columnPurchasePaymentMethod = 'payment_method';
  
  /// الحالة
  static const String columnPurchaseStatus = 'status';

  // ========== أعمدة جدول الديون ==========
  
  /// معرف العميل
  static const String columnDebtCustomerId = 'customer_id';
  
  /// المبلغ الأصلي
  static const String columnDebtOriginalAmount = 'original_amount';
  
  /// المبلغ المدفوع
  static const String columnDebtPaidAmount = 'paid_amount';
  
  /// المبلغ المتبقي
  static const String columnDebtRemainingAmount = 'remaining_amount';
  
  /// تاريخ الاستحقاق
  static const String columnDebtDueDate = 'due_date';
  
  /// الحالة
  static const String columnDebtStatus = 'status';

  // ========== أعمدة جدول المصروفات ==========
  
  /// معرف الفئة
  static const String columnExpenseCategoryId = 'category_id';
  
  /// المبلغ
  static const String columnExpenseAmount = 'amount';
  
  /// التاريخ
  static const String columnExpenseDate = 'date';
  
  /// الوصف
  static const String columnExpenseDescription = 'description';
  
  /// الإيصال
  static const String columnExpenseReceipt = 'receipt';

  // ========== حالات المزامنة ==========
  
  /// بانتظار المزامنة
  static const String syncStatusPending = 'pending';
  
  /// تمت المزامنة
  static const String syncStatusSynced = 'synced';
  
  /// فشلت المزامنة
  static const String syncStatusFailed = 'failed';
  
  /// قيد المزامنة
  static const String syncStatusSyncing = 'syncing';

  // ========== أنواع العمليات في قائمة المزامنة ==========
  
  /// إضافة
  static const String operationInsert = 'insert';
  
  /// تحديث
  static const String operationUpdate = 'update';
  
  /// حذف
  static const String operationDelete = 'delete';

  // ========== استعلامات SQL شائعة ==========
  
  /// استعلام الحذف الناعم
  static String softDeleteQuery(String tableName) =>
      'UPDATE $tableName SET $columnIsDeleted = 1, $columnDeletedAt = ? WHERE $columnId = ?';
  
  /// استعلام الاستعادة
  static String restoreQuery(String tableName) =>
      'UPDATE $tableName SET $columnIsDeleted = 0, $columnDeletedAt = NULL WHERE $columnId = ?';
  
  /// استعلام الحذف النهائي
  static String hardDeleteQuery(String tableName) =>
      'DELETE FROM $tableName WHERE $columnId = ?';
}
