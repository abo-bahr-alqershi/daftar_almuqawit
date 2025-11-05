# تقرير إصلاح ترابط الملفات في مشروع دفتر المقاوت

## ملخص التحليل

تم فحص جميع الملفات المذكورة في قوائم الترابط الثلاثة وتم اكتشاف عدة ملفات لا تُستخدم في أماكنها الصحيحة أو لا تُستخدم بشكل كامل.

---

## 1. الملفات التي تحتاج إلى ربط كامل

### 1.1 `error_handler.dart`

**الوضع الحالي:**
- الملف موجود ولكن لا يُستخدم في معظم repositories و datasources
- يجب استخدامه في جميع عمليات معالجة الأخطاء

**الملفات التي يجب أن تستخدمه:**
1. ✅ جميع الـ Repositories في `lib/data/repositories/`
2. ✅ جميع الـ Remote Datasources في `lib/data/datasources/remote/`
3. ✅ جميع الـ BLoCs في `lib/presentation/blocs/`
4. ✅ جميع الـ UseCases في `lib/domain/usecases/`

**مثال على الاستخدام المطلوب:**

```dart
// في أي repository أو datasource
import 'package:dartz/dartz.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/errors/failures.dart';

class CustomerRepositoryImpl {
  Future<Either<Failure, Customer>> getCustomer(int id) async {
    try {
      final customer = await localDataSource.getById(id);
      return Right(customer);
    } catch (e, stackTrace) {
      // استخدام ErrorHandler لتحويل الأخطاء
      return Left(ErrorHandler.handleException(e, stackTrace));
    }
  }
}
```

**الإجراء المطلوب:**
- [ ] إضافة استيراد `error_handler.dart` في جميع الملفات المذكورة
- [ ] استبدال جميع كتل `catch` البسيطة باستخدام `ErrorHandler.handleException()`
- [ ] التأكد من أن جميع الدوال ترجع `Either<Failure, T>` في الـ repositories

---

### 1.2 `conflict_resolver.dart`

**الوضع الحالي:**
- ✅ مُسجل في `service_locator.dart`
- ✅ يُستخدم في `sync_manager.dart`
- ✅ يُستخدم في `resolve_conflicts.dart` usecase
- ❌ لا يُستخدم في repositories أثناء عمليات المزامنة الفعلية

**الملفات التي يجب أن تستخدمه:**
1. ✅ `lib/data/repositories/*/` - جميع الـ repositories عند مزامنة البيانات
2. ✅ `lib/data/datasources/remote/base_remote_datasource.dart`

**مثال على الاستخدام المطلوب:**

```dart
class CustomerRepositoryImpl {
  final ConflictResolver _conflictResolver;
  
  Future<Either<Failure, void>> syncCustomer(CustomerModel local) async {
    try {
      // جلب البيانات البعيدة
      final remote = await remoteDataSource.getById(local.id);
      
      // كشف التعارضات
      final hasConflict = await _conflictResolver.detectConflict(
        local.toMap(),
        remote.toMap(),
      );
      
      if (hasConflict) {
        // حل التعارض
        final resolved = await _conflictResolver.resolveConflict(
          local.toMap(),
          remote.toMap(),
          strategy: ConflictResolutionStrategy.useNewest,
        );
        
        final resolvedModel = CustomerModel.fromMap(resolved);
        await localDataSource.update(resolvedModel);
        await remoteDataSource.upsert(resolvedModel);
      }
      
      return Right(null);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleException(e, stackTrace));
    }
  }
}
```

**الإجراء المطلوب:**
- [ ] إضافة `ConflictResolver` إلى constructor جميع repositories
- [ ] تطبيق منطق كشف وحل التعارضات في دوال المزامنة
- [ ] إضافة معالجة التعارضات في `base_remote_datasource.dart`

---

### 1.3 `firebase_service.dart`

**الوضع الحالي:**
- ✅ مُسجل في `service_locator.dart`
- ⚠️ معلق في `injection_container.dart` (السطر 50)
- ❌ لا يُستخدم بشكل كافٍ في remote datasources

**الملفات التي يجب أن تستخدمه:**
1. ✅ `main.dart` - للتهيئة الأولية
2. ✅ جميع Remote Datasources - للتحقق من الاتصال قبل العمليات
3. ✅ `network_service.dart` - للتكامل

**مثال على الاستخدام المطلوب:**

```dart
// في main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة Firebase أولاً
  await FirebaseService.instance.initialize();
  
  // ثم تهيئة باقي الخدمات
  await setupServiceLocator();
  
  runApp(MyApp());
}

// في remote datasources
class CustomersRemoteDataSource {
  final FirebaseService _firebaseService;
  
  Future<List<CustomerModel>> fetchAll() async {
    // التحقق من اتصال Firebase
    if (!await _firebaseService.checkConnection()) {
      throw NoInternetException();
    }
    
    final snap = await col(FirebaseConstants.customers).get();
    return snap.docs.map((d) => CustomerModel.fromMap(d.data())).toList();
  }
}
```

