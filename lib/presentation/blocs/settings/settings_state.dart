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
  
  SettingsLoaded({
    required this.languageCode,
    required this.isDarkMode,
  });
  
  @override
  List<Object?> get props => [languageCode, isDarkMode];
}

/// حالة حدوث خطأ
class SettingsError extends SettingsState {
  final String message;
  SettingsError(this.message);
  
  @override
  List<Object?> get props => [message];
}
