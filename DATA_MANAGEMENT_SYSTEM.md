# نظام إدارة البيانات - المزامنة والنسخ الاحتياطي

## نظرة عامة

تم تطوير نظام متكامل لإدارة البيانات في التطبيق، يوفر:

1. **المزامنة التلقائية** عبر Firebase Storage
2. **النسخ الاحتياطي الآمن** على Google Drive
3. **التخزين المحلي** باستخدام SQLite

---

## الفرق بين المزامنة والنسخ الاحتياطي

### 🔄 المزامنة (Sync)

**الغرض**: تحديث مستمر للبيانات بين جميع أجهزة المستخدم

**التقنية**: Firebase Storage

**الآلية**:
- يتم رفع كل تغيير للسحابة تلقائياً
- يتم تحميل التغييرات من الأجهزة الأخرى
- يعمل في الخلفية بشكل دوري

**الاستخدام**:
```dart
final coordinator = StorageSyncCoordinator.instance;

// مزامنة فورية
final result = await coordinator.syncNow();

// تفعيل المزامنة التلقائية
coordinator.startAutoSync(interval: Duration(minutes: 15));
```

**الملفات المتأثرة**:
- `lib/core/services/firebase/firebase_storage_service.dart`
- `lib/core/services/sync/storage_sync_coordinator.dart`
- `lib/core/services/sync/sync_status_monitor.dart`

---

### 📦 النسخ الاحتياطي (Backup)

**الغرض**: نسخة كاملة للاستعادة عند فقدان البيانات

**التقنية**: Google Drive

**الآلية**:
- نسخة كاملة من قاعدة البيانات (SQLite)
- يُحفظ على Google Drive الخاص بالمستخدم
- يُنفذ يدوياً أو بجدولة

**الاستخدام**:
```dart
final backupService = BackupService();

// إنشاء نسخة احتياطية ورفعها
final fileId = await backupService.createBackupToDrive();

// استعادة من نسخة سابقة
await backupService.restoreFromDrive(fileId);
```

**الملفات المتأثرة**:
- `lib/core/services/backup_service.dart`
- `lib/core/services/google_drive_service.dart`

---

## البنية التقنية

### 1. Firebase Storage Service

**الموقع**: `lib/core/services/firebase/firebase_storage_service.dart`

**المسؤوليات**:
- رفع/تحميل الملفات من/إلى Firebase Storage
- إدارة البيانات المتزامنة في مسار `sync_data/{userId}`
- دعم JSON و binary files

**الدوال الرئيسية**:
```dart
// رفع بيانات JSON
await firebaseStorage.uploadJsonData('sales', documentId, data);

// تحميل بيانات JSON
final data = await firebaseStorage.downloadJsonData('sales', documentId);

// قائمة الملفات المتزامنة
final files = await firebaseStorage.listSyncFiles('sales');
```

---

### 2. Storage Sync Coordinator

**الموقع**: `lib/core/services/sync/storage_sync_coordinator.dart`

**المسؤوليات**:
- تنسيق المزامنة بين SQLite و Firebase Storage
- إدارة المزامنة الثنائية (رفع + تحميل)
- دعم المزامنة التلقائية الدورية

**المجموعات المدعومة**:
- sales (المبيعات)
- purchases (المشتريات)
- customers (العملاء)
- suppliers (الموردون)
- debts (الديون)
- debt_payments (دفعات الديون)
- expenses (المصروفات)
- qat_types (أنواع القات)
- accounts (الحسابات)

**الاستخدام**:
```dart
// مزامنة فورية
final result = await coordinator.syncNow(forceUpload: false);

print('تم رفع: ${result.uploadedCount}');
print('تم تحميل: ${result.downloadedCount}');
print('أخطاء: ${result.errorCount}');

// المزامنة التلقائية
coordinator.startAutoSync(interval: Duration(minutes: 15));
```

---

### 3. Google Drive Service

**الموقع**: `lib/core/services/google_drive_service.dart`

**المسؤوليات**:
- المصادقة مع Google Drive API
- رفع/تحميل ملفات النسخ الاحتياطي
- إدارة النسخ (عرض، حذف، بحث)

**الإعداد المطلوب**:
1. إضافة SHA-1 في Firebase Console
2. تفعيل Google Sign-In
3. تفعيل Google Drive API في Google Cloud Console
4. تحديث `google-services.json`

