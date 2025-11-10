/// أحداث لوحة التحكم
/// تحدد الأحداث التي يمكن أن تحدث في لوحة التحكم

import 'package:equatable/equatable.dart';

/// الحدث الأساسي للوحة التحكم
abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// تحميل بيانات لوحة التحكم
class LoadDashboard extends DashboardEvent {}

/// تحديث بيانات لوحة التحكم
class RefreshDashboard extends DashboardEvent {}

/// تصفية لوحة التحكم حسب الفترة الزمنية
class FilterDashboardByDateRange extends DashboardEvent {
  final DateTime startDate;
  final DateTime endDate;

  FilterDashboardByDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// تحميل إحصائيات اليوم
class LoadTodayStatistics extends DashboardEvent {}

/// تحميل إحصائيات الأسبوع
class LoadWeekStatistics extends DashboardEvent {}

/// تحميل إحصائيات الشهر
class LoadMonthStatistics extends DashboardEvent {}

/// تحميل الأنشطة الأخيرة
class LoadRecentActivities extends DashboardEvent {
  final int limit;

  LoadRecentActivities({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// تصدير بيانات لوحة التحكم
class ExportDashboardData extends DashboardEvent {
  final String format;

  ExportDashboardData({required this.format});

  @override
  List<Object?> get props => [format];
}