**الإجراء المطلوب:**
- [ ] فك التعليق عن استخدام FirebaseService في `injection_container.dart`
- [ ] إضافة FirebaseService إلى جميع remote datasources
- [ ] إضافة فحص الاتصال قبل كل عملية بعيدة
- [ ] استخدامه في `main.dart` للتهيئة

---

### 1.4 `firebase_storage_service.dart`

**الوضع الحالي:**
- ✅ مُسجل في `service_locator.dart`
- ❌ لا يُستخدم في أي مكان فعلياً
- ⚠️ الملف الحالي بسيط جداً ويحتاج إلى تطوير

**الملفات التي يجب أن تستخدمه:**
1. ❌ `lib/core/services/backup/backup_service.dart` - لرفع النسخ الاحتياطية
2. ❌ `lib/core/services/export/export_service.dart` - لرفع التقارير
3. ❌ `lib/data/datasources/remote/backup_remote_datasource.dart`
4. ❌ الملفات التي تتعامل مع الصور والمرفقات

**مثال على الاستخدام المطلوب:**

```dart
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// رفع ملف
  Future<String> uploadFile({
    required String path,
    required File file,
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref(path);
      final task = ref.putFile(file);
      
      task.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });
      
      await task;
      return await ref.getDownloadURL();
    } catch (e) {
      throw StorageException('فشل رفع الملف: ${e.toString()}');
    }
  }

  /// تحميل ملف
  Future<File> downloadFile({
    required String path,
    required String localPath,
  }) async {
    try {
      final ref = _storage.ref(path);
      final file = File(localPath);
      await ref.writeToFile(file);
      return file;
    } catch (e) {
      throw StorageException('فشل تحميل الملف: ${e.toString()}');
    }
  }

  /// حذف ملف
  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
    } catch (e) {
      throw StorageException('فشل حذف الملف: ${e.toString()}');
    }
  }
}

// الاستخدام في backup_service
class BackupService {
  final FirebaseStorageService _storageService;
  
  Future<Either<Failure, String>> uploadBackup(File backupFile) async {
    try {
      final path = 'backups/${DateTime.now().millisecondsSinceEpoch}.db';
      final url = await _storageService.uploadFile(
        path: path,
        file: backupFile,
        onProgress: (progress) {
          // تحديث تقدم الرفع
        },
      );
      return Right(url);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleException(e, stackTrace));
    }
  }
}
```

**الإجراء المطلوب:**
- [ ] تطوير `firebase_storage_service.dart` بإضافة دوال كاملة
- [ ] إنشاء `backup_service.dart` إذا لم يكن موجوداً
- [ ] إنشاء `export_service.dart` إذا لم يكن موجوداً
- [ ] استخدام الخدمة في جميع العمليات التي تحتاج رفع/تحميل ملفات

---

### 1.5 `network_service.dart`

**الوضع الحالي:**
- ✅ مُسجل في `service_locator.dart`
- ❌ لا يُستخدم في معظم remote datasources
- ✅ يحتوي على وظائف جيدة لكنها غير مستخدمة

**الملفات التي يجب أن تستخدمه:**
1. ❌ جميع Remote Datasources
2. ❌ `sync_service.dart`
3. ❌ جميع الـ BLoCs التي تتعامل مع الشبكة
4. ⚠️ `offline_banner.dart` - للعرض

**مثال على الاستخدام المطلوب:**

```dart
class CustomersRemoteDataSource {
  final NetworkService _networkService;
  
  Future<List<CustomerModel>> fetchAll() async {
    // التحقق من الاتصال
    if (!await _networkService.isOnline) {
      throw NoInternetException();
    }
    
    // أو استخدام executeWithConnectivity
    return await _networkService.executeWithConnectivity(
      onOnline: () async {
        final snap = await col(FirebaseConstants.customers).get();
        return snap.docs.map((d) => CustomerModel.fromMap(d.data())).toList();
      },
      onOffline: () {
        throw NoInternetException();
      },
    );
  }
}

// في sync_service
class SyncService {
  final NetworkService _networkService;
  
  Future<void> startSync() async {
    // الانتظار حتى يتوفر الاتصال
    await _networkService.waitForConnection(
      timeout: Duration(seconds: 30),
    );
    
    // بدء المزامنة
    await _syncAllData();
  }
}
```

**الإجراء المطلوب:**
- [ ] إضافة NetworkService إلى جميع remote datasources
- [ ] استخدام فحص الاتصال قبل كل عملية شبكة
- [ ] إضافة `executeWithConnectivity` في العمليات الحرجة
- [ ] استخدام `waitForConnection` في sync_service

