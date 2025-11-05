// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';

/// حالات التطبيق العامة
abstract class AppState extends Equatable {
  final String languageCode;
  final bool isDarkMode;
  final bool isConnected;
  final Map<String, dynamic>? settings;
  
  const AppState({
    this.languageCode = 'ar',
    this.isDarkMode = false,
    this.isConnected = true,
    this.settings,
  });
  
  @override
  List<Object?> get props => [languageCode, isDarkMode, isConnected, settings];
}

/// حالة التهيئة الأولية
class AppInitial extends AppState {
  const AppInitial() : super();
}

/// حالة المستخدم مصادق عليه
class AppAuthenticated extends AppState {
  const AppAuthenticated({
    super.languageCode,
    super.isDarkMode,
    super.isConnected,
    super.settings,
  });
  
  AppAuthenticated copyWith({
    String? languageCode,
    bool? isDarkMode,
    bool? isConnected,
    Map<String, dynamic>? settings,
  }) {
    return AppAuthenticated(
      languageCode: languageCode ?? this.languageCode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isConnected: isConnected ?? this.isConnected,
      settings: settings ?? this.settings,
    );
  }
}

/// حالة التطبيق جاهز
class AppReady extends AppState {
  const AppReady({
    super.languageCode,
    super.isDarkMode,
    super.isConnected,
    super.settings,
  });
  
  /// نسخ الحالة مع تحديث
AppReady copyWith({
    String? languageCode,
    bool? isDarkMode,
    bool? isConnected,
    Map<String, dynamic>? settings,
  }) {
    return AppReady(
      languageCode: languageCode ?? this.languageCode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isConnected: isConnected ?? this.isConnected,
      settings: settings ?? this.settings,
    );
  }
}

/// حالة خطأ في التطبيق
class AppError extends AppState {
  final String message;
  
  const AppError(this.message) : super();
  
  @override
  List<Object?> get props => [message, ...super.props];
}
