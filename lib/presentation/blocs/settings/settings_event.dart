/// أحداث Bloc الإعدادات
/// تحتوي على جميع الأحداث المتعلقة بإعدادات التطبيق

/// الحدث الأساسي للإعدادات
abstract class SettingsEvent {}

/// حدث تحميل الإعدادات
class LoadSettings extends SettingsEvent {}

/// حدث تغيير اللغة
class ChangeLanguage extends SettingsEvent {
  final String languageCode;
  ChangeLanguage(this.languageCode);
}

/// حدث تغيير الثيم
class ChangeTheme extends SettingsEvent {
  final bool isDark;
  ChangeTheme(this.isDark);
}

/// حدث حفظ الإعدادات
class SaveSettings extends SettingsEvent {}