---

## 2. الثوابت غير المستخدمة

### 2.1 `app_constants.dart`

**الثوابت المُستخدمة:**
- ✅ `currencySymbol` - في `formatters.dart`
- ✅ `dateFormat`, `displayDateFormat` - في `formatters.dart`
- ✅ `paymentCash`, `paymentCredit`, `paymentTransfer` - في `formatters.dart`
- ✅ `statusPending`, `statusCompleted`, `statusCancelled` - في `formatters.dart`

**الثوابت غير المستخدمة:**
- ❌ `appName`, `appNameEn`, `appVersion`
- ❌ `maxCustomerNameLength`, `maxPhoneLength`, `minPhoneLength`
- ❌ `maxAddressLength`, `maxNotesLength`
- ❌ `maxImageSizeMB`, `maxImagesCount`
- ❌ `autoSyncInterval`, `maxSyncRetries`
- ❌ `connectionTimeout`, `receiveTimeout`
- ❌ `pageSize`, `initialPageSize`
- ❌ `cacheValidityHours`, `maxCacheSizeMB`
- ❌ `maxBackupsCount`, `backupValidityDays`
- ❌ `debtReminderDays`, `minDebtAmount`
- ❌ `maxRating`, `minRating`, `defaultRating`
- ❌ جميع الروابط (supportUrl, privacyPolicyUrl, etc.)
- ❌ رسائل الأخطاء الافتراضية

**الملفات التي يجب أن تستخدمها:**

```dart
// في validators.dart
import '../constants/app_constants.dart';

class Validators {
  static String? validateCustomerName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال اسم العميل';
    }
    if (value.length > AppConstants.maxCustomerNameLength) {
      return 'اسم العميل طويل جداً (الحد الأقصى ${AppConstants.maxCustomerNameLength})';
    }
    return null;
  }
  
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    if (value.length < AppConstants.minPhoneLength || 
        value.length > AppConstants.maxPhoneLength) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }
}

// في sync_service.dart
import '../constants/app_constants.dart';

class SyncService {
  Timer? _autoSyncTimer;
  
  void startAutoSync() {
    _autoSyncTimer = Timer.periodic(
      Duration(minutes: AppConstants.autoSyncInterval),
      (_) => sync(),
    );
  }
  
  Future<void> sync() async {
    int retries = 0;
    while (retries < AppConstants.maxSyncRetries) {
      try {
        await _performSync();
        break;
      } catch (e) {
        retries++;
        if (retries >= AppConstants.maxSyncRetries) {
          rethrow;
        }
      }
    }
  }
}

// في api_client.dart
import '../constants/app_constants.dart';

class ApiClient {
  Dio get dio {
    return Dio(
      BaseOptions(
        connectTimeout: Duration(seconds: AppConstants.connectionTimeout),
        receiveTimeout: Duration(seconds: AppConstants.receiveTimeout),
      ),
    );
  }
}

// في about_screen.dart
import '../../../core/constants/app_constants.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(AppConstants.appName),
          Text('الإصدار: ${AppConstants.appVersion}'),
          TextButton(
            onPressed: () => _launchURL(AppConstants.supportUrl),
            child: Text('الدعم الفني'),
          ),
        ],
      ),
    );
  }
}
```

**الإجراء المطلوب:**
- [ ] استخدام ثوابت التحقق في `validators.dart`
- [ ] استخدام ثوابت المزامنة في `sync_service.dart`
- [ ] استخدام ثوابت الاتصال في `api_client.dart`
- [ ] استخدام ثوابت الصفحات في جميع دوال الترقيم
- [ ] استخدام ثوابت التطبيق في الشاشات المناسبة
- [ ] استخدام الروابط في `about_screen.dart` و `support_screen.dart`

---

### 2.2 `database_constants.dart`

**الوضع الحالي:**
- ✅ يُستخدم بشكل جيد في `base_queries.dart`, `report_queries.dart`, `search_queries.dart`
- ⚠️ لكن الاستعلامات نفسها غير مستخدمة في datasources

**المشكلة:**
الـ datasources تكتب استعلامات SQL مباشرة بدلاً من استخدام الاستعلامات الجاهزة من `base_queries.dart`

**مثال على المشكلة (customer_local_datasource.dart):**

```dart
// ❌ الطريقة الحالية (تكرار)
Future<int> updateDebt(int id, double amount) async {
  final database = await db;
  return await database.rawUpdate(
    'UPDATE ${CustomersTable.table} SET ${CustomersTable.cCurrentDebt} = ${CustomersTable.cCurrentDebt} + ? WHERE ${CustomersTable.cId} = ?',
    [amount, id],
  );
}

// ✅ الطريقة الصحيحة (استخدام base_queries)
Future<int> updateDebt(int id, double amount) async {
  // يجب استخدام دالة من BaseQueries أو إضافة دالة جديدة
}
```

