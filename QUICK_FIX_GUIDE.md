# دليل الإصلاح السريع - ترابط الملفات

## 📋 ملخص المشاكل الرئيسية

### 1. ❌ الملفات غير المستخدمة بشكل كافٍ:
- `error_handler.dart` - موجود لكن لا يُستخدم في معالجة الأخطاء
- `network_service.dart` - لا يُستخدم في remote datasources
- `firebase_storage_service.dart` - فارغ تقريباً ولا يُستخدم
- `conflict_resolver.dart` - لا يُستخدم في repositories
- `base_queries.dart`, `report_queries.dart`, `search_queries.dart` - لا تُستخدم في datasources

### 2. ❌ الثوابت غير المستخدمة:
- معظم ثوابت `app_constants.dart` غير مستخدمة
- `storage_keys.dart` يُستخدم فقط في مكان واحد
- `database_constants.dart` يُستخدم في الاستعلامات لكن الاستعلامات نفسها غير مستخدمة

### 3. ❌ ملفات مفقودة:
- `shared_preferences_service.dart` - غير موجود
- `secure_storage_service.dart` - غير موجود
- `backup_service.dart` - غير موجود
- `export_service.dart` - غير موجود

---

## 🚀 خطة الإصلاح السريعة (3 مراحل)

### 📍 المرحلة 1: الإصلاحات الحرجة (يومان)

#### أ. إضافة ErrorHandler في Repositories

**الملفات المطلوب تعديلها:** جميع ملفات `*_repository_impl.dart` في `lib/data/repositories/`

**الإضافات المطلوبة:**

```dart
// في بداية كل repository
import 'package:dartz/dartz.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/errors/failures.dart';

// في كل دالة
Future<Either<Failure, YourType>> yourFunction() async {
  try {
    // ... your code
    return Right(result);
  } catch (e, stackTrace) {
    return Left(ErrorHandler.handleException(e, stackTrace));
  }
}
```

**قائمة الملفات:**
- [ ] `customer_repository_impl.dart`
- [ ] `supplier_repository_impl.dart`
- [ ] `sales_repository_impl.dart`
- [ ] `purchase_repository_impl.dart`
- [ ] `debt_repository_impl.dart`
- [ ] `expense_repository_impl.dart`
- [ ] `accounting_repository_impl.dart`
- [ ] `statistics_repository_impl.dart`

#### ب. إضافة NetworkService في Remote DataSources

**الملفات المطلوب تعديلها:** جميع `*_remote_datasource.dart` في `lib/data/datasources/remote/`

**الإضافات:**

```dart
// في constructor
class YourRemoteDataSource {
  final NetworkService _networkService;
  final FirestoreService _firestoreService;
  
  YourRemoteDataSource(this._networkService, this._firestoreService);
  
  // في كل دالة
  Future<List<YourModel>> fetchAll() async {
    if (!await _networkService.isOnline) {
      throw NoInternetException();
    }
    // ... rest of code
  }
}
```

**تحديث service_locator.dart:**

```dart
// إضافة NetworkService كمعامل
sl.registerLazySingleton<CustomersRemoteDataSource>(
  () => CustomersRemoteDataSource(
    sl<NetworkService>(),  // إضافة هذا
    sl<FirestoreService>(),
  ),
);
```

**قائمة الملفات:**
- [ ] `customers_remote_datasource.dart`
- [ ] `suppliers_remote_datasource.dart`
- [ ] `sales_remote_datasource.dart`
- [ ] `purchases_remote_datasource.dart`
- [ ] `debts_remote_datasource.dart`
- [ ] وباقي الملفات...

---

### 📍 المرحلة 2: الخدمات المفقودة (3 أيام)

#### أ. إنشاء shared_preferences_service.dart

**المسار:** `lib/core/services/local/shared_preferences_service.dart`

**الكود الكامل:**

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/storage_keys.dart';

class SharedPreferencesService {
  final SharedPreferences _prefs;
  
