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
  
  // إعدادات المزامنة (Firebase Storage)
  static const String lastSyncTime = 'last_sync_time';
  static const String lastSyncResult = 'last_sync_result';
  static const String autoSyncEnabled = 'auto_sync_enabled';
  static const String syncInterval = 'sync_interval';
  static const String wifiOnlySync = 'wifi_only_sync';
  static const String syncUploadedCount = 'sync_uploaded_count';
  static const String syncDownloadedCount = 'sync_downloaded_count';
  static const String syncErrorCount = 'sync_error_count';
  
  // إعدادات النسخ الاحتياطي (Google Drive)
  static const String lastBackupTime = 'last_backup_time';
  static const String lastBackupFileId = 'last_backup_file_id';
  static const String autoBackupEnabled = 'auto_backup_enabled';
  static const String backupInterval = 'backup_interval';
  static const String backupLocation = 'backup_location';
  static const String googleDriveSignedIn = 'google_drive_signed_in';
  static const String googleDriveEmail = 'google_drive_email';
  
  // إعدادات الإشعارات
  static const String notificationsEnabled = 'notifications_enabled';
  static const String debtRemindersEnabled = 'debt_reminders_enabled';
  static const String reminderTime = 'reminder_time';
  
  // إعدادات العرض
  static const String currencySymbol = 'currency_symbol';
  static const String dateFormat = 'date_format';
  static const String useArabicNumbers = 'use_arabic_numbers';
  static const String showDecimals = 'show_decimals';
  static const String learningModeEnabled = 'learning_mode_enabled';
  
  // التخزين الآمن (SecureStorage)
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String encryptionKey = 'encryption_key';
  static const String biometricEnabled = 'biometric_enabled';
  
  // ذاكرة التخزين المؤقت
  static const String cacheVersion = 'cache_version';
  static const String lastClearTime = 'last_clear_time';
}