**الإجراء المطلوب:**
- [ ] تدقيق جميع استخدامات `DatabaseConstants` في المشروع
- [ ] التأكد من عدم وجود أسماء جداول وأعمدة مكتوبة مباشرة
- [ ] استبدال جميع القيم الثابتة المكتوبة بثوابت من `DatabaseConstants`

---

### 2.3 `storage_keys.dart`

**الوضع الحالي:**
- ✅ يُستخدم بشكل جيد في `settings_bloc.dart`
- ❌ لا يُستخدم في أماكن أخرى كثيرة

**الملفات التي يجب أن تستخدمه:**
1. ❌ `shared_preferences_service.dart`
2. ❌ `secure_storage_service.dart`
3. ❌ `cache_service.dart`
4. ❌ `auth_bloc.dart`
5. ❌ `app_bloc.dart`
6. ❌ `sync_bloc.dart`
7. ❌ `backup_bloc.dart`

**مثال على الاستخدام المطلوب:**

```dart
// في shared_preferences_service.dart
import '../constants/storage_keys.dart';

class SharedPreferencesService {
  final SharedPreferences _prefs;
  
  // ✅ استخدام StorageKeys بدلاً من strings مباشرة
  Future<void> setLanguage(String language) async {
    await _prefs.setString(StorageKeys.language, language);
  }
  
  String getLanguage() {
    return _prefs.getString(StorageKeys.language) ?? 'ar';
  }
  
  Future<void> setLastSyncTime(DateTime time) async {
    await _prefs.setString(
      StorageKeys.lastSyncTime,
      time.toIso8601String(),
    );
  }
  
  DateTime? getLastSyncTime() {
    final timeString = _prefs.getString(StorageKeys.lastSyncTime);
    return timeString != null ? DateTime.parse(timeString) : null;
  }
}

// في auth_bloc.dart
import '../../../core/constants/storage_keys.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SharedPreferencesService _prefs;
  final SecureStorageService _secureStorage;
  
  Future<void> _onLoginRequested(LoginRequested event, Emitter emit) async {
    try {
      final user = await _authService.login(event.email, event.password);
      
      // حفظ معلومات المستخدم
      await _prefs.setString(StorageKeys.userId, user.id);
      await _prefs.setString(StorageKeys.userEmail, user.email);
      
      // حفظ التوكن بشكل آمن
      await _secureStorage.write(StorageKeys.authToken, user.token);
      
      if (event.rememberMe) {
        await _prefs.setBool(StorageKeys.rememberMe, true);
      }
      
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
```

**الإجراء المطلوب:**
- [ ] إنشاء `shared_preferences_service.dart` إذا لم يكن موجوداً
- [ ] إنشاء `secure_storage_service.dart` إذا لم يكن موجوداً
- [ ] استخدام StorageKeys في جميع عمليات التخزين المحلي
- [ ] استبدال جميع النصوص الثابتة بـ StorageKeys

---

## 3. الاستعلامات غير المستخدمة

### 3.1 `base_queries.dart`

**الوضع الحالي:**
- ✅ الملف موجود ومكتمل
- ❌ لا يُستخدم في أي datasource

**المشكلة:**
جميع الـ local datasources تكتب استعلاماتها مباشرة بدلاً من استخدام `BaseQueries`

**الحل المطلوب:**

```dart
// ❌ الطريقة الحالية في customer_local_datasource.dart
Future<List<CustomerModel>> searchByName(String query) async {
  return await search(
    column: CustomersTable.cName,
    query: query,
    orderBy: '${CustomersTable.cName} COLLATE NOCASE',
  );
}

// ✅ الطريقة الصحيحة باستخدام BaseQueries
import '../../database/queries/base_queries.dart';

Future<List<CustomerModel>> searchByName(String query) async {
  final database = await db;
  final sql = BaseQueries.search(
    tableName,
    [CustomersTable.cName, CustomersTable.cPhone],
    query,
  );
  final results = await database.rawQuery(sql, ['%$query%', '%$query%']);
  return results.map((m) => CustomerModel.fromMap(m)).toList();
}

// مثال آخر - الحصول على جميع السجلات
Future<List<CustomerModel>> getAll() async {
  final database = await db;
  final sql = BaseQueries.selectAll(tableName);
  final results = await database.rawQuery(sql);
  return results.map((m) => CustomerModel.fromMap(m)).toList();
}

// الحصول على سجل واحد
Future<CustomerModel?> getById(int id) async {
  final database = await db;
  final sql = BaseQueries.selectById(tableName);
  final results = await database.rawQuery(sql, [id]);
  if (results.isEmpty) return null;
  return CustomerModel.fromMap(results.first);
}

// الحذف الناعم
Future<int> delete(int id) async {
  final database = await db;
  final now = DateTime.now().toIso8601String();
  final sql = BaseQueries.softDelete(tableName);
  return await database.rawUpdate(sql, [now, id]);
}
```