  SharedPreferencesService(this._prefs);
  
  // Language
  Future<void> setLanguage(String language) async {
    await _prefs.setString(StorageKeys.language, language);
  }
  
  String getLanguage() => _prefs.getString(StorageKeys.language) ?? 'ar';
  
  // Theme
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(StorageKeys.themeMode, mode);
  }
  
  String getThemeMode() => _prefs.getString(StorageKeys.themeMode) ?? 'light';
  
  // User
  Future<void> setUserId(String id) async {
    await _prefs.setString(StorageKeys.userId, id);
  }
  
  String? getUserId() => _prefs.getString(StorageKeys.userId);
  
  // Sync
  Future<void> setLastSyncTime(DateTime time) async {
    await _prefs.setString(StorageKeys.lastSyncTime, time.toIso8601String());
  }
  
  DateTime? getLastSyncTime() {
    final str = _prefs.getString(StorageKeys.lastSyncTime);
    return str != null ? DateTime.parse(str) : null;
  }
  
  Future<void> setAutoSyncEnabled(bool enabled) async {
    await _prefs.setBool(StorageKeys.autoSyncEnabled, enabled);
  }
  
  bool getAutoSyncEnabled() => 
    _prefs.getBool(StorageKeys.autoSyncEnabled) ?? true;
  
  // Backup
  Future<void> setAutoBackupEnabled(bool enabled) async {
    await _prefs.setBool(StorageKeys.autoBackupEnabled, enabled);
  }
  
  bool getAutoBackupEnabled() => 
    _prefs.getBool(StorageKeys.autoBackupEnabled) ?? false;
  
  Future<void> clear() async {
    await _prefs.clear();
  }
}
```

**تسجيل في service_locator.dart:**

```dart
// في setupServiceLocator
final prefs = await SharedPreferences.getInstance();
sl.registerLazySingleton<SharedPreferencesService>(
  () => SharedPreferencesService(prefs),
);
```

#### ب. إنشاء secure_storage_service.dart

**المسار:** `lib/core/services/local/secure_storage_service.dart`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/storage_keys.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;
  
  SecureStorageService(this._storage);
  
  // Auth Token
  Future<void> setAuthToken(String token) async {
    await _storage.write(key: StorageKeys.authToken, value: token);
  }
  
  Future<String?> getAuthToken() async {
    return await _storage.read(key: StorageKeys.authToken);
  }
  
  Future<void> deleteAuthToken() async {
    await _storage.delete(key: StorageKeys.authToken);
  }
  
  // Refresh Token
  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }
  
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }
  
  // Encryption Key
  Future<void> setEncryptionKey(String key) async {
    await _storage.write(key: StorageKeys.encryptionKey, value: key);
  }
  
  Future<String?> getEncryptionKey() async {
    return await _storage.read(key: StorageKeys.encryptionKey);
  }
  
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
```

**تسجيل:**

```dart
sl.registerLazySingleton<SecureStorageService>(
  () => SecureStorageService(const FlutterSecureStorage()),
);
```

#### ج. تطوير firebase_storage_service.dart

**استبدال المحتوى الحالي:**

```dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../errors/exceptions.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FirebaseStorage get instance => _storage;
  
  /// رفع ملف
  Future<String> uploadFile({
    required String path,
    required File file,
    void Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref(path);
      final task = ref.putFile(file);
      
      if (onProgress != null) {
        task.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      
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
  
  /// الحصول على رابط التحميل
  Future<String> getDownloadUrl(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } catch (e) {
      throw StorageException('فشل الحصول على الرابط: ${e.toString()}');
    }
  }
  
  /// قائمة الملفات في مجلد
  Future<List<String>> listFiles(String path) async {
    try {
      final result = await _storage.ref(path).listAll();
      return result.items.map((ref) => ref.fullPath).toList();
    } catch (e) {
      throw StorageException('فشل جلب قائمة الملفات: ${e.toString()}');
    }
  }
}
```

