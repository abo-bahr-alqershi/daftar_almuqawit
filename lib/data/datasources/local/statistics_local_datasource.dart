// ignore_for_file: public_member_api_docs

import 'package:sqflite/sqflite.dart';
import '../../models/statistics_model.dart';
import '../../database/queries/report_queries.dart';
import 'base_local_datasource.dart';

class StatisticsLocalDataSource extends BaseLocalDataSource<DailyStatisticsModel> {
  StatisticsLocalDataSource(super.dbHelper);

  @override
  String get tableName => 'daily_stats';

  @override
  DailyStatisticsModel fromMap(Map<String, dynamic> map) => DailyStatisticsModel.fromMap(map);

  Future<DailyStatisticsModel?> getDaily(String date) async {
    final database = await db;
    final rows = await database.query('daily_stats', where: 'date = ?', whereArgs: [date], limit: 1);
    if (rows.isEmpty) return null;
    return DailyStatisticsModel.fromMap(rows.first);
  }

  Future<List<DailyStatisticsModel>> getMonthly(int year, int month) async {
    final database = await db;
    final prefix = '$year-${month.toString().padLeft(2, '0')}-';
    final rows = await database.query('daily_stats', where: 'date LIKE ?', whereArgs: ['$prefix%'], orderBy: 'date ASC');
    return rows.map((e) => DailyStatisticsModel.fromMap(e)).toList();
  }
  
  Future<void> saveDaily(dynamic statistics) async {
    final database = await db;
    final model = statistics is DailyStatisticsModel 
      ? statistics 
      : DailyStatisticsModel(
          date: statistics.date,
          totalSales: statistics.totalSales ?? 0,
          totalPurchases: statistics.totalPurchases ?? 0,
          totalExpenses: statistics.totalExpenses ?? 0,
          cashSales: statistics.cashSales ?? 0,
          creditSales: statistics.creditSales ?? 0,
          grossProfit: statistics.grossProfit ?? 0,
          netProfit: statistics.netProfit ?? 0,
          newDebts: statistics.newDebts ?? 0,
          collectedDebts: statistics.collectedDebts ?? 0,
          cashBalance: statistics.cashBalance ?? 0,
        );
    
    await database.insert(
      'daily_stats',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>> getDailyStatistics(String date) async {
    final query = ReportQueries.dailyStatistics(date);
    // نمرر نفس التاريخ لكل الاستعلامات الفرعية داخل dailyStatistics
    final results = await rawQuery(
      query,
      [date, date, date, date, date, date, date],
    );
    
    if (results.isEmpty) {
      return {
        'total_sales': 0.0,
        'cash_sales': 0.0,
        'credit_sales': 0.0,
        'total_purchases': 0.0,
        'total_expenses': 0.0,
        'collected_debts': 0.0,
        'new_debts': 0.0,
        'gross_profit': 0.0,
        'net_profit': 0.0,
      };
    }
    
    return results.first;
  }

  Future<List<Map<String, dynamic>>> getMonthlyStatistics(int year, int month) async {
    final query = ReportQueries.monthlyStatistics(year, month);
    final yearStr = year.toString();
    final monthStr = month.toString().padLeft(2, '0');
    
    return await rawQuery(query, [yearStr, monthStr]);
  }

  Future<List<Map<String, dynamic>>> getTopCustomers(int limit) async {
    final query = ReportQueries.topCustomers(limit);
    return await rawQuery(query);
  }

  Future<List<Map<String, dynamic>>> getBestSellingProducts(int limit) async {
    final query = ReportQueries.bestSellingProducts(limit);
    return await rawQuery(query);
  }

  Future<List<Map<String, dynamic>>> getProfitAnalysis(String startDate, String endDate) async {
    final query = ReportQueries.profitAnalysis(startDate, endDate);
    return await rawQuery(query, [startDate, endDate]);
  }

  Future<List<Map<String, dynamic>>> getOverdueDebts() async {
    final query = ReportQueries.overdueDebts();
    return await rawQuery(query);
  }

  Future<Map<String, dynamic>> getSalesByPaymentMethod(String startDate, String endDate) async {
    final query = ReportQueries.salesByPaymentMethod(startDate, endDate);
    final results = await rawQuery(query, [startDate, endDate]);
    return results.isNotEmpty ? results.first : {};
  }

  Future<List<Map<String, dynamic>>> getExpensesByCategory(String startDate, String endDate) async {
    final query = ReportQueries.expensesByCategory(startDate, endDate);
    return await rawQuery(query, [startDate, endDate]);
  }

  Future<Map<String, dynamic>> getCashFlowReport(String startDate, String endDate) async {
    final query = ReportQueries.cashFlowReport(startDate, endDate);
    final results = await rawQuery(query, [startDate, endDate]);
    return results.isNotEmpty ? results.first : {};
  }

  Future<List<Map<String, dynamic>>> getInventoryReport() async {
    final query = ReportQueries.inventoryReport();
    return await rawQuery(query);
  }

  Future<List<Map<String, dynamic>>> getSupplierPerformance(String startDate, String endDate) async {
    final query = ReportQueries.supplierPerformance(startDate, endDate);
    return await rawQuery(query, [startDate, endDate]);
  }
}
