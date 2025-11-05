part of 'app_settings_bloc.dart';

/// أحداث إعدادات التطبيق
abstract class AppSettingsEvent extends Equatable {
  const AppSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// حدث تحميل الإعدادات
class LoadSettings extends AppSettingsEvent {}

/// حدث تغيير اللغة
class ChangeLanguage extends AppSettingsEvent {
  final String languageCode;
  
  const ChangeLanguage({required this.languageCode});
  
  @override
  List<Object?> get props => [languageCode];
}

/// حدث تبديل وضع الثيم
class ToggleThemeMode extends AppSettingsEvent {
  final bool? isDarkMode;
  
  const ToggleThemeMode({this.isDarkMode});
  
  @override
  List<Object?> get props => [isDarkMode];
}

/// حدث تحديث إعدادات الإشعارات
class UpdateNotificationSettings extends AppSettingsEvent {
  final bool enabled;
  
  const UpdateNotificationSettings({required this.enabled});
  
  @override
  List<Object?> get props => [enabled];
}

/// حدث تحديث العملة
class UpdateCurrency extends AppSettingsEvent {
  final String currency;
  
  const UpdateCurrency({required this.currency});
  
  @override
  List<Object?> get props => [currency];
}

/// حدث حفظ جميع الإعدادات
class SaveSettings extends AppSettingsEvent {}
