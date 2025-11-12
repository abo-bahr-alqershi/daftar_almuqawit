// ignore_for_file: public_member_api_docs

import 'package:get_it/get_it.dart';

import '../../../domain/repositories/supplier_repository.dart';
import '../../../domain/repositories/customer_repository.dart';
import '../../../domain/repositories/qat_type_repository.dart';
import '../../../domain/repositories/purchase_repository.dart';
import '../../../domain/repositories/sales_repository.dart';
import '../../../domain/repositories/debt_repository.dart';
import '../../../domain/repositories/debt_payment_repository.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../../domain/repositories/accounting_repository.dart';
import '../../../domain/repositories/statistics_repository.dart';
import '../../../domain/repositories/sync_repository.dart';
import '../../../domain/repositories/backup_repository.dart';
import '../../../domain/repositories/inventory_repository.dart';

import '../../../data/repositories/supplier_repository_impl.dart';
import '../../../data/repositories/customer_repository_impl.dart';
import '../../../data/repositories/qat_type_repository_impl.dart';
import '../../../data/repositories/purchase_repository_impl.dart';
import '../../../data/repositories/sale_repository_impl.dart';
import '../../../data/repositories/debt_repository_impl.dart';
import '../../../data/repositories/debt_payment_repository_impl.dart';
import '../../../data/repositories/expense_repository_impl.dart';
import '../../../data/repositories/accounting_repository_impl.dart';
import '../../../data/repositories/statistics_repository_impl.dart';
import '../../../data/repositories/sync_repository_impl.dart';
import '../../../data/repositories/backup_repository_impl.dart';
import '../../../data/repositories/inventory_repository_impl.dart';

class RepositoryModule {
  static Future<void> register(GetIt sl) async {
    sl.registerLazySingleton<SupplierRepository>(() => SupplierRepositoryImpl(sl()));
    sl.registerLazySingleton<CustomerRepository>(() => CustomerRepositoryImpl(sl()));
    sl.registerLazySingleton<QatTypeRepository>(() => QatTypeRepositoryImpl(sl()));
    
    // إضافة InventoryRepository أولاً
    sl.registerLazySingleton<InventoryRepository>(() => InventoryRepositoryImpl(
      localDataSource: sl(),
      qatTypeLocalDataSource: sl(),
    ));
    
    // تحديث PurchaseRepository و SalesRepository ليستخدموا InventoryRepository
    sl.registerLazySingleton<PurchaseRepository>(() => PurchaseRepositoryImpl(sl(), inventoryRepository: sl()));
    sl.registerLazySingleton<SalesRepository>(() => SaleRepositoryImpl(sl(), inventoryRepository: sl()));
    
    sl.registerLazySingleton<DebtRepository>(() => DebtRepositoryImpl(sl()));
    sl.registerLazySingleton<DebtPaymentRepository>(() => DebtPaymentRepositoryImpl(sl()));
    sl.registerLazySingleton<ExpenseRepository>(() => ExpenseRepositoryImpl(sl()));
    sl.registerLazySingleton<AccountingRepository>(() => AccountingRepositoryImpl(sl()));
    sl.registerLazySingleton<StatisticsRepository>(() => StatisticsRepositoryImpl(sl()));
    sl.registerLazySingleton<SyncRepository>(() => SyncRepositoryImpl(sl(), sl()));
    sl.registerLazySingleton<BackupRepository>(() => BackupRepositoryImpl(sl(), sl()));
  }
}
