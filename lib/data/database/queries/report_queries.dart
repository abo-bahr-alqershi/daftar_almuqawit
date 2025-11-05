// ignore_for_file: public_member_api_docs

import '../../../core/constants/database_constants.dart';

/// استعلامات التقارير والإحصائيات
/// توفر استعلامات SQL معقدة للتقارير المالية والإحصائيات
class ReportQueries {
  ReportQueries._();

  /// استعلام الإحصائيات اليومية
  static String dailyStatistics(String date) {
    return '''
      SELECT 
        COALESCE(SUM(CASE WHEN s.${DatabaseConstants.columnSaleStatus} = 'completed' THEN s.${DatabaseConstants.columnSaleTotal} ELSE 0 END), 0) as total_sales,
        COALESCE(SUM(CASE WHEN s.${DatabaseConstants.columnSalePaymentMethod} = 'cash' THEN s.${DatabaseConstants.columnSalePaid} ELSE 0 END), 0) as cash_sales,
        COALESCE(SUM(CASE WHEN s.${DatabaseConstants.columnSalePaymentMethod} = 'credit' THEN s.${DatabaseConstants.columnSaleRemaining} ELSE 0 END), 0) as credit_sales,
        COALESCE(SUM(p.${DatabaseConstants.columnPurchaseTotal}), 0) as total_purchases,
        COALESCE(SUM(e.${DatabaseConstants.columnExpenseAmount}), 0) as total_expenses,
        COALESCE(SUM(d.${DatabaseConstants.columnDebtPaidAmount}), 0) as collected_debts,
        COALESCE(SUM(CASE WHEN d.${DatabaseConstants.columnCreatedAt} = ? THEN d.${DatabaseConstants.columnDebtOriginalAmount} ELSE 0 END), 0) as new_debts
      FROM ${DatabaseConstants.tableSales} s
      LEFT JOIN ${DatabaseConstants.tablePurchases} p ON DATE(p.${DatabaseConstants.columnPurchaseDate}) = ?
      LEFT JOIN ${DatabaseConstants.tableExpenses} e ON DATE(e.${DatabaseConstants.columnExpenseDate}) = ?
      LEFT JOIN ${DatabaseConstants.tableDebts} d ON DATE(d.${DatabaseConstants.columnCreatedAt}) = ?
      WHERE DATE(s.${DatabaseConstants.columnSaleDate}) = ?
      AND s.${DatabaseConstants.columnIsDeleted} = 0
    ''';
  }

  /// استعلام الإحصائيات الشهرية
  static String monthlyStatistics(int year, int month) {
    return '''
      SELECT 
        DATE(${DatabaseConstants.columnSaleDate}) as date,
        COALESCE(SUM(${DatabaseConstants.columnSaleTotal}), 0) as total_sales,
        COALESCE(SUM(${DatabaseConstants.columnSalePaid}), 0) as paid_amount,
        COALESCE(SUM(${DatabaseConstants.columnSaleRemaining}), 0) as remaining_amount,
        COUNT(*) as sales_count
      FROM ${DatabaseConstants.tableSales}
      WHERE strftime('%Y', ${DatabaseConstants.columnSaleDate}) = ?
      AND strftime('%m', ${DatabaseConstants.columnSaleDate}) = ?
      AND ${DatabaseConstants.columnIsDeleted} = 0
      GROUP BY DATE(${DatabaseConstants.columnSaleDate})
      ORDER BY date DESC
    ''';
  }

  /// استعلام أفضل العملاء
  static String topCustomers(int limit) {
    return '''
      SELECT 
        c.${DatabaseConstants.columnId},
        c.${DatabaseConstants.columnCustomerName},
        c.${DatabaseConstants.columnCustomerPhone},
        COALESCE(SUM(s.${DatabaseConstants.columnSaleTotal}), 0) as total_purchases,
        COUNT(s.${DatabaseConstants.columnId}) as purchase_count,
        COALESCE(AVG(s.${DatabaseConstants.columnSaleTotal}), 0) as avg_purchase
      FROM ${DatabaseConstants.tableCustomers} c
      LEFT JOIN ${DatabaseConstants.tableSales} s ON c.${DatabaseConstants.columnId} = s.${DatabaseConstants.columnSaleCustomerId}
      WHERE c.${DatabaseConstants.columnIsDeleted} = 0
      AND s.${DatabaseConstants.columnIsDeleted} = 0
      GROUP BY c.${DatabaseConstants.columnId}
      ORDER BY total_purchases DESC
      LIMIT $limit
    ''';
  }

