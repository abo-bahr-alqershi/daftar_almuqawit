part of 'app_settings_bloc.dart';

/// حالة إعدادات التطبيق
class AppSettingsState extends Equatable {
  final String languageCode;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final String currency;
  final bool autoSync;
  final bool autoBackup;
  final bool isLoading;
  final String? error;
  
  const AppSettingsState({
    this.languageCode = 'ar',
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.currency = 'YER',
    this.autoSync = true,
    this.autoBackup = true,
    this.isLoading = true,
    this.error,
  });
  
  AppSettingsState copyWith({
    String? languageCode,
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? currency,
    bool? autoSync,
    bool? autoBackup,
    bool? isLoading,
    String? error,
  }) {
    return AppSettingsState(
      languageCode: languageCode ?? this.languageCode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      currency: currency ?? this.currency,
      autoSync: autoSync ?? this.autoSync,
      autoBackup: autoBackup ?? this.autoBackup,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
  
  @override
  List<Object?> get props => [
    languageCode,
    isDarkMode,
    notificationsEnabled,
    currency,
    autoSync,
    autoBackup,
    isLoading,
    error,
  ];
}
