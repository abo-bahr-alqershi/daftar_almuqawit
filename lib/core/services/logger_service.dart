/// خدمة تسجيل الأحداث والأخطاء
/// تسجل مستويات مختلفة وتحفظ السجلات محلياً وترسل تقارير الأخطاء

import 'dart:developer' as developer;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// خدمة تسجيل الأحداث والأخطاء
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();
  
  File? _logFile;
  final List<String> _logBuffer = [];
  static const int _maxLogSize = 1000; // عدد السطور
  static const int _maxLogAge = 7; // أيام
  /// تسجيل رسالة Debug
  void d(String message, {Map<String, dynamic>? data}) {
    developer.log(message, name: 'DEBUG', level: 500);
    if (data != null) {
      developer.log('Data: $data', name: 'DEBUG', level: 500);
    }
  }
  
  /// تسجيل رسالة Debug (اسم بديل)
  void debug(String message, {Map<String, dynamic>? data}) => d(message, data: data);

  /// تسجيل رسالة Info
  void i(String message, {Map<String, dynamic>? data}) {
    developer.log(message, name: 'INFO', level: 800);
    if (data != null) {
      developer.log('Data: $data', name: 'INFO', level: 800);
    }
  }
  
  /// تسجيل رسالة Info (اسم بديل)
  void info(String message, {Map<String, dynamic>? data}) => i(message, data: data);

  /// تسجيل رسالة Warning
  void w(String message, {Map<String, dynamic>? data}) {
    developer.log(message, name: 'WARNING', level: 900);
    if (data != null) {
      developer.log('Data: $data', name: 'WARNING', level: 900);
    }
  }
  
  /// تسجيل رسالة Warning (اسم بديل)
  void warning(String message, {Map<String, dynamic>? data}) => w(message, data: data);

  /// تسجيل رسالة Error
  void e(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    developer.log(
      message,
      name: 'ERROR',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
    if (data != null) {
      developer.log('Data: $data', name: 'ERROR', level: 1000);
    }
  }
  
  /// تسجيل رسالة Error (اسم بديل)
  void error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    e(message, error: error, stackTrace: stackTrace, data: data);
  }

  /// تهيئة ملف السجل
  Future<void> initialize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _logFile = File('${dir.path}/logs/app_log.txt');
      if (!await _logFile!.exists()) {
        await _logFile!.create(recursive: true);
      }
      await _cleanOldLogs();
    } catch (e) {
      developer.log('فشل تهيئة ملف السجل: $e', name: 'ERROR', level: 1000);
    }
  }

  /// حفظ السجل في ملف
  Future<void> _saveToFile(String level, String message) async {
    if (_logFile == null) return;
    
    try {
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = '[$timestamp] [$level] $message\n';
      _logBuffer.add(logEntry);
      
      // حفظ كل 10 سطور
      if (_logBuffer.length >= 10) {
        await _logFile!.writeAsString(
          _logBuffer.join(),
          mode: FileMode.append,
        );
        _logBuffer.clear();
      }
    } catch (e) {
      developer.log('فشل حفظ السجل: $e', name: 'ERROR', level: 1000);
    }
  }

  /// تنظيف السجلات القديمة
  Future<void> _cleanOldLogs() async {
    if (_logFile == null || !await _logFile!.exists()) return;
    
    try {
      final lines = await _logFile!.readAsLines();
      if (lines.length > _maxLogSize) {
        // الاحتفاظ بآخر _maxLogSize سطر
        final newLines = lines.sublist(lines.length - _maxLogSize);
        await _logFile!.writeAsString(newLines.join('\n'));
      }
    } catch (e) {
      developer.log('فشل تنظيف السجلات: $e', name: 'ERROR', level: 1000);
    }
  }

  /// إرسال تقرير خطأ
  Future<void> sendErrorReport(String error, StackTrace? stackTrace) async {
    // TODO: إرسال التقرير إلى خدمة مثل Firebase Crashlytics
    developer.log('إرسال تقرير خطأ: $error', name: 'ERROR', level: 1000);
  }

  /// الحصول على السجلات
  Future<String> getLogs() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return 'لا توجد سجلات';
    }
    
    try {
      return await _logFile!.readAsString();
    } catch (e) {
      return 'فشل قراءة السجلات: $e';
    }
  }

  /// مسح جميع السجلات
  Future<void> clearLogs() async {
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.delete();
      await initialize();
    }
    _logBuffer.clear();
  }
}