**راجع**: `GOOGLE_DRIVE_SETUP.md` للتفاصيل الكاملة

**الاستخدام**:
```dart
final driveService = GoogleDriveService.instance;

// تسجيل الدخول
await driveService.signIn();

// رفع نسخة احتياطية
final fileId = await driveService.uploadBackup(filePath);

// قائمة النسخ الاحتياطية
final backups = await driveService.listBackups();

// تحميل نسخة
await driveService.downloadBackup(fileId, localPath);
```

---

### 4. Backup Service

**الموقع**: `lib/core/services/backup_service.dart`

**المسؤوليات**:
- إنشاء نسخ احتياطية من قاعدة البيانات
- الرفع إلى Google Drive
- الاستعادة من النسخ
- جدولة النسخ التلقائي

**الاستخدام**:
```dart
final service = BackupService();

// نسخ محلي
final path = await service.createBackup();

// نسخ + رفع لـ Google Drive
final fileId = await service.createBackupToDrive(
  onUploadProgress: (progress) {
    print('${(progress * 100).toInt()}%');
  },
);

// استعادة
await service.restoreFromDrive(fileId);

// جدولة تلقائي
await service.scheduleAutoBackup(interval: Duration(days: 1));
```

---

### 5. Sync Status Monitor

**الموقع**: `lib/core/services/sync/sync_status_monitor.dart`

**المسؤوليات**:
- مراقبة حالة المزامنة في الوقت الفعلي
- توفير معلومات للواجهة
- إدارة المزامنة من UI

**الاستخدام**:
```dart
final monitor = SyncStatusMonitor();
monitor.startMonitoring();

// في Widget
SyncStatusWidget(
  monitor: monitor,
  builder: (context, status, info) {
    return Text('الحالة: $status');
  },
);

// مزامنة من UI
await monitor.triggerSync();
```

---

## واجهة المستخدم

### Data Management Screen

**الموقع**: `lib/presentation/screens/settings/data_management_screen.dart`

**الميزات**:
1. **تبويب معلومات**: شرح الفرق بين المزامنة والنسخ الاحتياطي
2. **تبويب المزامنة**: 
   - حالة المزامنة الحالية
   - زر مزامنة فورية
   - تفعيل/إيقاف المزامنة التلقائية
3. **تبويب النسخ الاحتياطي**:
   - إدارة حساب Google Drive
   - إنشاء نسخة احتياطية
   - قائمة النسخ المتاحة
   - استعادة من نسخة

**الاستخدام**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const DataManagementScreen(),
  ),
);
```

---

## تدفق العمل

### تدفق المزامنة

```
1. المستخدم يُدخل بيانات جديدة
   ↓
2. تُحفظ في SQLite محلياً
   ↓
3. تُضاف إلى قائمة الانتظار
   ↓
4. StorageSyncCoordinator يرفعها لـ Firebase Storage
   ↓
5. الأجهزة الأخرى تتلقى التحديث
   ↓
6. تُحدّث قاعدة البيانات المحلية
```

### تدفق النسخ الاحتياطي

```
1. المستخدم يطلب نسخ احتياطي
   ↓
2. التحقق من تسجيل الدخول لـ Google Drive
   ↓
3. نسخ قاعدة البيانات محلياً
   ↓
4. رفع الملف إلى Google Drive
   ↓
5. حفظ معرف الملف والتاريخ
   ↓
