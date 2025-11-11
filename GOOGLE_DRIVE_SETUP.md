# إعداد Google Drive للنسخ الاحتياطي

## المشكلة الحالية
عند محاولة تسجيل الدخول إلى Google Drive، يظهر خطأ "يجب تسجيل الدخول أولاً" بالرغم من اختيار حساب Gmail.

## السبب
ملف `google-services.json` لا يحتوي على OAuth client credentials (القسم `oauth_client` فارغ).

---

## الحل: إعداد Google Sign-In في Firebase Console

### الخطوة 1: الحصول على SHA-1 من المشروع

افتح Terminal في مجلد المشروع وقم بتنفيذ:

```bash
cd android
./gradlew signingReport
```

أو (للتشغيل السريع):

```bash
cd android
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

ابحث عن **SHA-1** و **SHA-256** وانسخهما.

---

### الخطوة 2: إضافة SHA-1 في Firebase Console

1. افتح [Firebase Console](https://console.firebase.google.com/)
2. اختر مشروع: **daftaralmuqawit**
3. اذهب إلى **Project Settings** (الإعدادات)
4. اختر تبويب **Your apps**
5. اختر تطبيق Android: `com.arma.daftar_almuqawit`
6. انزل إلى قسم **SHA certificate fingerprints**
7. اضغط **Add fingerprint**
8. الصق **SHA-1** الذي حصلت عليه
9. اضغط **Save**

---

### الخطوة 3: تفعيل Google Sign-In في Firebase

1. في Firebase Console، اذهب إلى **Authentication**
2. اختر **Sign-in method**
3. فعّل **Google** Sign-in provider
4. احفظ التغييرات

---

### الخطوة 4: تفعيل Google Drive API في Google Cloud Console

1. افتح [Google Cloud Console](https://console.cloud.google.com/)
2. اختر نفس المشروع: **daftaralmuqawit**
3. اذهب إلى **APIs & Services** > **Library**
4. ابحث عن **Google Drive API**
5. اضغط **Enable**

---

### الخطوة 5: تحديث google-services.json

1. ارجع إلى Firebase Console
2. اذهب إلى **Project Settings**
3. اختر تطبيق Android
4. اضغط **Download google-services.json**
5. استبدل الملف القديم في:
   ```
   android/app/google-services.json
   ```

الملف الجديد سيحتوي على:
```json
{
  "oauth_client": [
    {
      "client_id": "xxx.apps.googleusercontent.com",
      "client_type": 3
    }
  ]
}
```

---

### الخطوة 6: التحقق من AndroidManifest.xml

تأكد من وجود الأذونات في `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

---

### الخطوة 7: إعادة التشغيل

بعد تحديث `google-services.json`:

```bash
# نظف المشروع
flutter clean

# أعد تحميل التبعيات
flutter pub get

# أعد التشغيل
flutter run
```

---

## التحقق من نجاح الإعداد

بعد الإعداد، يجب أن يعمل الكود التالي:

```dart
final driveService = GoogleDriveService.instance;

// تسجيل الدخول
final success = await driveService.signIn();
if (success) {
  print('✅ تم تسجيل الدخول: ${driveService.userEmail}');
  
  // رفع نسخة احتياطية
  final fileId = await driveService.uploadBackup(backupPath);
  print('✅ تم رفع النسخة: $fileId');
} else {
  print('❌ فشل تسجيل الدخول');
}
```

---

## الأخطاء الشائعة

### 1. DEVELOPER_ERROR
**السبب**: SHA-1 غير مضاف في Firebase Console
**الحل**: أضف SHA-1 كما في الخطوة 2

### 2. API not enabled
**السبب**: Google Drive API غير مفعّل
**الحل**: فعّل API كما في الخطوة 4

### 3. oauth_client فارغ
**السبب**: لم يتم تحديث google-services.json بعد إضافة SHA-1
**الحل**: حمّل الملف الجديد من Firebase Console

---

## ملاحظات إضافية

### للنشر على Google Play Store

عندما تنشر التطبيق، ستحتاج إلى:

1. SHA-1 من keystore الإنتاج:
```bash
keytool -list -v -keystore ~/upload-keystore.jks -alias upload
```

2. إضافة SHA-1 الإنتاج في Firebase Console

3. إذا استخدمت Play App Signing، ستحتاج أيضاً SHA-1 من Google Play Console

---

## الفرق بين WhatsApp وتطبيقنا

WhatsApp يستخدم:
- **Google Play Services** المدمج في النظام
- **OAuth 2.0** تلقائي عبر الحساب المسجل في الجهاز

تطبيقنا يحتاج:
- **إعداد صريح** في Firebase Console
- **SHA-1 fingerprint** للمصادقة
- **OAuth credentials** محدد للتطبيق

بعد الإعداد الصحيح، سيعمل بنفس سلاسة WhatsApp!

---

## اختبار سريع

لاختبار ما إذا كانت الإعدادات صحيحة:

```bash
# تشغيل التطبيق
flutter run

# في LogCat ابحث عن:
# ✅ تم تسجيل الدخول بنجاح: example@gmail.com
# أو
# ❌ خطأ في الإعدادات - تحقق من SHA-1 في Firebase Console
```

---

## المساعدة

إذا واجهت مشاكل:
1. تحقق من Logs في LogCat
2. راجع Firebase Console > Authentication > Users
3. تأكد من أن Google Sign-In مفعّل
4. تأكد من أن Google Drive API مفعّل

**رقم المشروع**: 882426821019
**Package Name**: com.arma.daftar_almuqawit
