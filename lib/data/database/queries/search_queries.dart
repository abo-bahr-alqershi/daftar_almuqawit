// ignore_for_file: public_member_api_docs

import '../../../core/constants/database_constants.dart';

/// استعلامات البحث المتقدم
/// توفر استعلامات بحث متقدمة عبر جداول مختلفة
class SearchQueries {
  SearchQueries._();

  /// البحث في العملاء
  static String searchCustomers() {
    return '''
      SELECT * FROM ${DatabaseConstants.tableCustomers}
      WHERE (
        ${DatabaseConstants.columnCustomerName} LIKE ? OR
        ${DatabaseConstants.columnCustomerPhone} LIKE ? OR
        ${DatabaseConstants.columnCustomerAddress} LIKE ?
      )
      AND ${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY ${DatabaseConstants.columnCustomerName} ASC
    ''';
  }

  /// البحث في الموردين
  static String searchSuppliers() {
    return '''
      SELECT * FROM ${DatabaseConstants.tableSuppliers}
      WHERE (
        ${DatabaseConstants.columnSupplierName} LIKE ? OR
        ${DatabaseConstants.columnSupplierPhone} LIKE ? OR
        ${DatabaseConstants.columnSupplierAddress} LIKE ?
      )
      AND ${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY ${DatabaseConstants.columnSupplierName} ASC
    ''';
  }

  /// البحث في أنواع القات
  static String searchQatTypes() {
    return '''
      SELECT * FROM ${DatabaseConstants.tableQatTypes}
      WHERE (
        ${DatabaseConstants.columnQatTypeName} LIKE ? OR
        ${DatabaseConstants.columnQatTypeDescription} LIKE ?
      )
      AND ${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY ${DatabaseConstants.columnQatTypeName} ASC
    ''';
  }

  /// البحث في المبيعات
  static String searchSales() {
    return '''
      SELECT 
        s.*,
        c.${DatabaseConstants.columnCustomerName} as customer_name
      FROM ${DatabaseConstants.tableSales} s
      LEFT JOIN ${DatabaseConstants.tableCustomers} c ON s.${DatabaseConstants.columnSaleCustomerId} = c.${DatabaseConstants.columnId}
      WHERE (
        c.${DatabaseConstants.columnCustomerName} LIKE ? OR
        s.${DatabaseConstants.columnSaleNotes} LIKE ? OR
        s.${DatabaseConstants.columnSaleDate} LIKE ?
      )
      AND s.${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY s.${DatabaseConstants.columnSaleDate} DESC
    ''';
  }

  /// البحث في المشتريات
  static String searchPurchases() {
    return '''
      SELECT 
        p.*,
        s.${DatabaseConstants.columnSupplierName} as supplier_name
      FROM ${DatabaseConstants.tablePurchases} p
      LEFT JOIN ${DatabaseConstants.tableSuppliers} s ON p.${DatabaseConstants.columnPurchaseSupplierId} = s.${DatabaseConstants.columnId}
      WHERE (
        s.${DatabaseConstants.columnSupplierName} LIKE ? OR
        p.${DatabaseConstants.columnPurchaseDate} LIKE ?
      )
      AND p.${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY p.${DatabaseConstants.columnPurchaseDate} DESC
    ''';
  }

  /// البحث في الديون
  static String searchDebts() {
    return '''
      SELECT 
        d.*,
        c.${DatabaseConstants.columnCustomerName} as customer_name,
        c.${DatabaseConstants.columnCustomerPhone} as customer_phone
      FROM ${DatabaseConstants.tableDebts} d
      INNER JOIN ${DatabaseConstants.tableCustomers} c ON d.${DatabaseConstants.columnDebtCustomerId} = c.${DatabaseConstants.columnId}
      WHERE (
        c.${DatabaseConstants.columnCustomerName} LIKE ? OR
        c.${DatabaseConstants.columnCustomerPhone} LIKE ? OR
        d.${DatabaseConstants.columnDebtStatus} LIKE ?
      )
      AND d.${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY d.${DatabaseConstants.columnDebtDueDate} ASC
    ''';
  }

  /// البحث في المصروفات
  static String searchExpenses() {
    return '''
      SELECT 
        e.*,
        ec.name as category_name
      FROM ${DatabaseConstants.tableExpenses} e
      LEFT JOIN ${DatabaseConstants.tableExpenseCategories} ec ON e.${DatabaseConstants.columnExpenseCategoryId} = ec.${DatabaseConstants.columnId}
      WHERE (
        e.${DatabaseConstants.columnExpenseDescription} LIKE ? OR
        ec.name LIKE ? OR
        e.${DatabaseConstants.columnExpenseDate} LIKE ?
      )
      AND e.${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY e.${DatabaseConstants.columnExpenseDate} DESC
    ''';
  }

