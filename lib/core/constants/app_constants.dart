/// ثوابت عامة للتطبيق
/// 
/// يحتوي على جميع الثوابت المستخدمة في التطبيق
class AppConstants {
  AppConstants._();

  // ========== معلومات التطبيق ==========
  
  /// اسم التطبيق
  static const String appName = 'دفتر المقاوت';
  
  /// اسم التطبيق بالإنجليزية
  static const String appNameEn = 'Daftar AlMuqawit';
  
  /// إصدار التطبيق
  static const String appVersion = '1.0.0';
  
  /// رقم البناء
  static const int buildNumber = 1;
  
  /// معرف الحزمة
  static const String packageName = 'com.daftaralmuqawit.app';

  // ========== اللغات المدعومة ==========
  
  /// اللغة العربية
  static const String languageAr = 'ar';
  
  /// اللغة الإنجليزية
  static const String languageEn = 'en';
  
  /// اللغة الافتراضية
  static const String defaultLanguage = languageAr;
  
  /// قائمة اللغات المدعومة
  static const List<String> supportedLanguages = [languageAr, languageEn];

  // ========== العملات ==========
  
  /// الريال اليمني
  static const String currencyYER = 'YER';
  
  /// رمز الريال اليمني
  static const String currencySymbol = 'ر.ي';
  
  /// العملة الافتراضية
  static const String defaultCurrency = currencyYER;

  // ========== التنسيقات ==========
  
  /// تنسيق التاريخ الافتراضي
  static const String dateFormat = 'yyyy-MM-dd';
  
  /// تنسيق التاريخ والوقت
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  
  /// تنسيق الوقت
  static const String timeFormat = 'HH:mm';
  
  /// تنسيق التاريخ للعرض (عربي)
  static const String displayDateFormat = 'dd/MM/yyyy';
  
  /// تنسيق التاريخ والوقت للعرض
  static const String displayDateTimeFormat = 'dd/MM/yyyy - HH:mm';

  // ========== الحدود والقيود ==========
  
  /// الحد الأقصى لطول اسم العميل
  static const int maxCustomerNameLength = 50;
  
  /// الحد الأقصى لطول رقم الهاتف
  static const int maxPhoneLength = 15;
  
  /// الحد الأدنى لطول رقم الهاتف
  static const int minPhoneLength = 9;
  
  /// الحد الأقصى لطول العنوان
  static const int maxAddressLength = 200;
  
  /// الحد الأقصى لطول الملاحظات
  static const int maxNotesLength = 500;
  
  /// الحد الأقصى لحجم الصورة (بالميجابايت)
  static const double maxImageSizeMB = 5.0;
  
  /// الحد الأقصى لعدد الصور
  static const int maxImagesCount = 5;

  // ========== إعدادات المزامنة ==========
  
  /// مدة المزامنة التلقائية (بالدقائق)
  static const int autoSyncInterval = 15;
  
  /// عدد محاولات إعادة المزامنة
  static const int maxSyncRetries = 3;
  
  /// مهلة الاتصال (بالثواني)
  static const int connectionTimeout = 30;
  
  /// مهلة الاستقبال (بالثواني)
  static const int receiveTimeout = 30;

  // ========== إعدادات الصفحات ==========
  
  /// عدد العناصر في الصفحة الواحدة
  static const int pageSize = 20;
  
  /// عدد العناصر في التحميل الأولي
  static const int initialPageSize = 50;

  // ========== إعدادات التخزين المؤقت ==========
  
  /// مدة صلاحية التخزين المؤقت (بالساعات)
  static const int cacheValidityHours = 24;
  
  /// الحد الأقصى لحجم التخزين المؤقت (بالميجابايت)
  static const double maxCacheSizeMB = 100.0;

  // ========== إعدادات النسخ الاحتياطي ==========
  
  /// عدد النسخ الاحتياطية المحفوظة
  static const int maxBackupsCount = 5;
  
  /// مدة صلاحية النسخة الاحتياطية (بالأيام)
  static const int backupValidityDays = 30;

  // ========== إعدادات التقارير ==========
  
  /// عدد الأيام في التقرير الأسبوعي
  static const int weeklyReportDays = 7;
  
  /// عدد الأيام في التقرير الشهري
  static const int monthlyReportDays = 30;
  
  /// عدد الأيام في التقرير السنوي
  static const int yearlyReportDays = 365;

  // ========== إعدادات الديون ==========
  
  /// عدد الأيام قبل التذكير بالدين
  static const int debtReminderDays = 3;
  
  /// الحد الأدنى للدين المستحق
  static const double minDebtAmount = 1.0;

  // ========== إعدادات التقييم ==========
  
  /// الحد الأقصى للتقييم
  static const int maxRating = 5;
  
  /// الحد الأدنى للتقييم
  static const int minRating = 1;
  
  /// التقييم الافتراضي
  static const int defaultRating = 3;

  // ========== أنواع الدفع ==========
  
  /// نقدي
  static const String paymentCash = 'cash';
  
  /// آجل
  static const String paymentCredit = 'credit';
  
  /// محفظة
  static const String paymentTransfer = 'transfer';
  
  /// قائمة أنواع الدفع
  static const List<String> paymentTypes = [
    paymentCash,
    paymentCredit,
    paymentTransfer,
  ];

  // ========== حالات الطلب ==========
  
  /// معلق
  static const String statusPending = 'pending';
  
  /// مكتمل
  static const String statusCompleted = 'completed';
  
  /// ملغي
  static const String statusCancelled = 'cancelled';
  
  /// قيد المعالجة
  static const String statusProcessing = 'processing';

  // ========== روابط مهمة ==========
  
  /// رابط الدعم الفني
  static const String supportUrl = 'https://daftaralmuqawit.com/support';
  
  /// رابط سياسة الخصوصية
  static const String privacyPolicyUrl = 'https://daftaralmuqawit.com/privacy';
  
  /// رابط شروط الاستخدام
  static const String termsOfServiceUrl = 'https://daftaralmuqawit.com/terms';
  
  /// البريد الإلكتروني للدعم
  static const String supportEmail = 'support@daftaralmuqawit.com';
  
  /// رقم الواتساب للدعم
  static const String supportWhatsApp = '+967777777777';

  // ========== مفاتيح التخزين المحلي ==========
  
  /// مفتاح اللغة
  static const String keyLanguage = 'language';
  
  /// مفتاح الثيم
  static const String keyTheme = 'theme';
  
  /// مفتاح أول تشغيل
  static const String keyFirstRun = 'first_run';
  
  /// مفتاح آخر مزامنة
  static const String keyLastSync = 'last_sync';
  
  /// مفتاح معلومات المستخدم
  static const String keyUserInfo = 'user_info';

  // ========== رسائل افتراضية ==========
  
  /// رسالة خطأ عامة
  static const String errorGeneral = 'حدث خطأ غير متوقع';
  
  /// رسالة عدم وجود اتصال
  static const String errorNoConnection = 'لا يوجد اتصال بالإنترنت';
  
  /// رسالة انتهاء الجلسة
  static const String errorSessionExpired = 'انتهت صلاحية الجلسة';
  
  /// رسالة نجاح العملية
  static const String successMessage = 'تمت العملية بنجاح';
  
  /// رسالة تأكيد الحذف
  static const String confirmDelete = 'هل أنت متأكد من الحذف؟';
}
