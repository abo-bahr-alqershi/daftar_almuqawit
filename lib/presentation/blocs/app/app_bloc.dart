/// Bloc إدارة التطبيق
/// يدير حالة التطبيق العامة والتهيئة الأولية

import 'package:bloc/bloc.dart';
import 'app_event.dart';
import 'app_state.dart';

/// Bloc التطبيق
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AppLanguageChanged>(_onLanguageChanged);
    on<AppThemeChanged>(_onThemeChanged);
    on<AppSettingsUpdated>(_onSettingsUpdated);
    on<AppConnectivityChanged>(_onConnectivityChanged);
  }

  /// معالج بدء التطبيق
  Future<void> _onAppStarted(AppStarted event, Emitter<AppState> emit) async {
    try {
      // يمكن تحميل الإعدادات المحفوظة هنا
      emit(const AppReady());
    } catch (e) {
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