**الإجراء المطلوب:**
- [ ] مراجعة جميع الـ local datasources
- [ ] استبدال الاستعلامات المكررة باستخدام BaseQueries
- [ ] إضافة دوال جديدة في BaseQueries إذا لزم الأمر
- [ ] تحديث `base_local_datasource.dart` لاستخدام BaseQueries

---

### 3.2 `report_queries.dart`

**الوضع الحالي:**
- ✅ الملف موجود ومكتمل باستعلامات ممتازة
- ❌ لا يُستخدم في `statistics_local_datasource.dart`

**المشكلة:**
`statistics_local_datasource.dart` يستخدم استعلامات بسيطة بينما `report_queries.dart` يحتوي على استعلامات متقدمة

**الحل المطلوب:**

```dart
// في statistics_local_datasource.dart
import '../../database/queries/report_queries.dart';

class StatisticsLocalDataSource {
  // ✅ استخدام ReportQueries
  Future<DailyStatisticsModel?> getDaily(String date) async {
    final database = await db;
    final sql = ReportQueries.dailyStatistics(date);
    final results = await database.rawQuery(sql, [date, date, date, date, date]);
    
    if (results.isEmpty) return null;
    return DailyStatisticsModel.fromQueryResult(results.first);
  }
  
  Future<List<Map<String, dynamic>>> getMonthlyStats(int year, int month) async {
    final database = await db;
    final sql = ReportQueries.monthlyStatistics(year, month);
    final yearStr = year.toString();
    final monthStr = month.toString().padLeft(2, '0');
    
    return await database.rawQuery(sql, [yearStr, monthStr]);
  }
  
  Future<List<Map<String, dynamic>>> getTopCustomers({int limit = 10}) async {
    final database = await db;
    final sql = ReportQueries.topCustomers(limit);
    return await database.rawQuery(sql);
  }
  
  Future<List<Map<String, dynamic>>> getBestSellingProducts({int limit = 10}) async {
    final database = await db;
    final sql = ReportQueries.bestSellingProducts(limit);
    return await database.rawQuery(sql);
  }
  
  Future<List<Map<String, dynamic>>> getProfitAnalysis(
    String startDate,
    String endDate,
  ) async {
    final database = await db;
    final sql = ReportQueries.profitAnalysis(startDate, endDate);
    return await database.rawQuery(sql, [startDate, endDate]);
  }
  
  Future<List<Map<String, dynamic>>> getOverdueDebts() async {
    final database = await db;
    final sql = ReportQueries.overdueDebts();
    return await database.rawQuery(sql);
  }
  
  Future<Map<String, dynamic>> getCashFlowReport(
    String startDate,
    String endDate,
  ) async {
    final database = await db;
    final sql = ReportQueries.cashFlowReport(startDate, endDate);
    final results = await database.rawQuery(sql, [startDate, endDate]);
    
    // معالجة النتائج
    double totalCashIn = 0;
    double totalCashOut = 0;
    
    for (var row in results) {
      totalCashIn += (row['cash_in'] as num).toDouble();
      totalCashOut += (row['cash_out'] as num).toDouble();
    }
    
    return {
      'details': results,
      'totalCashIn': totalCashIn,
      'totalCashOut': totalCashOut,
      'netFlow': totalCashIn - totalCashOut,
    };
  }
}
```

**الإجراء المطلوب:**
- [ ] إضافة جميع دوال التقارير في `statistics_local_datasource.dart`
- [ ] استخدام استعلامات من `ReportQueries`
- [ ] إنشاء use cases مناسبة لكل تقرير
- [ ] إنشاء blocs للتقارير
- [ ] إنشاء شاشات التقارير المقابلة

---

### 3.3 `search_queries.dart`

**الوضع الحالي:**
- ✅ الملف موجود ومكتمل
- ❌ لا يُستخدم في الـ datasources

**الحل المطلوب:**

