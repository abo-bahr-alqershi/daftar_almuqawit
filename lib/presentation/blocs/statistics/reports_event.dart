/// أحداث التقارير
/// تحدد الأحداث التي يمكن أن تحدث في التقارير

import 'package:equatable/equatable.dart';

/// الحدث الأساسي للتقارير
abstract class ReportsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// إنشاء تقرير يومي
class GenerateDailyReportEvent extends ReportsEvent {
  /// التاريخ المطلوب (ISO format: yyyy-MM-dd)
  final String date;
  
  GenerateDailyReportEvent(this.date);
  
  @override
  List<Object?> get props => [date];
}

/// إنشاء تقرير أسبوعي
class GenerateWeeklyReportEvent extends ReportsEvent {
  /// تاريخ بداية الأسبوع
  final String startDate;
  
  /// تاريخ نهاية الأسبوع
  final String endDate;
  
  GenerateWeeklyReportEvent({
    required this.startDate,
    required this.endDate,
  });
  
  @override
  List<Object?> get props => [startDate, endDate];
}

/// إنشاء تقرير شهري
class GenerateMonthlyReportEvent extends ReportsEvent {
  /// السنة
  final int year;
  
  /// الشهر (1-12)
  final int month;
  
  GenerateMonthlyReportEvent(this.year, this.month);
  
  @override
  List<Object?> get props => [year, month];
}

/// إنشاء تقرير سنوي
class GenerateYearlyReportEvent extends ReportsEvent {
  /// السنة
  final int year;
  
  GenerateYearlyReportEvent(this.year);
  
  @override
  List<Object?> get props => [year];
}

/// إنشاء تقرير مخصص
class GenerateCustomReportEvent extends ReportsEvent {
  /// تاريخ البداية
  final String startDate;
  
  /// تاريخ النهاية
  final String endDate;
  
  GenerateCustomReportEvent({
    required this.startDate,
    required this.endDate,
  });
  
  @override
  List<Object?> get props => [startDate, endDate];
}

/// طباعة تقرير
class PrintReportEvent extends ReportsEvent {
  /// نوع التقرير (daily, weekly, monthly, yearly, custom)
  final String reportType;
  
  /// بيانات التقرير
  final Map<String, dynamic> data;
  
  /// تاريخ البداية (اختياري)
  final String? startDate;
  
  /// تاريخ النهاية (اختياري)
  final String? endDate;
  
  /// بيانات مخصصة (اختياري)
  final Map<String, dynamic>? customData;
  
  PrintReportEvent(
    this.reportType,
    this.data, {
    this.startDate,
    this.endDate,
    this.customData,
  });
  
  @override
  List<Object?> get props => [reportType, data, startDate, endDate, customData];
}

/// مشاركة تقرير
class ShareReportEvent extends ReportsEvent {
  /// نوع التقرير (daily, weekly, monthly, yearly, custom)
  final String reportType;
  
  /// بيانات التقرير
  final Map<String, dynamic> data;
  
  /// تاريخ البداية (اختياري)
  final String? startDate;
  
  /// تاريخ النهاية (اختياري)
  final String? endDate;
  
  /// بيانات مخصصة (اختياري)
  final Map<String, dynamic>? customData;
  
  ShareReportEvent(
    this.reportType,
    this.data, {
    this.startDate,
    this.endDate,
    this.customData,
  });
  
  @override
  List<Object?> get props => [reportType, data, startDate, endDate, customData];
}

/// تصدير تقرير إلى Excel
class ExportReportEvent extends ReportsEvent {
  /// نوع التقرير
  final String reportType;
  
  /// بيانات التقرير
  final Map<String, dynamic> data;
  
  ExportReportEvent(this.reportType, this.data);
  
  @override
  List<Object?> get props => [reportType, data];
}
