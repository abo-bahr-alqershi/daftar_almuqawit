// ignore_for_file: public_member_api_docs

import '../../database/queries/search_queries.dart';
import '../../database/database_helper.dart';

class SearchLocalDataSource {
  final DatabaseHelper _dbHelper;

  SearchLocalDataSource(this._dbHelper);

  Future<List<Map<String, dynamic>>> _rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final database = await _dbHelper.database;
    return await database.rawQuery(sql, arguments);
  }

  Future<List<Map<String, dynamic>>> globalSearch(String searchTerm) async {
    final query = SearchQueries.globalSearch();
    final pattern = '%$searchTerm%';
    
    return await _rawQuery(
      query,
      [pattern, pattern, pattern, pattern, pattern, pattern],
    );
  }

  Future<List<Map<String, dynamic>>> searchCustomers(String searchTerm) async {
    final query = SearchQueries.searchCustomers();
    final pattern = '%$searchTerm%';
    
    return await _rawQuery(query, [pattern, pattern, pattern]);
  }

  Future<List<Map<String, dynamic>>> advancedSearchCustomers({
    String? searchTerm,
    bool? isBlocked,
    double? minDebt,
    double? maxDebt,
    int? minRating,
    int? maxRating,
  }) async {
    final query = SearchQueries.advancedSearchCustomers(
      isBlocked: isBlocked,
      minDebt: minDebt,
      maxDebt: maxDebt,
      minRating: minRating,
      maxRating: maxRating,
    );
    
    final pattern = '%${searchTerm ?? ''}%';
    return await _rawQuery(query, [pattern, pattern]);
  }

  Future<List<Map<String, dynamic>>> searchSuppliers(String searchTerm) async {
    final query = SearchQueries.searchSuppliers();
    final pattern = '%$searchTerm%';
    
    return await _rawQuery(query, [pattern, pattern, pattern]);
  }

  Future<List<Map<String, dynamic>>> searchQatTypes(String searchTerm) async {
    final query = SearchQueries.searchQatTypes();
    final pattern = '%$searchTerm%';
    
    return await _rawQuery(query, [pattern, pattern]);
  }

  Future<List<Map<String, dynamic>>> searchSales(String searchTerm) async {
    final query = SearchQueries.searchSales();
    final pattern = '%$searchTerm%';
    
    return await _rawQuery(query, [pattern, pattern, pattern]);
  }

  Future<List<Map<String, dynamic>>> advancedSearchSales({
    String? searchTerm,
    String? paymentMethod,
    String? status,
    double? minTotal,
    double? maxTotal,
    String? startDate,
    String? endDate,
  }) async {
    final query = SearchQueries.advancedSearchSales(
      paymentMethod: paymentMethod,
      status: status,
      minTotal: minTotal,
      maxTotal: maxTotal,
      startDate: startDate,
      endDate: endDate,
    );
    
    final pattern = '%${searchTerm ?? ''}%';
    return await _rawQuery(query, [pattern, pattern]);
  }

  Future<List<Map<String, dynamic>>> searchPurchases(String searchTerm) async {
    final query = SearchQueries.searchPurchases();
    final pattern = '%$searchTerm%';
    
    return await _rawQuery(query, [pattern, pattern, pattern]);
  }

  Future<List<Map<String, dynamic>>> searchDebts(String searchTerm) async {
    final query = SearchQueries.searchDebts();
    final pattern = '%$searchTerm%';
    
    return await _rawQuery(query, [pattern, pattern, pattern]);
  }

  Future<List<Map<String, dynamic>>> searchDebtsByStatus(String status) async {
    final query = SearchQueries.searchDebtsByStatus(status);
    return await _rawQuery(query);
  }

  Future<List<Map<String, dynamic>>> searchExpenses(String searchTerm) async {
    final query = SearchQueries.searchExpenses();
    final pattern = '%$searchTerm%';
    
    return await _rawQuery(query, [pattern, pattern]);
  }

  Future<List<String>> quickSearch(
    String tableName,
    String columnName,
    String searchTerm,
  ) async {
    final query = SearchQueries.quickSearch(tableName, columnName);
    final pattern = '%$searchTerm%';
    
    final results = await _rawQuery(query, [pattern]);
    return results.map((r) => r[columnName].toString()).toList();
  }
}