```dart
// في customer_local_datasource.dart
import '../../database/queries/search_queries.dart';

class CustomerLocalDataSource {
  // ✅ استخدام SearchQueries بدلاً من كتابة الاستعلامات مباشرة
  Future<List<CustomerModel>> searchCustomers(String query) async {
    final database = await db;
    final sql = SearchQueries.searchCustomers();
    final searchTerm = '%$query%';
    final results = await database.rawQuery(
      sql,
      [searchTerm, searchTerm, searchTerm],
    );
    return results.map((m) => CustomerModel.fromMap(m)).toList();
  }
  
  // البحث المتقدم مع فلاتر
  Future<List<CustomerModel>> advancedSearch({
    String? query,
    bool? isBlocked,
    double? minDebt,
    double? maxDebt,
    int? minRating,
  }) async {
    final database = await db;
    final sql = SearchQueries.advancedSearchCustomers(
      isBlocked: isBlocked,
      minDebt: minDebt,
      maxDebt: maxDebt,
      minRating: minRating,
    );
    
    final searchTerm = '%${query ?? ''}%';
    final results = await database.rawQuery(sql, [searchTerm, searchTerm]);
    return results.map((m) => CustomerModel.fromMap(m)).toList();
  }
}

// في global_search_bloc.dart (إذا كان موجوداً)
import '../../../data/database/queries/search_queries.dart';

class GlobalSearchBloc extends Bloc<GlobalSearchEvent, GlobalSearchState> {
  Future<void> _onSearchSubmitted(
    GlobalSearchSubmitted event,
    Emitter emit,
  ) async {
    emit(GlobalSearchLoading());
    
    try {
      final database = await _dbHelper.database;
      final sql = SearchQueries.globalSearch();
      final searchTerm = '%${event.query}%';
      
      final results = await database.rawQuery(
        sql,
        [
          searchTerm, searchTerm, // للعملاء
          searchTerm, searchTerm, // للموردين
          searchTerm, searchTerm, // لأنواع القات
        ],
      );
      
      emit(GlobalSearchLoaded(results));
    } catch (e) {
      emit(GlobalSearchError(e.toString()));
    }
  }
}
```

**الإجراء المطلوب:**
- [ ] استخدام SearchQueries في جميع دوال البحث في datasources
- [ ] إنشاء `global_search_bloc.dart` للبحث الشامل
- [ ] إضافة شاشة بحث شاملة تستخدم `SearchQueries.globalSearch()`
- [ ] إضافة البحث المتقدم في شاشات القوائم

---

## 4. ملفات تحتاج إلى إنشاء

### 4.1 خدمات غير موجودة

#### `shared_preferences_service.dart`
**المسار المقترح:** `lib/core/services/local/shared_preferences_service.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/storage_keys.dart';

class SharedPreferencesService {
  static SharedPreferencesService? _instance;
  static SharedPreferences? _prefs;
  
  SharedPreferencesService._();
  
  static Future<SharedPreferencesService> getInstance() async {
    if (_instance == null) {
      _instance = SharedPreferencesService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }
  
  // دوال للإعدادات
  Future<void> setLanguage(String language) async {
    await _prefs!.setString(StorageKeys.language, language);
  }
  
  String getLanguage() {
    return _prefs!.getString(StorageKeys.language) ?? 'ar';
  }
  
  // دوال المستخدم
  Future<void> setUserId(String id) async {
    await _prefs!.setString(StorageKeys.userId, id);
  }
  
  String? getUserId() {
    return _prefs!.getString(StorageKeys.userId);
  }
  
  // دوال المزامنة
  Future<void> setLastSyncTime(DateTime time) async {
    await _prefs!.setString(
      StorageKeys.lastSyncTime,
      time.toIso8601String(),
    );
  }
  
  DateTime? getLastSyncTime() {
    final timeStr = _prefs!.getString(StorageKeys.lastSyncTime);
    return timeStr != null ? DateTime.parse(timeStr) : null;
  }
  
  // دوال النسخ الاحتياطي
  Future<void> setAutoBackupEnabled(bool enabled) async {
    await _prefs!.setBool(StorageKeys.autoBackupEnabled, enabled);
  }
  
  bool getAutoBackupEnabled() {
    return _prefs!.getBool(StorageKeys.autoBackupEnabled) ?? false;
  }
  
  // مسح جميع البيانات
  Future<void> clear() async {
    await _prefs!.clear();
  }
}
```