  /// استعلام أفضل المنتجات مبيعاً
  static String bestSellingProducts(int limit) {
    return '''
      SELECT 
        qt.${DatabaseConstants.columnId},
        qt.${DatabaseConstants.columnQatTypeName},
        COALESCE(SUM(si.quantity), 0) as total_quantity,
        COALESCE(SUM(si.total), 0) as total_revenue,
        COUNT(si.${DatabaseConstants.columnId}) as sales_count
      FROM ${DatabaseConstants.tableQatTypes} qt
      LEFT JOIN ${DatabaseConstants.tableSaleItems} si ON qt.${DatabaseConstants.columnId} = si.qat_type_id
      WHERE qt.${DatabaseConstants.columnIsDeleted} = 0
      GROUP BY qt.${DatabaseConstants.columnId}
      ORDER BY total_quantity DESC
      LIMIT $limit
    ''';
  }

  /// استعلام تحليل الأرباح
  static String profitAnalysis(String startDate, String endDate) {
    return '''
      SELECT 
        DATE(s.${DatabaseConstants.columnSaleDate}) as date,
        COALESCE(SUM(s.${DatabaseConstants.columnSaleTotal}), 0) as revenue,
        COALESCE(SUM(p.${DatabaseConstants.columnPurchaseTotal}), 0) as cost,
        COALESCE(SUM(e.${DatabaseConstants.columnExpenseAmount}), 0) as expenses,
        (COALESCE(SUM(s.${DatabaseConstants.columnSaleTotal}), 0) - 
         COALESCE(SUM(p.${DatabaseConstants.columnPurchaseTotal}), 0) - 
         COALESCE(SUM(e.${DatabaseConstants.columnExpenseAmount}), 0)) as net_profit
      FROM ${DatabaseConstants.tableSales} s
      LEFT JOIN ${DatabaseConstants.tablePurchases} p ON DATE(p.${DatabaseConstants.columnPurchaseDate}) = DATE(s.${DatabaseConstants.columnSaleDate})
      LEFT JOIN ${DatabaseConstants.tableExpenses} e ON DATE(e.${DatabaseConstants.columnExpenseDate}) = DATE(s.${DatabaseConstants.columnSaleDate})
      WHERE DATE(s.${DatabaseConstants.columnSaleDate}) BETWEEN ? AND ?
      AND s.${DatabaseConstants.columnIsDeleted} = 0
      GROUP BY DATE(s.${DatabaseConstants.columnSaleDate})
      ORDER BY date DESC
    ''';
  }

  /// استعلام الديون المستحقة
  static String overdueDebts() {
    return '''
      SELECT 
        d.${DatabaseConstants.columnId},
        d.${DatabaseConstants.columnDebtOriginalAmount},
        d.${DatabaseConstants.columnDebtRemainingAmount},
        d.${DatabaseConstants.columnDebtDueDate},
        c.${DatabaseConstants.columnCustomerName},
        c.${DatabaseConstants.columnCustomerPhone},
        julianday('now') - julianday(d.${DatabaseConstants.columnDebtDueDate}) as days_overdue
      FROM ${DatabaseConstants.tableDebts} d
      INNER JOIN ${DatabaseConstants.tableCustomers} c ON d.${DatabaseConstants.columnDebtCustomerId} = c.${DatabaseConstants.columnId}
      WHERE d.${DatabaseConstants.columnDebtStatus} = 'pending'
      AND DATE(d.${DatabaseConstants.columnDebtDueDate}) < DATE('now')
      AND d.${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY days_overdue DESC
    ''';
  }

  /// استعلام ملخص المبيعات حسب طريقة الدفع
  static String salesByPaymentMethod(String startDate, String endDate) {
    return '''
      SELECT 
        ${DatabaseConstants.columnSalePaymentMethod} as payment_method,
        COUNT(*) as count,
        COALESCE(SUM(${DatabaseConstants.columnSaleTotal}), 0) as total,
        COALESCE(SUM(${DatabaseConstants.columnSalePaid}), 0) as paid,
        COALESCE(SUM(${DatabaseConstants.columnSaleRemaining}), 0) as remaining
      FROM ${DatabaseConstants.tableSales}
      WHERE DATE(${DatabaseConstants.columnSaleDate}) BETWEEN ? AND ?
      AND ${DatabaseConstants.columnIsDeleted} = 0
      GROUP BY ${DatabaseConstants.columnSalePaymentMethod}
    ''';
  }

