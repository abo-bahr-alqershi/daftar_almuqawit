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
  
  DashboardLoaded({
    required this.dailyStats,
    required this.todaySales,
    required this.todayPurchases,
    required this.pendingDebts,
    required this.overdueDebts,
    required this.monthlyProgress,
  });
  
  @override
  List<Object?> get props => [
    dailyStats,
    todaySales,
    todayPurchases,
    pendingDebts,
    overdueDebts,
    monthlyProgress,
  ];
}

/// حالة خطأ في تحميل بيانات لوحة التحكم
class DashboardError extends DashboardState {
  /// رسالة الخطأ
  final String message;
  
  DashboardError(this.message);
  
  @override
  List<Object?> get props => [message];
}
