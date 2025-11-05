/// Bloc إدارة إعدادات التطبيق
/// يدير الإعدادات العامة للتطبيق مثل اللغة والوضع الليلي

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/local/shared_preferences_service.dart';

part 'app_settings_event.dart';
part 'app_settings_state.dart';

/// Bloc إعدادات التطبيق
class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  final SharedPreferencesService _preferencesService;
  
  AppSettingsBloc({
    SharedPreferencesService? preferencesService,
  }) : _preferencesService = preferencesService ?? SharedPreferencesService.instance,
       super(const AppSettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ToggleThemeMode>(_onToggleThemeMode);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
    on<UpdateCurrency>(_onUpdateCurrency);
    on<SaveSettings>(_onSaveSettings);
    
    // تحميل الإعدادات عند البدء
    add(LoadSettings());
  }
  
  /// تحميل الإعدادات المحفوظة
  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<AppSettingsState> emit,
  ) async {
    try {
      final languageCode = await _preferencesService.getString('language_code') ?? 'ar';
      final isDarkMode = await _preferencesService.getBool('is_dark_mode') ?? false;
      final notificationsEnabled = await _preferencesService.getBool('notifications_enabled') ?? true;
      final currency = await _preferencesService.getString('currency') ?? 'YER';
      final autoSync = await _preferencesService.getBool('auto_sync') ?? true;
      final autoBackup = await _preferencesService.getBool('auto_backup') ?? true;
      
      emit(state.copyWith(
        languageCode: languageCode,
        isDarkMode: isDarkMode,
        notificationsEnabled: notificationsEnabled,
        currency: currency,
        autoSync: autoSync,
        autoBackup: autoBackup,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
  
  /// تغيير لغة التطبيق
  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(state.copyWith(languageCode: event.languageCode));
    await _preferencesService.setString('language_code', event.languageCode);
  }
  
  /// تبديل وضع الوضع الليلي
  Future<void> _onToggleThemeMode(
    ToggleThemeMode event,
    Emitter<AppSettingsState> emit,
  ) async {
    final isDarkMode = event.isDarkMode ?? !state.isDarkMode;
    emit(state.copyWith(isDarkMode: isDarkMode));
    await _preferencesService.setBool('is_dark_mode', isDarkMode);
  }
  
  /// تحديث إعدادات الإشعارات
  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettings event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(state.copyWith(notificationsEnabled: event.enabled));
    await _preferencesService.setBool('notifications_enabled', event.enabled);
  }
  
  /// تحديث العملة
  Future<void> _onUpdateCurrency(
    UpdateCurrency event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(state.copyWith(currency: event.currency));
    await _preferencesService.setString('currency', event.currency);
  }
  
  /// حفظ جميع الإعدادات
  Future<void> _onSaveSettings(
    SaveSettings event,
    Emitter<AppSettingsState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      await Future.wait([
        _preferencesService.setString('language_code', state.languageCode),
        _preferencesService.setBool('is_dark_mode', state.isDarkMode),
        _preferencesService.setBool('notifications_enabled', state.notificationsEnabled),
        _preferencesService.setString('currency', state.currency),
        _preferencesService.setBool('auto_sync', state.autoSync),
        _preferencesService.setBool('auto_backup', state.autoBackup),
      ]);
      
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}
