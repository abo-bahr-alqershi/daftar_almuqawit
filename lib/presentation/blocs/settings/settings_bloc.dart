/// Bloc إدارة الإعدادات
/// يدير جميع العمليات المتعلقة بإعدادات التطبيق

import 'package:bloc/bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import '../../../core/services/local/shared_preferences_service.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/sync/sync_manager.dart';
import '../../../core/services/backup_service.dart';

/// Bloc الإعدادات
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferencesService _prefs;
  final LoggerService _logger;
  final SyncManager _syncManager;
  final BackupService _backupService;

  SettingsBloc({
    required SharedPreferencesService prefs,
    required LoggerService logger,
    required SyncManager syncManager,
    required BackupService backupService,
  })  : _prefs = prefs,
        _logger = logger,
        _syncManager = syncManager,
        _backupService = backupService,
        super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ChangeTheme>(_onChangeTheme);
    on<SaveSettings>(_onSaveSettings);
    on<ToggleAutoSync>(_onToggleAutoSync);
    on<ToggleAutoBackup>(_onToggleAutoBackup);
    on<ToggleNotifications>(_onToggleNotifications);
    on<ToggleSound>(_onToggleSound);
  }

  /// معالج تحميل الإعدادات
  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    try {
      _logger.info('تحميل الإعدادات');
      
      final language = await _prefs.getString(StorageKeys.language) ?? 'ar';
      final themeMode = await _prefs.getString(StorageKeys.themeMode) ?? 'light';
      final isDark = themeMode == 'dark';
      final autoSyncEnabled = _prefs.getBool(StorageKeys.autoSyncEnabled) ?? false;
      final autoBackupEnabled = _prefs.getBool(StorageKeys.autoBackupEnabled) ?? false;
      final notificationsEnabled = _prefs.getBool(StorageKeys.notificationsEnabled) ?? true;
      final soundEnabled = true; // TODO: إضافة مفتاح للصوت في StorageKeys
      
      emit(SettingsLoaded(
        languageCode: language,
        isDarkMode: isDark,
        autoSyncEnabled: autoSyncEnabled,
        autoBackupEnabled: autoBackupEnabled,
        notificationsEnabled: notificationsEnabled,
        soundEnabled: soundEnabled,
      ));
      
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
        emit(currentState.copyWith(languageCode: event.languageCode));
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
        emit(currentState.copyWith(isDarkMode: event.isDark));
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

  /// معالج تبديل المزامنة التلقائية
  Future<void> _onToggleAutoSync(ToggleAutoSync event, Emitter<SettingsState> emit) async {
    try {
      _logger.info('تبديل المزامنة التلقائية إلى: ${event.enabled}');
      
      // حفظ الإعداد
      await _prefs.setBool(StorageKeys.autoSyncEnabled, event.enabled);
      
      // تفعيل أو إيقاف خدمة المزامنة التلقائية
      if (event.enabled) {
        _syncManager.startAuto();
        _logger.info('تم تفعيل المزامنة التلقائية');
      } else {
        await _syncManager.stopAuto();
        _logger.info('تم إيقاف المزامنة التلقائية');
      }
      
      // تحديث الحالة
      final currentState = state;
      if (currentState is SettingsLoaded) {
        emit(currentState.copyWith(autoSyncEnabled: event.enabled));
      }
    } catch (e, s) {
      _logger.error('فشل تبديل المزامنة التلقائية', error: e, stackTrace: s);
      emit(SettingsError('فشل تبديل المزامنة التلقائية: ${e.toString()}'));
    }
  }

  /// معالج تبديل النسخ الاحتياطي التلقائي
  Future<void> _onToggleAutoBackup(ToggleAutoBackup event, Emitter<SettingsState> emit) async {
    try {
      _logger.info('تبديل النسخ الاحتياطي التلقائي إلى: ${event.enabled}');
      
      // حفظ الإعداد
      await _prefs.setBool(StorageKeys.autoBackupEnabled, event.enabled);
      
      // تفعيل أو إيقاف خدمة النسخ الاحتياطي التلقائي
      if (event.enabled) {
        await _backupService.scheduleAutoBackup();
        _logger.info('تم تفعيل النسخ الاحتياطي التلقائي');
      } else {
        await _backupService.cancelAutoBackup();
        _logger.info('تم إيقاف النسخ الاحتياطي التلقائي');
      }
      
      // تحديث الحالة
      final currentState = state;
      if (currentState is SettingsLoaded) {
        emit(currentState.copyWith(autoBackupEnabled: event.enabled));
      }
    } catch (e, s) {
      _logger.error('فشل تبديل النسخ الاحتياطي التلقائي', error: e, stackTrace: s);
      emit(SettingsError('فشل تبديل النسخ الاحتياطي التلقائي: ${e.toString()}'));
    }
  }

  /// معالج تبديل الإشعارات
  Future<void> _onToggleNotifications(ToggleNotifications event, Emitter<SettingsState> emit) async {
    try {
      _logger.info('تبديل الإشعارات إلى: ${event.enabled}');
      
      // حفظ الإعداد
      await _prefs.setBool(StorageKeys.notificationsEnabled, event.enabled);
      
      // تحديث الحالة
      final currentState = state;
      if (currentState is SettingsLoaded) {
        emit(currentState.copyWith(notificationsEnabled: event.enabled));
      }
      
      _logger.info('تم تبديل الإشعارات بنجاح');
    } catch (e, s) {
      _logger.error('فشل تبديل الإشعارات', error: e, stackTrace: s);
      emit(SettingsError('فشل تبديل الإشعارات: ${e.toString()}'));
    }
  }

  /// معالج تبديل الصوت
  Future<void> _onToggleSound(ToggleSound event, Emitter<SettingsState> emit) async {
    try {
      _logger.info('تبديل الصوت إلى: ${event.enabled}');
      
      // TODO: حفظ إعداد الصوت عند إضافة مفتاح في StorageKeys
      
      // تحديث الحالة
      final currentState = state;
      if (currentState is SettingsLoaded) {
        emit(currentState.copyWith(soundEnabled: event.enabled));
      }
      
      _logger.info('تم تبديل الصوت بنجاح');
    } catch (e, s) {
      _logger.error('فشل تبديل الصوت', error: e, stackTrace: s);
      emit(SettingsError('فشل تبديل الصوت: ${e.toString()}'));
    }
  }
}
