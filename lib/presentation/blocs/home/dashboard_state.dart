/// حالات لوحة التحكم
/// تمثل الحالات المختلفة للوحة التحكم

import 'package:equatable/equatable.dart';
import '../../../domain/entities/daily_statistics.dart';
import '../../../domain/entities/sale.dart';
import '../../../domain/entities/purchase.dart';
import '../../../domain/entities/debt.dart';

/// الحالة الأساسية للوحة التحكم
abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية للوحة التحكم
class DashboardInitial extends DashboardState {}

/// حالة تحميل بيانات لوحة التحكم
class DashboardLoading extends DashboardState {}

/// حالة نجاح تحميل بيانات لوحة التحكم
class DashboardLoaded extends DashboardState {
  /// إحصائيات اليوم
  final DailyStatistics dailyStats;
  
  /// إحصائيات الأمس للمقارنة
  final DailyStatistics? yesterdayStats;
  
  /// مبيعات اليوم
  final List<Sale> todaySales;
  
  /// مشتريات اليوم
  final List<Purchase> todayPurchases;
  
  /// الديون المعلقة
  final List<Debt> pendingDebts;
  
  /// الديون المتأخرة
  final List<Debt> overdueDebts;
  
  /// نسبة التقدم الشهري (0.0 إلى 1.0)
  final double monthlyProgress;
  
  /// الفترة الزمنية المعروضة (اختياري)
  final DateTime? startDate;
  final DateTime? endDate;
  
  DashboardLoaded({
    required this.dailyStats,
    this.yesterdayStats,
    required this.todaySales,
    required this.todayPurchases,
    required this.pendingDebts,
    required this.overdueDebts,
    required this.monthlyProgress,
    this.startDate,
    this.endDate,
  });
  
  @override
  List<Object?> get props => [
    dailyStats,
    yesterdayStats,
    todaySales,
    todayPurchases,
    pendingDebts,
    overdueDebts,
    monthlyProgress,
    startDate,
    endDate,
  ];

  DashboardLoaded copyWith({
    DailyStatistics? dailyStats,
    DailyStatistics? yesterdayStats,
    List<Sale>? todaySales,
    List<Purchase>? todayPurchases,
    List<Debt>? pendingDebts,
    List<Debt>? overdueDebts,
    double? monthlyProgress,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DashboardLoaded(
      dailyStats: dailyStats ?? this.dailyStats,
      yesterdayStats: yesterdayStats ?? this.yesterdayStats,
      todaySales: todaySales ?? this.todaySales,
      todayPurchases: todayPurchases ?? this.todayPurchases,
      pendingDebts: pendingDebts ?? this.pendingDebts,
      overdueDebts: overdueDebts ?? this.overdueDebts,
      monthlyProgress: monthlyProgress ?? this.monthlyProgress,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

/// حالة تحديث جزئي للوحة التحكم
class DashboardRefreshing extends DashboardState {
  final DashboardLoaded currentData;

  DashboardRefreshing(this.currentData);

  @override
  List<Object?> get props => [currentData];
}

/// حالة تصدير البيانات
class DashboardExporting extends DashboardState {}

/// حالة نجاح التصدير
class DashboardExported extends DashboardState {
  final String filePath;

  DashboardExported(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// حالة خطأ في تحميل بيانات لوحة التحكم
class DashboardError extends DashboardState {
  /// رسالة الخطأ
  final String message;
  
  DashboardError(this.message);
  
  @override
  List<Object?> get props => [message];
}