#### د. إنشاء backup_service.dart

**المسار:** `lib/core/services/backup/backup_service.dart`

**محتوى الملف في التقرير الشامل** (FILE_CONNECTIVITY_FIX_REPORT.md)

**تسجيل:**

```dart
sl.registerLazySingleton<BackupService>(
  () => BackupService(
    sl<FirebaseStorageService>(),
    sl<DatabaseService>(),
  ),
);
```

---

### 📍 المرحلة 3: الاستعلامات والثوابت (3 أيام)

#### أ. استخدام BaseQueries في Local DataSources

**مثال التعديل في customer_local_datasource.dart:**

```dart
import '../../database/queries/base_queries.dart';

class CustomerLocalDataSource extends BaseLocalDataSource<CustomerModel> {
  // ... existing code
  
  // ✅ استبدال الدوال القديمة
  @override
  Future<List<CustomerModel>> getAll() async {
    final database = await db;
    final sql = BaseQueries.selectAll(tableName);
    final results = await database.rawQuery(sql);
    return results.map((m) => CustomerModel.fromMap(m)).toList();
  }
  
  @override
  Future<CustomerModel?> getById(int id) async {
    final database = await db;
    final sql = BaseQueries.selectById(tableName);
    final results = await database.rawQuery(sql, [id]);
    if (results.isEmpty) return null;
    return CustomerModel.fromMap(results.first);
  }
  
  @override
  Future<int> delete(int id) async {
    final database = await db;
    final now = DateTime.now().toIso8601String();
    final sql = BaseQueries.softDelete(tableName);
    return await database.rawUpdate(sql, [now, id]);
  }
  
  Future<List<CustomerModel>> search(String query) async {
    final database = await db;
    final sql = BaseQueries.search(
      tableName,
      [CustomersTable.cName, CustomersTable.cPhone, CustomersTable.cAddress],
      query,
    );
    final searchTerm = '%$query%';
    final results = await database.rawQuery(
      sql,
      [searchTerm, searchTerm, searchTerm],
    );
    return results.map((m) => CustomerModel.fromMap(m)).toList();
  }
}
```

**كرر نفس النمط في:**
- [ ] `supplier_local_datasource.dart`
- [ ] `sales_local_datasource.dart`
- [ ] `purchase_local_datasource.dart`
- [ ] `debt_local_datasource.dart`
- [ ] وباقي الملفات...

#### ب. استخدام SearchQueries

**مثال في customer_local_datasource.dart:**

```dart
import '../../database/queries/search_queries.dart';

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

Future<List<CustomerModel>> advancedSearchCustomers({
  String? query,
  bool? isBlocked,
  double? minDebt,
  double? maxDebt,
}) async {
  final database = await db;
  final sql = SearchQueries.advancedSearchCustomers(
    isBlocked: isBlocked,
    minDebt: minDebt,
    maxDebt: maxDebt,
  );
  final searchTerm = '%${query ?? ''}%';
  final results = await database.rawQuery(sql, [searchTerm, searchTerm]);
  return results.map((m) => CustomerModel.fromMap(m)).toList();
}
```

#### ج. استخدام ReportQueries

**في statistics_local_datasource.dart:**

```dart
import '../../database/queries/report_queries.dart';

Future<Map<String, dynamic>> getDailyStatistics(String date) async {
  final database = await db;
  final sql = ReportQueries.dailyStatistics(date);
  final results = await database.rawQuery(sql, [date, date, date, date, date]);
  
  if (results.isEmpty) return {};
  return results.first;
}

Future<List<Map<String, dynamic>>> getTopCustomers(int limit) async {
  final database = await db;
  final sql = ReportQueries.topCustomers(limit);
  return await database.rawQuery(sql);
}

Future<List<Map<String, dynamic>>> getBestSellingProducts(int limit) async {
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
```

#### د. استخدام AppConstants

**في validators.dart:**

