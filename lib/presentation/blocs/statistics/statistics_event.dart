/// أحداث Bloc الإحصائيات
/// تحتوي على جميع الأحداث المتعلقة بإدارة الإحصائيات

/// الحدث الأساسي للإحصائيات
abstract class StatisticsEvent {}

/// حدث تحميل إحصائيات اليوم
class LoadTodayStatistics extends StatisticsEvent {
  final String date;
  LoadTodayStatistics(this.date);
}

/// حدث تحميل إحصائيات فترة محددة
class LoadPeriodStatistics extends StatisticsEvent {
  final String startDate;
  final String endDate;
  LoadPeriodStatistics(this.startDate, this.endDate);
}

/// حدث تحميل إحصائيات الشهر
class LoadMonthStatistics extends StatisticsEvent {
  final int year;
  final int month;
  LoadMonthStatistics(this.year, this.month);
}

/// حدث تحميل إحصائيات السنة
class LoadYearStatistics extends StatisticsEvent {
  final int year;
  LoadYearStatistics(this.year);
}

/// حدث تحديث الإحصائيات
class RefreshStatistics extends StatisticsEvent {}