  /// استعلام المصروفات حسب الفئة
  static String expensesByCategory(String startDate, String endDate) {
    return '''
      SELECT 
        ec.name as category_name,
        COUNT(e.${DatabaseConstants.columnId}) as count,
        COALESCE(SUM(e.${DatabaseConstants.columnExpenseAmount}), 0) as total
      FROM ${DatabaseConstants.tableExpenses} e
      INNER JOIN ${DatabaseConstants.tableExpenseCategories} ec ON e.${DatabaseConstants.columnExpenseCategoryId} = ec.${DatabaseConstants.columnId}
      WHERE DATE(e.${DatabaseConstants.columnExpenseDate}) BETWEEN ? AND ?
      AND e.${DatabaseConstants.columnIsDeleted} = 0
      GROUP BY ec.${DatabaseConstants.columnId}
      ORDER BY total DESC
    ''';
  }

  /// استعلام تقرير التدفق النقدي
  static String cashFlowReport(String startDate, String endDate) {
    return '''
      SELECT 
        DATE(date) as date,
        SUM(CASE WHEN type = 'in' THEN amount ELSE 0 END) as cash_in,
        SUM(CASE WHEN type = 'out' THEN amount ELSE 0 END) as cash_out,
        SUM(CASE WHEN type = 'in' THEN amount ELSE -amount END) as net_flow
      FROM (
        SELECT ${DatabaseConstants.columnSaleDate} as date, ${DatabaseConstants.columnSalePaid} as amount, 'in' as type
        FROM ${DatabaseConstants.tableSales}
        WHERE ${DatabaseConstants.columnSalePaymentMethod} = 'cash'
        AND ${DatabaseConstants.columnIsDeleted} = 0
        UNION ALL
        SELECT ${DatabaseConstants.columnPurchaseDate} as date, ${DatabaseConstants.columnPurchasePaid} as amount, 'out' as type
        FROM ${DatabaseConstants.tablePurchases}
        WHERE ${DatabaseConstants.columnIsDeleted} = 0
        UNION ALL
        SELECT ${DatabaseConstants.columnExpenseDate} as date, ${DatabaseConstants.columnExpenseAmount} as amount, 'out' as type
        FROM ${DatabaseConstants.tableExpenses}
        WHERE ${DatabaseConstants.columnIsDeleted} = 0
      )
      WHERE DATE(date) BETWEEN ? AND ?
      GROUP BY DATE(date)
      ORDER BY date DESC
    ''';
  }

  /// استعلام تقرير المخزون
  static String inventoryReport() {
    return '''
      SELECT 
        qt.${DatabaseConstants.columnId},
        qt.${DatabaseConstants.columnQatTypeName},
        COALESCE(SUM(pi.quantity), 0) as purchased,
        COALESCE(SUM(si.quantity), 0) as sold,
        (COALESCE(SUM(pi.quantity), 0) - COALESCE(SUM(si.quantity), 0)) as remaining
      FROM ${DatabaseConstants.tableQatTypes} qt
      LEFT JOIN ${DatabaseConstants.tablePurchaseItems} pi ON qt.${DatabaseConstants.columnId} = pi.qat_type_id
      LEFT JOIN ${DatabaseConstants.tableSaleItems} si ON qt.${DatabaseConstants.columnId} = si.qat_type_id
      WHERE qt.${DatabaseConstants.columnIsDeleted} = 0
      GROUP BY qt.${DatabaseConstants.columnId}
      ORDER BY qt.${DatabaseConstants.columnQatTypeName}
    ''';
  }

  /// استعلام تقرير أداء الموردين
  static String supplierPerformance(String startDate, String endDate) {
    return '''
      SELECT 
        s.${DatabaseConstants.columnId},
        s.${DatabaseConstants.columnSupplierName},
        COUNT(p.${DatabaseConstants.columnId}) as purchase_count,
        COALESCE(SUM(p.${DatabaseConstants.columnPurchaseTotal}), 0) as total_purchases,
        COALESCE(AVG(p.${DatabaseConstants.columnPurchaseTotal}), 0) as avg_purchase,
        s.${DatabaseConstants.columnSupplierRating}
      FROM ${DatabaseConstants.tableSuppliers} s
      LEFT JOIN ${DatabaseConstants.tablePurchases} p ON s.${DatabaseConstants.columnId} = p.${DatabaseConstants.columnPurchaseSupplierId}
      WHERE DATE(p.${DatabaseConstants.columnPurchaseDate}) BETWEEN ? AND ?
      AND s.${DatabaseConstants.columnIsDeleted} = 0
      AND p.${DatabaseConstants.columnIsDeleted} = 0
      GROUP BY s.${DatabaseConstants.columnId}
      ORDER BY total_purchases DESC
    ''';
  }
}