```dart
import '../constants/app_constants.dart';

class Validators {
  static String? validateCustomerName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال اسم العميل';
    }
    if (value.length > AppConstants.maxCustomerNameLength) {
      return 'الاسم طويل جداً (الحد الأقصى ${AppConstants.maxCustomerNameLength})';
    }
    return null;
  }
  
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    if (value.length < AppConstants.minPhoneLength || 
        value.length > AppConstants.maxPhoneLength) {
      return 'رقم الهاتف يجب أن يكون بين ${AppConstants.minPhoneLength} و ${AppConstants.maxPhoneLength} رقم';
    }
    return null;
  }
  
  static String? validateAddress(String? value) {
    if (value != null && value.length > AppConstants.maxAddressLength) {
      return 'العنوان طويل جداً';
    }
    return null;
  }
  
  static String? validateNotes(String? value) {
    if (value != null && value.length > AppConstants.maxNotesLength) {
      return 'الملاحظات طويلة جداً';
    }
    return null;
  }
}
```

**في sync_service.dart:**

```dart
import '../constants/app_constants.dart';

class SyncService {
  Timer? _autoSyncTimer;
  int _retryCount = 0;
  
  void startAutoSync() {
    _autoSyncTimer = Timer.periodic(
      Duration(minutes: AppConstants.autoSyncInterval),
      (_) => _performSync(),
    );
  }
  
  Future<void> _performSync() async {
    _retryCount = 0;
    while (_retryCount < AppConstants.maxSyncRetries) {
      try {
        await _syncAllData();
        _retryCount = 0;
        break;
      } catch (e) {
        _retryCount++;
        if (_retryCount >= AppConstants.maxSyncRetries) {
          _logger.error('فشلت المزامنة بعد ${AppConstants.maxSyncRetries} محاولات');
          rethrow;
        }
        await Future.delayed(Duration(seconds: 5 * _retryCount));
      }
    }
  }
}
```

**في api_client.dart:**

```dart
import '../constants/app_constants.dart';

Dio get dio {
  return Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: AppConstants.connectionTimeout),
      receiveTimeout: Duration(seconds: AppConstants.receiveTimeout),
    ),
  );
}
```

---

## ✅ قائمة المراجعة النهائية

### المرحلة 1 (يومان):
- [ ] إضافة ErrorHandler في 8 repositories
- [ ] إضافة NetworkService في 12 remote datasources
- [ ] تحديث service_locator.dart

### المرحلة 2 (3 أيام):
- [ ] إنشاء shared_preferences_service.dart
- [ ] إنشاء secure_storage_service.dart
- [ ] تطوير firebase_storage_service.dart
- [ ] إنشاء backup_service.dart
- [ ] تسجيل جميع الخدمات الجديدة

### المرحلة 3 (3 أيام):
- [ ] استخدام BaseQueries في 10 local datasources
- [ ] استخدام SearchQueries في دوال البحث
- [ ] استخدام ReportQueries في statistics_local_datasource
- [ ] استخدام AppConstants في validators
- [ ] استخدام AppConstants في sync_service
- [ ] استخدام AppConstants في api_client

---

## 🎯 نصائح التنفيذ

1. **ابدأ بالمرحلة 1** - هي الأهم لاستقرار التطبيق
2. **اختبر بعد كل تعديل** - لا تنتقل للملف التالي حتى تتأكد
3. **استخدم Git Commit** - بعد كل ملف ناجح
4. **راجع التقرير الشامل** - للتفاصيل الكاملة في `FILE_CONNECTIVITY_FIX_REPORT.md`
5. **لا تستعجل** - الدقة أهم من السرعة

---

## 📞 في حالة المشاكل

إذا واجهت أي مشاكل:
1. راجع قوائم الترابط الثلاثة
2. راجع التقرير الشامل (FILE_CONNECTIVITY_FIX_REPORT.md)
3. تأكد من imports الصحيحة
4. تأكد من تسجيل الخدمات في service_locator

**الوقت الإجمالي المتوقع:** 8 أيام عمل
