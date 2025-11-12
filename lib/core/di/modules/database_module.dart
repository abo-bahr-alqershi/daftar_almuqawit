// ignore_for_file: public_member_api_docs

import 'package:get_it/get_it.dart';

import '../../../data/datasources/local/accounting_local_datasource.dart';
import '../../../data/datasources/local/customer_local_datasource.dart';
import '../../../data/datasources/local/debt_local_datasource.dart';
import '../../../data/datasources/local/debt_payment_local_datasource.dart';
import '../../../data/datasources/local/expense_local_datasource.dart';
import '../../../data/datasources/local/purchase_local_datasource.dart';
import '../../../data/datasources/local/qat_type_local_datasource.dart';
import '../../../data/datasources/local/sales_local_datasource.dart';
import '../../../data/datasources/local/statistics_local_datasource.dart';
import '../../../data/datasources/local/supplier_local_datasource.dart';
import '../../../data/datasources/local/sync_local_datasource.dart';
import '../../../data/datasources/local/search_local_datasource.dart';
import '../../../data/datasources/local/inventory_local_datasource.dart';
import '../../../data/database/database_helper.dart';

class DatabaseModule {
  static Future<void> register(GetIt sl) async {
    sl.registerLazySingleton<SupplierLocalDataSource>(() => SupplierLocalDataSource(sl<DatabaseHelper>()));
    sl.registerLazySingleton<CustomerLocalDataSource>(() => CustomerLocalDataSource(sl<DatabaseHelper>()));
    sl.registerLazySingleton<QatTypeLocalDataSource>(() => QatTypeLocalDataSource(sl<DatabaseHelper>()));
    sl.registerLazySingleton<PurchaseLocalDataSource>(() => PurchaseLocalDataSource(sl<DatabaseHelper>()));
    sl.registerLazySingleton<SalesLocalDataSource>(() => SalesLocalDataSource(sl<DatabaseHelper>()));
    sl.registerLazySingleton<DebtLocalDataSource>(() => DebtLocalDataSource(sl<DatabaseHelper>()));
    sl.registerLazySingleton<DebtPaymentLocalDataSource>(() => DebtPaymentLocalDataSource(sl<DatabaseHelper>()));
    sl.registerLazySingleton<ExpenseLocalDataSource>(() => ExpenseLocalDataSource(sl<DatabaseHelper>()));
    sl.registerLazySingleton<AccountingLocalDataSource>(() => AccountingLocalDataSource(sl<DatabaseHelper>()));
    sl.registerLazySingleton<StatisticsLocalDataSource>(() => StatisticsLocalDataSource(sl<DatabaseHelper>()));
    sl.registerLazySingleton<SyncLocalDataSource>(() => SyncLocalDataSource(sl<DatabaseHelper>()));
    sl.registerLazySingleton<SearchLocalDataSource>(() => SearchLocalDataSource(sl<DatabaseHelper>()));
    sl.registerLazySingleton<InventoryLocalDataSource>(() => InventoryLocalDataSource(sl<DatabaseHelper>()));
  }
}
