/// حالات Bloc الإعدادات
/// تحتوي على جميع الحالات الممكنة للإعدادات

import 'package:equatable/equatable.dart';

/// الحالة الأساسية للإعدادات
abstract class SettingsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class SettingsInitial extends SettingsState {}

/// حالة تحميل الإعدادات بنجاح
class SettingsLoaded extends SettingsState {
  final String languageCode;
  final bool isDarkMode;
  final bool autoSyncEnabled;
  final bool autoBackupEnabled;
  final bool notificationsEnabled;
  final bool soundEnabled;
  
  SettingsLoaded({
    required this.languageCode,
    required this.isDarkMode,
    this.autoSyncEnabled = false,
    this.autoBackupEnabled = false,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
  });
  
  /// نسخ الحالة مع تحديث بعض القيم
  SettingsLoaded copyWith({
    String? languageCode,
    bool? isDarkMode,
    bool? autoSyncEnabled,
    bool? autoBackupEnabled,
    bool? notificationsEnabled,
    bool? soundEnabled,
  }) {
    return SettingsLoaded(
      languageCode: languageCode ?? this.languageCode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
  
  @override
  List<Object?> get props => [
    languageCode,
    isDarkMode,
    autoSyncEnabled,
    autoBackupEnabled,
    notificationsEnabled,
    soundEnabled,
  ];
}

/// حالة حدوث خطأ
class SettingsError extends SettingsState {
  final String message;
  SettingsError(this.message);
  
  @override
  List<Object?> get props => [message];
}
