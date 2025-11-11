/// أحداث Bloc الإعدادات
/// تحتوي على جميع الأحداث المتعلقة بإعدادات التطبيق

/// الحدث الأساسي للإعدادات
abstract class SettingsEvent {}

/// حدث تحميل الإعدادات
class LoadSettings extends SettingsEvent {}

/// حدث تغيير اللغة
class ChangeLanguage extends SettingsEvent {
  final String languageCode;
  ChangeLanguage({required this.languageCode});
}

/// حدث تغيير الثيم
class ChangeTheme extends SettingsEvent {
  final bool isDark;
  ChangeTheme(this.isDark);
}

/// حدث حفظ الإعدادات
class SaveSettings extends SettingsEvent {}

/// حدث تبديل المزامنة التلقائية
class ToggleAutoSync extends SettingsEvent {
  final bool enabled;
  ToggleAutoSync(this.enabled);
}

/// حدث تبديل النسخ الاحتياطي التلقائي
class ToggleAutoBackup extends SettingsEvent {
  final bool enabled;
  ToggleAutoBackup(this.enabled);
}

/// حدث تبديل الإشعارات
class ToggleNotifications extends SettingsEvent {
  final bool enabled;
  ToggleNotifications(this.enabled);
}

/// حدث تبديل الصوت
class ToggleSound extends SettingsEvent {
  final bool enabled;
  ToggleSound(this.enabled);
}
