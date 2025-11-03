/// Bloc إدارة الإعدادات
/// يدير جميع العمليات المتعلقة بإعدادات التطبيق

import 'package:bloc/bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// Bloc الإعدادات
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {

  SettingsBloc() : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ChangeTheme>(_onChangeTheme);
    on<SaveSettings>(_onSaveSettings);
  }

  /// معالج تحميل الإعدادات
  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      emit(SettingsLoaded(languageCode: 'ar', isDarkMode: false));
    } catch (e) {
      emit(SettingsError('فشل تحميل الإعدادات: ${e.toString()}'));
    }
  }

  /// معالج تغيير اللغة
  Future<void> _onChangeLanguage(ChangeLanguage event, Emitter<SettingsState> emit) async {
    try {
      final currentState = state;
      if (currentState is SettingsLoaded) {
        emit(SettingsLoaded(
          languageCode: event.languageCode,
          isDarkMode: currentState.isDarkMode,
        ));
      }
    } catch (e) {
      emit(SettingsError('فشل تغيير اللغة: ${e.toString()}'));
    }
  }

  /// معالج تغيير الثيم
  Future<void> _onChangeTheme(ChangeTheme event, Emitter<SettingsState> emit) async {
    try {
      final currentState = state;
      if (currentState is SettingsLoaded) {
        emit(SettingsLoaded(
          languageCode: currentState.languageCode,
          isDarkMode: event.isDark,
        ));
      }
    } catch (e) {
      emit(SettingsError('فشل تغيير الثيم: ${e.toString()}'));
    }
  }

  /// معالج حفظ الإعدادات
  Future<void> _onSaveSettings(SaveSettings event, Emitter<SettingsState> emit) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // حفظ الإعدادات
    } catch (e) {
      emit(SettingsError('فشل حفظ الإعدادات: ${e.toString()}'));
    }
  }
}