#### `secure_storage_service.dart`
**المسار المقترح:** `lib/core/services/local/secure_storage_service.dart`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/storage_keys.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  
  // التوكنات
  Future<void> setAuthToken(String token) async {
    await _storage.write(key: StorageKeys.authToken, value: token);
  }
  
  Future<String?> getAuthToken() async {
    return await _storage.read(key: StorageKeys.authToken);
  }
  
  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }
  
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }
  
  // مفتاح التشفير
  Future<void> setEncryptionKey(String key) async {
    await _storage.write(key: StorageKeys.encryptionKey, value: key);
  }
  
  Future<String?> getEncryptionKey() async {
    return await _storage.read(key: StorageKeys.encryptionKey);
  }
  
  // حذف
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
  
  // مسح الكل
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
```

#### `backup_service.dart`
**المسار المقترح:** `lib/core/services/backup/backup_service.dart`

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../firebase/firebase_storage_service.dart';
import '../local/database_service.dart';
import '../../constants/app_constants.dart';

class BackupService {
  final FirebaseStorageService _storageService;
  final DatabaseService _dbService;
  
  BackupService(this._storageService, this._dbService);
  
  /// إنشاء نسخة احتياطية محلية
  Future<File> createLocalBackup() async {
    final dbPath = await _dbService.getDatabasePath();
    final dbFile = File(dbPath);
    
    // إنشاء مجلد النسخ الاحتياطية
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    
    // اسم الملف
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = '${backupDir.path}/backup_$timestamp.db';
    
    // نسخ قاعدة البيانات
    await dbFile.copy(backupPath);
    
    // حذف النسخ القديمة
    await _cleanOldBackups(backupDir);
    
    return File(backupPath);
  }
  
  /// رفع نسخة احتياطية للسحابة
  Future<String> uploadBackup(File backupFile) async {
    final path = 'backups/${DateTime.now().millisecondsSinceEpoch}.db';
    return await _storageService.uploadFile(
      path: path,
      file: backupFile,
    );
  }
  
  /// استعادة من نسخة احتياطية
  Future<void> restoreBackup(File backupFile) async {
    final dbPath = await _dbService.getDatabasePath();
    await backupFile.copy(dbPath);
    await _dbService.reinitialize();
  }
  
  /// تحميل نسخة احتياطية من السحابة
  Future<File> downloadBackup(String url) async {
    final appDir = await getApplicationDocumentsDirectory();
    final tempPath = '${appDir.path}/temp_backup.db';
    
    return await _storageService.downloadFile(
      path: url,
      localPath: tempPath,
    );
  }
  
  /// حذف النسخ القديمة
  Future<void> _cleanOldBackups(Directory backupDir) async {
    final files = await backupDir.list().toList();
    final backupFiles = files.whereType<File>().toList();
    
    if (backupFiles.length > AppConstants.maxBackupsCount) {
      // فرز حسب التاريخ
      backupFiles.sort((a, b) => 
        a.lastModifiedSync().compareTo(b.lastModifiedSync())
      );
      
      // حذف الأقدم
      final toDelete = backupFiles.length - AppConstants.maxBackupsCount;
      for (var i = 0; i < toDelete; i++) {
        await backupFiles[i].delete();
      }
    }
  }
}
```

#### `export_service.dart`
**المسار المقترح:** `lib/core/services/export/export_service.dart`

```dart
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class ExportService {
  /// تصدير إلى PDF
  Future<File> exportToPdf({
    required String title,
    required List<Map<String, dynamic>> data,
    required List<String> columns,
  }) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: columns,
                data: data.map((row) {
                  return columns.map((col) => row[col]?.toString() ?? '').toList();
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
    
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/export_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
  
  /// تصدير إلى Excel (CSV)
  Future<File> exportToExcel({
    required String title,
    required List<Map<String, dynamic>> data,
    required List<String> columns,
  }) async {
    final buffer = StringBuffer();
    
    // Headers
    buffer.writeln(columns.join(','));
    
    // Data
    for (var row in data) {
      final values = columns.map((col) {
        final value = row[col]?.toString() ?? '';
        // Escape commas
        return value.contains(',') ? '"$value"' : value;
      }).join(',');
      buffer.writeln(values);
    }
    
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(buffer.toString());
    
    return file;
  }
}
```

---

## 5. خطة التنفيذ المقترحة

### المرحلة 1: إصلاح معالجة الأخطاء (أولوية عالية) ⭐⭐⭐
1. [ ] إضافة `ErrorHandler` في جميع repositories
2. [ ] إضافة `ErrorHandler` في جميع remote datasources
3. [ ] تحديث جميع BLoCs لاستخدام معالجة الأخطاء الصحيحة
4. [ ] التأكد من أن جميع الدوال ترجع `Either<Failure, T>`

**الوقت المقدر:** 2-3 أيام

### المرحلة 2: ربط خدمات الشبكة (أولوية عالية) ⭐⭐⭐
1. [ ] إضافة `NetworkService` في جميع remote datasources
2. [ ] إضافة `FirebaseService` في جميع remote datasources
3. [ ] تطبيق فحص الاتصال قبل العمليات البعيدة
4. [ ] استخدام `executeWithConnectivity` في العمليات الحرجة

**الوقت المقدر:** 1-2 يوم

### المرحلة 3: تطوير FirebaseStorageService (أولوية متوسطة) ⭐⭐
1. [ ] تطوير `firebase_storage_service.dart` بدوال كاملة
2. [ ] إنشاء `backup_service.dart`
3. [ ] إنشاء `export_service.dart`
4. [ ] ربط الخدمات في المشروع

