/// أحداث التقارير
/// تحدد الأحداث التي يمكن أن تحدث في التقارير
library;

import 'package:equatable/equatable.dart';

/// الحدث الأساسي للتقارير
abstract class ReportsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// إنشاء تقرير يومي
class GenerateDailyReportEvent extends ReportsEvent {
  GenerateDailyReportEvent(this.date);

  /// التاريخ المطلوب (ISO format: yyyy-MM-dd)
  final String date;

  @override
  List<Object?> get props => [date];
}

/// إنشاء تقرير أسبوعي
class GenerateWeeklyReportEvent extends ReportsEvent {
  GenerateWeeklyReportEvent({required this.startDate, required this.endDate});

  /// تاريخ بداية الأسبوع
  final String startDate;

  /// تاريخ نهاية الأسبوع
  final String endDate;

  @override
  List<Object?> get props => [startDate, endDate];
}

/// إنشاء تقرير شهري
class GenerateMonthlyReportEvent extends ReportsEvent {
  GenerateMonthlyReportEvent(this.year, this.month);

  /// السنة
  final int year;

  /// الشهر (1-12)
  final int month;

  @override
  List<Object?> get props => [year, month];
}

/// إنشاء تقرير سنوي
class GenerateYearlyReportEvent extends ReportsEvent {
  GenerateYearlyReportEvent(this.year);

  /// السنة
  final int year;

  @override
  List<Object?> get props => [year];
}

/// إنشاء تقرير مخصص
class GenerateCustomReportEvent extends ReportsEvent {
  GenerateCustomReportEvent({required this.startDate, required this.endDate});

  /// تاريخ البداية
  final String startDate;

  /// تاريخ النهاية
  final String endDate;

  @override
  List<Object?> get props => [startDate, endDate];
}

/// طباعة تقرير
class PrintReportEvent extends ReportsEvent {
  PrintReportEvent(
    this.reportType,
    this.data, {
    this.startDate,
    this.endDate,
    this.customData,
  });

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

  @override
  List<Object?> get props => [reportType, data, startDate, endDate, customData];
}

/// مشاركة تقرير
class ShareReportEvent extends ReportsEvent {
  ShareReportEvent(
    this.reportType,
    this.data, {
    this.startDate,
    this.endDate,
    this.customData,
  });

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

  @override
  List<Object?> get props => [reportType, data, startDate, endDate, customData];
}

/// تصدير تقرير إلى Excel
class ExportReportEvent extends ReportsEvent {
  ExportReportEvent(this.reportType, this.data);

  /// نوع التقرير
  final String reportType;

  /// بيانات التقرير
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [reportType, data];
}
