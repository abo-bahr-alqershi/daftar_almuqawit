# ✅ دليل حل مشكلة Google Drive Sign-In (محدث)

## 🔴 المشكلة الأساسية

```
PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10:
```

**الخطأ رقم 10 = Developer Error** - عدم تطابق Package Name / Bundle ID

---

## 🎯 الحل الكامل (Android + iOS)

### 1️⃣ **إصلاحات Android** ✅

#### المشكلة:
- ❌ `applicationId` في `build.gradle.kts` = `com.example.daftar_almuqawit`
- ✅ `package_name` في `google-services.json` = `com.arma.daftar_almuqawit`

#### الحل المُنفَّذ:

**أ. تحديث build.gradle.kts:**
```kotlin
// android/app/build.gradle.kts
applicationId = "com.arma.daftar_almuqawit" // ✅ تم التغيير
```

**ب. نقل MainActivity:**
```bash
# من
android/app/src/main/kotlin/com/example/daftar_almuqawit/MainActivity.kt

# إلى
android/app/src/main/kotlin/com/arma/daftar_almuqawit/MainActivity.kt
```

**ج. تحديث package في MainActivity.kt:**
```kotlin
package com.arma.daftar_almuqawit // ✅ تم التغيير
```

---

### 2️⃣ **إصلاحات iOS** ✅

#### المشكلة:
- ❌ `PRODUCT_BUNDLE_IDENTIFIER` في `project.pbxproj` = `com.example.daftarAlmuqawit`
- ✅ `BUNDLE_ID` في `GoogleService-Info.plist` = `com.arma.daftaralmuqawit`

#### الحل المُنفَّذ:

**أ. تحديث Bundle ID في project.pbxproj:**
```xml
<!-- تم استبدال جميع المواضع (6 مواضع) -->
PRODUCT_BUNDLE_IDENTIFIER = com.arma.daftaralmuqawit; // ✅
```

**ب. إضافة إعدادات Google Sign-In في Info.plist:**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.882426821019-fqqjs73b92375g5g5rhsbpao9fpregnq</string>
        </array>
    </dict>