**الوقت المقدر:** 2-3 أيام

### المرحلة 4: ربط حل التعارضات (أولوية متوسطة) ⭐⭐
1. [ ] إضافة `ConflictResolver` في repositories
2. [ ] تطبيق منطق كشف وحل التعارضات
3. [ ] اختبار المزامنة مع التعارضات
4. [ ] معالجة حالات التعارض الخاصة

**الوقت المقدر:** 2-3 أيام

### المرحلة 5: استخدام الاستعلامات الجاهزة (أولوية متوسطة) ⭐⭐
1. [ ] تحديث `base_local_datasource.dart` لاستخدام BaseQueries
2. [ ] تحديث جميع local datasources لاستخدام BaseQueries
3. [ ] ربط `statistics_local_datasource.dart` مع ReportQueries
4. [ ] ربط دوال البحث مع SearchQueries

**الوقت المقدر:** 2-3 أيام

### المرحلة 6: استخدام الثوابت (أولوية منخفضة) ⭐
1. [ ] إنشاء `shared_preferences_service.dart`
2. [ ] إنشاء `secure_storage_service.dart`
3. [ ] استخدام StorageKeys في جميع عمليات التخزين
4. [ ] استخدام AppConstants في validators
5. [ ] استخدام AppConstants في sync_service
6. [ ] استخدام AppConstants في api_client
7. [ ] استخدام AppConstants في الشاشات

**الوقت المقدر:** 3-4 أيام

### المرحلة 7: شاشات التقارير (أولوية منخفضة) ⭐
1. [ ] إنشاء use cases للتقارير
2. [ ] إنشاء blocs للتقارير
3. [ ] إنشاء شاشات التقارير
4. [ ] ربط ReportQueries بالشاشات

**الوقت المقدر:** 4-5 أيام

---

## 6. ملخص الإحصائيات

### ملفات تحتاج إلى تعديل: **~50 ملف**

#### حسب الأولوية:
- **أولوية عالية ⭐⭐⭐:** 25 ملف (repositories + remote datasources + blocs)
- **أولوية متوسطة ⭐⭐:** 15 ملف (local datasources + services)
- **أولوية منخفضة ⭐:** 10 ملف (شاشات + constants usage)

#### حسب النوع:
- **Repositories:** 8 ملفات
- **Remote DataSources:** 12 ملف
- **Local DataSources:** 10 ملفات
- **BLoCs:** 10 ملفات
- **Services:** 7 ملفات
- **Screens:** 3 ملفات

### ملفات تحتاج إلى إنشاء: **5 ملفات**
1. `shared_preferences_service.dart`
2. `secure_storage_service.dart`
3. `backup_service.dart`
4. `export_service.dart`
5. `global_search_bloc.dart` (اختياري)

### الوقت الإجمالي المقدر: **16-23 يوم عمل**

---

## 7. ملاحظات مهمة

### احتياطات قبل البدء:
1. ✅ إنشاء نسخة احتياطية من المشروع
2. ✅ إنشاء branch جديد للتعديلات
3. ✅ الالتزام بالنمط الحالي للكود
4. ✅ كتابة اختبارات للوظائف الجديدة

### أولويات العمل:
1. **معالجة الأخطاء (ErrorHandler)** - الأكثر أهمية لأنها تؤثر على استقرار التطبيق
2. **خدمات الشبكة** - مهمة لضمان عمل المزامنة بشكل صحيح
3. **الاستعلامات والثوابت** - تحسينات في الكود وقابلية الصيانة
4. **الخدمات الجديدة** - إضافات اختيارية لكنها مفيدة

### نصائح للتنفيذ:
- ابدأ بملف واحد واختبره قبل الانتقال للتالي
- استخدم Git commit بعد كل تعديل ناجح
- راجع قوائم الترابط الثلاثة قبل كل تعديل
- اختبر المزامنة بعناية بعد كل تغيير
- استخدم TODO comments للتعديلات المؤجلة

---

## 8. قائمة المراجعة السريعة

### للمراجعة بعد كل تعديل:
- [ ] الملف يستورد جميع التبعيات المطلوبة
- [ ] لا توجد imports غير مستخدمة
- [ ] معالجة الأخطاء موجودة وصحيحة
- [ ] الثوابت مستخدمة بدلاً من القيم الثابتة
- [ ] التوثيق موجود للدوال المهمة
- [ ] لا توجد تحذيرات من المحلل
- [ ] الكود يتبع نمط المشروع

---

**تاريخ إنشاء التقرير:** ${DateTime.now().toString().split('.').first}
**الإصدار:** 1.0
**الحالة:** جاهز للتنفيذ