  /// البحث الشامل (في جميع الجداول)
  static String globalSearch() {
    return '''
      SELECT 'customer' as type, ${DatabaseConstants.columnId} as id, ${DatabaseConstants.columnCustomerName} as name, ${DatabaseConstants.columnCustomerPhone} as info
      FROM ${DatabaseConstants.tableCustomers}
      WHERE (${DatabaseConstants.columnCustomerName} LIKE ? OR ${DatabaseConstants.columnCustomerPhone} LIKE ?)
      AND ${DatabaseConstants.columnIsDeleted} = 0
      
      UNION ALL
      
      SELECT 'supplier' as type, ${DatabaseConstants.columnId} as id, ${DatabaseConstants.columnSupplierName} as name, ${DatabaseConstants.columnSupplierPhone} as info
      FROM ${DatabaseConstants.tableSuppliers}
      WHERE (${DatabaseConstants.columnSupplierName} LIKE ? OR ${DatabaseConstants.columnSupplierPhone} LIKE ?)
      AND ${DatabaseConstants.columnIsDeleted} = 0
      
      UNION ALL
      
      SELECT 'qat_type' as type, ${DatabaseConstants.columnId} as id, ${DatabaseConstants.columnQatTypeName} as name, ${DatabaseConstants.columnQatTypeDescription} as info
      FROM ${DatabaseConstants.tableQatTypes}
      WHERE (${DatabaseConstants.columnQatTypeName} LIKE ? OR ${DatabaseConstants.columnQatTypeDescription} LIKE ?)
      AND ${DatabaseConstants.columnIsDeleted} = 0
      
      ORDER BY name ASC
    ''';
  }

  /// البحث المتقدم في العملاء مع الفلاتر
  static String advancedSearchCustomers({
    bool? isBlocked,
    double? minDebt,
    double? maxDebt,
    int? minRating,
    int? maxRating,
  }) {
    final conditions = <String>[];
    
    if (isBlocked != null) {
      conditions.add('${DatabaseConstants.columnCustomerIsBlocked} = ${isBlocked ? 1 : 0}');
    }
    
    if (minDebt != null) {
      conditions.add('${DatabaseConstants.columnCustomerTotalDebt} >= $minDebt');
    }
    
    if (maxDebt != null) {
      conditions.add('${DatabaseConstants.columnCustomerTotalDebt} <= $maxDebt');
    }
    
    if (minRating != null) {
      conditions.add('${DatabaseConstants.columnCustomerRating} >= $minRating');
    }
    
    if (maxRating != null) {
      conditions.add('${DatabaseConstants.columnCustomerRating} <= $maxRating');
    }
    
    final whereClause = conditions.isEmpty ? '' : 'AND ${conditions.join(' AND ')}';
    
    return '''
      SELECT * FROM ${DatabaseConstants.tableCustomers}
      WHERE (
        ${DatabaseConstants.columnCustomerName} LIKE ? OR
        ${DatabaseConstants.columnCustomerPhone} LIKE ?
      )
      AND ${DatabaseConstants.columnIsDeleted} = 0
      $whereClause
      ORDER BY ${DatabaseConstants.columnCustomerName} ASC
    ''';
  }

  /// البحث في المبيعات مع الفلاتر المتقدمة
  static String advancedSearchSales({
    String? paymentMethod,
    String? status,
    double? minAmount,
    double? maxAmount,
  }) {
    final conditions = <String>[];
    
    if (paymentMethod != null) {
      conditions.add("${DatabaseConstants.columnSalePaymentMethod} = '$paymentMethod'");
    }
    
    if (status != null) {
      conditions.add("${DatabaseConstants.columnSaleStatus} = '$status'");
    }
    
    if (minAmount != null) {
      conditions.add('${DatabaseConstants.columnSaleTotal} >= $minAmount');
    }
    
    if (maxAmount != null) {
      conditions.add('${DatabaseConstants.columnSaleTotal} <= $maxAmount');
    }
    
    final whereClause = conditions.isEmpty ? '' : 'AND ${conditions.join(' AND ')}';
    
    return '''
      SELECT 
        s.*,
        c.${DatabaseConstants.columnCustomerName} as customer_name
      FROM ${DatabaseConstants.tableSales} s
      LEFT JOIN ${DatabaseConstants.tableCustomers} c ON s.${DatabaseConstants.columnSaleCustomerId} = c.${DatabaseConstants.columnId}
      WHERE s.${DatabaseConstants.columnIsDeleted} = 0
      $whereClause
      ORDER BY s.${DatabaseConstants.columnSaleDate} DESC
    ''';
  }

  /// البحث في الديون حسب الحالة
  static String searchDebtsByStatus(String status) {
    return '''
      SELECT 
        d.*,
        c.${DatabaseConstants.columnCustomerName} as customer_name,
        c.${DatabaseConstants.columnCustomerPhone} as customer_phone
      FROM ${DatabaseConstants.tableDebts} d
      INNER JOIN ${DatabaseConstants.tableCustomers} c ON d.${DatabaseConstants.columnDebtCustomerId} = c.${DatabaseConstants.columnId}
      WHERE d.${DatabaseConstants.columnDebtStatus} = ?
      AND d.${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY d.${DatabaseConstants.columnDebtDueDate} ASC
    ''';
  }

  /// البحث السريع (autocomplete)
  static String quickSearch(String tableName, String columnName) {
    return '''
      SELECT DISTINCT $columnName 
      FROM $tableName
      WHERE $columnName LIKE ?
      AND ${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY $columnName ASC
      LIMIT 10
    ''';
  }
}
