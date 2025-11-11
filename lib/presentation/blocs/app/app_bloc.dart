/// Bloc إدارة التطبيق
/// يدير حالة التطبيق العامة والتهيئة الأولية

import 'package:bloc/bloc.dart';
import 'app_event.dart';
import 'app_state.dart';
import '../../../core/services/local/shared_preferences_service.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/services/sync/sync_manager.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/logger_service.dart';

/// Bloc التطبيق
class AppBloc extends Bloc<AppEvent, AppState> {
  final SharedPreferencesService _prefsService;
  final SyncManager _syncManager;
  final BackupService _backupService;
  final LoggerService _logger;

  AppBloc({
    required SharedPreferencesService prefsService,
    required SyncManager syncManager,
    required BackupService backupService,
    required LoggerService logger,
  })  : _prefsService = prefsService,
        _syncManager = syncManager,
        _backupService = backupService,
        _logger = logger,
        super(const AppInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AppLanguageChanged>(_onLanguageChanged);
    on<AppThemeChanged>(_onThemeChanged);
    on<AppSettingsUpdated>(_onSettingsUpdated);
    on<AppConnectivityChanged>(_onConnectivityChanged);
  }

  /// معالج بدء التطبيق
  Future<void> _onAppStarted(AppStarted event, Emitter<AppState> emit) async {
    try {
      _logger.info('بدء تهيئة التطبيق...');
      
      // تهيئة SharedPreferences
      await _prefsService.init();
      
      // تحميل الإعدادات المحفوظة
      final autoSyncEnabled = _prefsService.getBool(StorageKeys.autoSyncEnabled) ?? false;
      final autoBackupEnabled = _prefsService.getBool(StorageKeys.autoBackupEnabled) ?? false;
      
      _logger.info('الإعدادات: المزامنة التلقائية = $autoSyncEnabled، النسخ الاحتياطي التلقائي = $autoBackupEnabled');
      
      // تفعيل المزامنة التلقائية إذا كانت مفعلة
      if (autoSyncEnabled) {
        _logger.info('تفعيل المزامنة التلقائية...');
        _syncManager.startAuto();
        _logger.info('تم تفعيل المزامنة التلقائية بنجاح');
      }
      
      // تفعيل النسخ الاحتياطي التلقائي إذا كان مفعلاً
      if (autoBackupEnabled) {
        _logger.info('تفعيل النسخ الاحتياطي التلقائي...');
        await _backupService.scheduleAutoBackup();
        _logger.info('تم تفعيل النسخ الاحتياطي التلقائي بنجاح');
      }
      
      _logger.info('تم تهيئة التطبيق بنجاح');
      emit(const AppReady());
    } catch (e, stackTrace) {
      _logger.error('خطأ في تهيئة التطبيق', error: e, stackTrace: stackTrace);
      emit(AppError(e.toString()));
    }
  }

  /// معالج تغيير اللغة
  Future<void> _onLanguageChanged(
    AppLanguageChanged event,
    Emitter<AppState> emit,
  ) async {
    if (state is AppReady) {
      final currentState = state as AppReady;
      emit(currentState.copyWith(languageCode: event.languageCode));
    }
  }

  /// معالج تغيير الثيم
  Future<void> _onThemeChanged(
    AppThemeChanged event,
    Emitter<AppState> emit,
  ) async {
    if (state is AppReady) {
      final currentState = state as AppReady;
      emit(currentState.copyWith(isDarkMode: event.isDark));
    }
  }

  /// معالج تحديث الإعدادات
  Future<void> _onSettingsUpdated(
    AppSettingsUpdated event,
    Emitter<AppState> emit,
  ) async {
    if (state is AppReady) {
      final currentState = state as AppReady;
      emit(currentState.copyWith(settings: event.settings));
    }
  }

  /// معالج تغيير حالة الاتصال
  Future<void> _onConnectivityChanged(
    AppConnectivityChanged event,
    Emitter<AppState> emit,
  ) async {
    if (state is AppReady) {
      final currentState = state as AppReady;
      emit(currentState.copyWith(isConnected: event.isConnected));
    }
  }
}
