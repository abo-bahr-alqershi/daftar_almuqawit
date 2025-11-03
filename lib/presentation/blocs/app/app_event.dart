// ignore_for_file: public_member_api_docs

/// أحداث التطبيق العامة
abstract class AppEvent {}

/// حدث بدء التطبيق
class AppStarted extends AppEvent {}

/// حدث تغيير اللغة
class AppLanguageChanged extends AppEvent {
  final String languageCode;
  AppLanguageChanged(this.languageCode);
}

/// حدث تغيير الثيم (فاتح/داكن)
class AppThemeChanged extends AppEvent {
  final bool isDark;
  AppThemeChanged(this.isDark);
}

/// حدث تحديث الإعدادات
class AppSettingsUpdated extends AppEvent {
  final Map<String, dynamic> settings;
  AppSettingsUpdated(this.settings);
}

/// حدث تحديث حالة الاتصال
class AppConnectivityChanged extends AppEvent {
  final bool isConnected;
  AppConnectivityChanged(this.isConnected);
}
