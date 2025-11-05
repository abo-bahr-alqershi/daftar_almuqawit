/// Bloc إدارة الإعدادات
/// يدير جميع العمليات المتعلقة بإعدادات التطبيق

import 'package:bloc/bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import '../../../core/services/local/shared_preferences_service.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/services/logger_service.dart';

/// Bloc الإعدادات
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferencesService _prefs;
  final LoggerService _logger;

  SettingsBloc({
    required SharedPreferencesService prefs,
    required LoggerService logger,
  })  : _prefs = prefs,
        _logger = logger,
        super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ChangeTheme>(_onChangeTheme);
    on<SaveSettings>(_onSaveSettings);
  }

  /// معالج تحميل الإعدادات
  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    try {
      _logger.info('تحميل الإعدادات');
      
      final language = await _prefs.getString(StorageKeys.language) ?? 'ar';
      final themeMode = await _prefs.getString(StorageKeys.themeMode) ?? 'light';
      final isDark = themeMode == 'dark';
      
      emit(SettingsLoaded(languageCode: language, isDarkMode: isDark));
      _logger.info('تم تحميل الإعدادات بنجاح');
    } catch (e, s) {
      _logger.error('فشل تحميل الإعدادات', error: e, stackTrace: s);
      emit(SettingsError('فشل تحميل الإعدادات: ${e.toString()}'));
    }
  }

  /// معالج تغيير اللغة
  Future<void> _onChangeLanguage(ChangeLanguage event, Emitter<SettingsState> emit) async {
    try {
      _logger.info('تغيير اللغة إلى: ${event.languageCode}');
      
      await _prefs.setString(StorageKeys.language, event.languageCode);
      
      final currentState = state;
      if (currentState is SettingsLoaded) {
        emit(SettingsLoaded(
          languageCode: event.languageCode,
          isDarkMode: currentState.isDarkMode,
        ));
      }
      
      _logger.info('تم تغيير اللغة بنجاح');
    } catch (e, s) {
      _logger.error('فشل تغيير اللغة', error: e, stackTrace: s);
      emit(SettingsError('فشل تغيير اللغة: ${e.toString()}'));
    }
  }

  /// معالج تغيير الثيم
  Future<void> _onChangeTheme(ChangeTheme event, Emitter<SettingsState> emit) async {
    try {
      _logger.info('تغيير الثيم إلى: ${event.isDark ? "dark" : "light"}');
      
      await _prefs.setString(StorageKeys.themeMode, event.isDark ? 'dark' : 'light');
      
      final currentState = state;
      if (currentState is SettingsLoaded) {
        emit(SettingsLoaded(
          languageCode: currentState.languageCode,
          isDarkMode: event.isDark,
        ));
      }
      
      _logger.info('تم تغيير الثيم بنجاح');
    } catch (e, s) {
      _logger.error('فشل تغيير الثيم', error: e, stackTrace: s);
      emit(SettingsError('فشل تغيير الثيم: ${e.toString()}'));
    }
  }

  /// معالج حفظ الإعدادات
  Future<void> _onSaveSettings(SaveSettings event, Emitter<SettingsState> emit) async {
    try {
      _logger.info('حفظ الإعدادات');
      
      // الإعدادات يتم حفظها تلقائياً عند التغيير
      // هذا المعالج للحفظ الشامل إذا لزم الأمر
      
      _logger.info('تم حفظ الإعدادات بنجاح');
    } catch (e, s) {
      _logger.error('فشل حفظ الإعدادات', error: e, stackTrace: s);
      emit(SettingsError('فشل حفظ الإعدادات: ${e.toString()}'));
    }
  }
}
