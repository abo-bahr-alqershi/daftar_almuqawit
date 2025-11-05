// ignore_for_file: public_member_api_docs

/// مفاتيح التخزين المحلي (SharedPreferences/SecureStorage)
class StorageKeys {
  StorageKeys._();

  // إعدادات التطبيق
  static const String language = 'language';
  static const String themeMode = 'theme_mode';
  static const String onboarded = 'onboarded';
  static const String firstRun = 'first_run';
  
  // إعدادات المستخدم
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String userPhone = 'user_phone';
  static const String userPhoto = 'user_photo';
  static const String rememberMe = 'remember_me';
  
  // إعدادات المزامنة
  static const String lastSyncTime = 'last_sync_time';
  static const String autoSyncEnabled = 'auto_sync_enabled';
  static const String syncInterval = 'sync_interval';
  static const String wifiOnlySync = 'wifi_only_sync';
  
  // إعدادات النسخ الاحتياطي
  static const String lastBackupTime = 'last_backup_time';
  static const String autoBackupEnabled = 'auto_backup_enabled';
  static const String backupInterval = 'backup_interval';
  static const String backupLocation = 'backup_location';
  
  // إعدادات الإشعارات
  static const String notificationsEnabled = 'notifications_enabled';
  static const String debtRemindersEnabled = 'debt_reminders_enabled';
  static const String reminderTime = 'reminder_time';
  
  // إعدادات العرض
  static const String currencySymbol = 'currency_symbol';
  static const String dateFormat = 'date_format';
  static const String useArabicNumbers = 'use_arabic_numbers';
  static const String showDecimals = 'show_decimals';
  
  // التخزين الآمن (SecureStorage)
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String encryptionKey = 'encryption_key';
  static const String biometricEnabled = 'biometric_enabled';
  
  // ذاكرة التخزين المؤقت
  static const String cacheVersion = 'cache_version';
  static const String lastClearTime = 'last_clear_time';
}