6. حذف النسخة المحلية المؤقتة
```

---

## مفاتيح التخزين

**الموقع**: `lib/core/constants/storage_keys.dart`

### المزامنة
```dart
StorageKeys.lastSyncTime          // آخر وقت مزامنة
StorageKeys.lastSyncResult        // نتيجة آخر مزامنة
StorageKeys.autoSyncEnabled       // تفعيل المزامنة التلقائية
StorageKeys.syncInterval          // الفترة بين المزامنات
StorageKeys.syncUploadedCount     // عدد العناصر المرفوعة
StorageKeys.syncDownloadedCount   // عدد العناصر المحملة
```

### النسخ الاحتياطي
```dart
StorageKeys.lastBackupTime        // آخر وقت نسخ
StorageKeys.lastBackupFileId      // معرف آخر نسخة في Drive
StorageKeys.autoBackupEnabled     // تفعيل النسخ التلقائي
StorageKeys.backupInterval        // الفترة بين النسخ
StorageKeys.googleDriveSignedIn   // حالة تسجيل الدخول
StorageKeys.googleDriveEmail      // البريد المسجل
```

---

## الأمان والخصوصية

### Firebase Storage
- ✅ مصادقة مطلوبة (Firebase Auth)
- ✅ قواعد أمان: كل مستخدم يصل فقط لبياناته
- ✅ تشفير تلقائي (في النقل والتخزين)

### Google Drive
- ✅ OAuth 2.0 للمصادقة
- ✅ صلاحيات محدودة (DriveFileScope فقط)
- ✅ البيانات في Drive الخاص بالمستخدم فقط

### قاعدة البيانات المحلية
- ✅ SQLite مشفر (يمكن تفعيله)
- ✅ صلاحيات التطبيق محلية فقط

---

## حل المشاكل الشائعة

### المزامنة لا تعمل

**الأعراض**: لا يتم رفع/تحميل البيانات

**الأسباب المحتملة**:
1. لم يتم تسجيل الدخول لـ Firebase
2. لا يوجد اتصال بالإنترنت
3. خطأ في قواعد Firebase Storage Security Rules

**الحل**:
```dart
// تحقق من المصادقة
if (!FirebaseAuth.instance.currentUser != null) {
  await FirebaseAuth.instance.signInAnonymously();
}

// تحقق من الاتصال
final connectivity = await Connectivity().checkConnectivity();

// شغّل المزامنة يدوياً
await coordinator.syncNow();
```

---

### Google Drive يعطي خطأ DEVELOPER_ERROR

**السبب**: SHA-1 غير مضاف في Firebase Console

**الحل**: راجع `GOOGLE_DRIVE_SETUP.md`

---

### النسخ الاحتياطي بطيء

**السبب**: حجم قاعدة البيانات كبير

**الحلول**:
1. حذف البيانات القديمة غير المهمة
2. استخدام WiFi بدلاً من البيانات الخلوية
3. ضغط النسخة الاحتياطية (مُفعّل تلقائياً)

---

## الاختبار

### اختبار المزامنة

```dart
test('sync uploads new sales', () async {
  // أضف بيع جديد
  await salesRepo.add(sale);
  
  // شغّل المزامنة
  final result = await coordinator.syncNow();
  
  // تحقق من النتيجة
  expect(result.uploadedCount, 1);
  expect(result.success, true);
});
```

### اختبار النسخ الاحتياطي

```dart
test('backup creates file in Google Drive', () async {
  // سجّل الدخول
  await driveService.signIn();
  
  // أنشئ نسخة
  final fileId = await backupService.createBackupToDrive();
  
  // تحقق من وجود الملف
  final backups = await driveService.listBackups();
  expect(backups.any((b) => b.id == fileId), true);
});
```

---

## الأداء

### المزامنة
- **الحجم**: JSON compacted (حجم صغير)
- **التكرار**: كل 15 دقيقة (قابل للتخصيص)
- **الاستهلاك**: منخفض (فقط البيانات المتغيرة)

### النسخ الاحتياطي
- **الحجم**: قاعدة بيانات كاملة (~1-10 MB)
- **التكرار**: يومي أو يدوي
- **الاستهلاك**: متوسط (نسخة كاملة)

---

## التطوير المستقبلي

### المزامنة
- [ ] دعم الصور والملفات الكبيرة
- [ ] مزامنة انتقائية (اختيار المجموعات)
- [ ] Conflict resolution متقدم
- [ ] Delta sync (فقط التغييرات)

### النسخ الاحتياطي
- [ ] تشفير النسخ الاحتياطية
- [ ] النسخ إلى Dropbox/OneDrive
- [ ] نسخ احتياطي تزايدي (incremental)
- [ ] استعادة انتقائية (جداول محددة)

---

## المراجع

- [Firebase Storage Documentation](https://firebase.google.com/docs/storage)
- [Google Drive API Documentation](https://developers.google.com/drive)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [SQLite in Flutter](https://pub.dev/packages/sqflite)

---

## الدعم

للمشاكل والاستفسارات:
1. راجع `GOOGLE_DRIVE_SETUP.md` للإعداد
2. تحقق من Logs في LogCat
3. راجع هذا الملف للفهم العام

---

**آخر تحديث**: 2024
**الإصدار**: 1.0.0