</array>
<key>GIDClientID</key>
<string>882426821019-fqqjs73b92375g5g5rhsbpao9fpregnq.apps.googleusercontent.com</string>
```

---

## 📋 التحقق النهائي من التطابق

SHA-1 لجهازك:
```
C6:11:84:37:31:BC:91:23:AA:70:6F:B5:AA:E5:C7:A7:7B:CA:D1:98
```

SHA-256 (اختياري):
```
DD:0B:F5:31:77:36:4D:83:AA:61:ED:40:93:8E:51:07:50:00:25:5E:E2:95:18:F6:DC:A5:97:B7:74:47:F2:B7
```

---

### الخطوة 2: إضافة SHA-1 في Firebase Console

1. افتح [Firebase Console](https://console.firebase.google.com/)

2. اختر المشروع: **daftaralmuqawit**

3. اضغط على أيقونة الإعدادات ⚙️ بجانب "Project Overview"


| الملف/الخاصية | Package/Bundle ID | الحالة |
|---------------|-------------------|--------|
| `google-services.json` | `com.arma.daftar_almuqawit` | ✅ صحيح |
| `build.gradle.kts` → `applicationId` | `com.arma.daftar_almuqawit` | ✅ تم التصحيح |
| `MainActivity.kt` → `package` | `com.arma.daftar_almuqawit` | ✅ تم التصحيح |
| `GoogleService-Info.plist` | `com.arma.daftaralmuqawit` | ✅ صحيح |
| `project.pbxproj` → `BUNDLE_ID` | `com.arma.daftaralmuqawit` | ✅ تم التصحيح |

---

## 🚀 خطوات ما بعد الإصلاح

### 1. تنظيف المشروع:
```bash
flutter clean
cd ios && rm -rf Pods/ Podfile.lock && cd ..
flutter pub get
```

### 2. بناء التطبيق من جديد:

**Android:**
```bash
flutter build apk --debug
# أو
flutter run
```

**iOS (macOS فقط):**
```bash
cd ios
pod install
cd ..
flutter build ios
```

---

## ⚠️ خطوات إضافية مهمة في Google Cloud Console

### إضافة SHA-1 Certificate (Android)

**SHA-1 لجهازك:**
```
C6:11:84:37:31:BC:91:23:AA:70:6F:B5:AA:E5:C7:A7:7B:CA:D1:98
```

**الخطوات:**

1. افتح [Firebase Console](https://console.firebase.google.com/)
2. اختر المشروع: **daftaralmuqawit**
3. اضغط ⚙️ → **Project settings**

3. اضغط ⚙️ → **Project settings**
4. اختر تطبيق Android: `com.arma.daftar_almuqawit`
5. انزل إلى **SHA certificate fingerprints**
6. اضغط **Add fingerprint**
7. الصق SHA-1: `C6:11:84:37:31:BC:91:23:AA:70:6F:B5:AA:E5:C7:A7:7B:CA:D1:98`
8. اضغط **Save**
9. **حمّل google-services.json الجديد** واستبدله في `android/app/`

### تفعيل Google Drive API

1. افتح [Google Cloud Console](https://console.cloud.google.com/)
2. اختر المشروع: **daftaralmuqawit** (رقم: `882426821019`)
3. اذهب إلى **APIs & Services** → **Library**
4. ابحث عن: **Google Drive API**
5. اضغط **Enable**


### تفعيل Google Sign-In في Firebase

1. في Firebase Console → **Authentication**
2. اضغط **Get Started** (إذا لم تكن مفعلة)
3. تبويب **Sign-in method**
4. اضغط **Google** → **Enable**
5. اختر Support email
6. **Save**

---

## 🧪 اختبار التطبيق

### الخطوات:

1. افتح التطبيق
2. اذهب **الإعدادات** → **النسخ الاحتياطي**
3. اضغط زر **نسخ احتياطي إلى Google Drive**
4. اختر حساب Gmail من القائمة
5. يجب أن تظهر:
   ```
   ✅ تم تسجيل الدخول بنجاح
   📤 جاري رفع النسخة الاحتياطية...
   ✅ تم رفع النسخة بنجاح!
   ```

### التحقق من LogCat:

✅ **نجح:**
```
🔐 بدء تسجيل الدخول إلى Google Drive...
✅ تم تسجيل الدخول بنجاح: your.email@gmail.com
📧 البريد: your.email@gmail.com
✅ تم إعداد Drive API بنجاح
📤 جاري رفع الملف إلى Drive...
✅ تم رفع الملف بنجاح!
🆔 File ID: 1abc...xyz
```

❌ **فشل:**
```
❌ فشل تسجيل الدخول إلى Google Drive
PlatformException(sign_in_failed, ApiException: 10)
```

---

## ⚠️ ملاحظات هامة

### Package Name في Android vs iOS

| Platform | Package/Bundle ID | الملف |
|----------|-------------------|-------|
| Android | `com.arma.daftar_almuqawit` | ✅ مع underscore |
| iOS | `com.arma.daftaralmuqawit` | ✅ بدون underscore |

**هذا طبيعي!** Firebase يحول `_` إلى حروف في iOS تلقائياً.

### بعد أي تغيير في Firebase:

1. ⏱️ انتظر 5-10 دقائق
2. 📥 حمّل `google-services.json` الجديد
3. 🧹 نفّذ `flutter clean`
4. 🔨 أعد البناء

---

## 🎉 النتيجة المتوقعة

بعد هذه الإصلاحات:

✅ تسجيل الدخول يعمل على Android  
✅ تسجيل الدخول يعمل على iOS  
✅ رفع النسخ الاحتياطية إلى Google Drive  
✅ استعادة النسخ من Drive  
✅ عرض قائمة النسخ الاحتياطية  
✅ حذف النسخ القديمة  

---

**آخر تحديث**: 2025-11-11  
**الحالة**: ✅ تم إصلاح Android + iOS  
**الإصلاحات**: Package Name + Bundle ID + Info.plist + google-services.json

- تأكد من استبدال الملف القديم
- أعد بناء التطبيق بـ `flutter clean && flutter run`

---

## اختبار سريع

قبل تشغيل التطبيق، تحقق من:

### 1. google-services.json يحتوي على oauth_client
```bash
grep -A 5 "oauth_client" android/app/google-services.json
```

يجب أن يظهر شيء (وليس فارغاً)

### 2. Google Sign-In مفعّل في Firebase
افتح: https://console.firebase.google.com/project/daftaralmuqawit/authentication/providers

يجب أن يكون Google **Enabled**

### 3. Google Drive API مفعّل
افتح: https://console.cloud.google.com/apis/library/drive.googleapis.com?project=daftaralmuqawit

يجب أن يظهر **API enabled**

---

## ملاحظات مهمة

### للتطوير
- استخدم SHA-1 من `debug.keystore` (الذي حصلنا عليه أعلاه)
- يعمل على المحاكي والأجهزة الحقيقية

### للإنتاج (Play Store)
عندما تنشر التطبيق، ستحتاج:

1. SHA-1 من keystore الإنتاج:
```bash
keytool -list -v -keystore ~/upload-keystore.jks -alias upload
```

2. إضافته في Firebase Console (بالإضافة للـ debug SHA-1)

3. إذا استخدمت **Play App Signing**:
   - اذهب إلى Google Play Console
   - Setup → App signing
   - انسخ SHA-1 من **App signing key certificate**
   - أضفه في Firebase Console

---

## دعم إضافي

إذا استمرت المشكلة:

1. **تحقق من Logs:**
```bash
flutter run
# في terminal آخر
adb logcat | grep -i "google\|drive\|sign"
```

2. **تحقق من الحساب:**
   - تأكد من تسجيل الدخول إلى حساب Google في الجهاز
   - اذهب إلى **الإعدادات** → **الحسابات** → **Google**

3. **أعد المحاولة:**
   - احذف بيانات التطبيق
   - أعد تشغيل الجهاز
   - أعد تثبيت التطبيق

4. **جرّب جهاز آخر:**
   - قد تكون المشكلة في الجهاز نفسه

---

## الخلاصة

**الخطوات الأساسية:**
1. ✅ أضف SHA-1 في Firebase Console
2. ✅ فعّل Google Sign-In في Authentication
3. ✅ فعّل Google Drive API في Cloud Console
4. ✅ حمّل `google-services.json` الجديد
5. ✅ نظف وأعد بناء التطبيق

**بعد هذه الخطوات، يجب أن يعمل تسجيل الدخول بنجاح!** 🎉

---

**آخر تحديث:** 2024
**SHA-1:** `C6:11:84:37:31:BC:91:23:AA:70:6F:B5:AA:E5:C7:A7:7B:CA:D1:98`
**Package:** `com.arma.daftar_almuqawit`
**Project ID:** `daftaralmuqawit`
