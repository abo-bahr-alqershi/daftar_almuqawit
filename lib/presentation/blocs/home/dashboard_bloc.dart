/// Bloc إدارة لوحة التحكم
/// يدير بيانات وإحصائيات لوحة التحكم الرئيسية

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/usecases/statistics/get_daily_statistics.dart';
import '../../../domain/usecases/statistics/get_monthly_statistics.dart';
import '../../../domain/usecases/sales/get_today_sales.dart';
import '../../../domain/usecases/purchases/get_today_purchases.dart';
import '../../../domain/usecases/debts/get_pending_debts.dart';
import '../../../domain/usecases/debts/get_overdue_debts.dart';
import '../../../domain/entities/daily_statistics.dart';
import '../../../domain/entities/sale.dart';
import '../../../domain/entities/purchase.dart';
import '../../../domain/entities/debt.dart';
import '../../../domain/usecases/base/base_usecase.dart';

// Events
abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class RefreshDashboard extends DashboardEvent {}

// States
abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DailyStatistics todayStats;
  final List<Sale> todaySales;
  final List<Purchase> todayPurchases;
  final List<Debt> pendingDebts;
  final List<Debt> overdueDebts;
  final double monthlyProgress;
  
  DashboardLoaded({
    required this.todayStats,
    required this.todaySales,
    required this.todayPurchases,
    required this.pendingDebts,
    required this.overdueDebts,
    required this.monthlyProgress,
  });
  
  @override
  List<Object?> get props => [
    todayStats,
    todaySales,
    todayPurchases,
    pendingDebts,
    overdueDebts,
    monthlyProgress,
  ];
}

class DashboardError extends DashboardState {
  final String message;
  
  DashboardError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Bloc لوحة التحكم
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDailyStatistics _getDailyStatistics;
  final GetMonthlyStatistics _getMonthlyStatistics;
  final GetTodaySales _getTodaySales;
  final GetTodayPurchases _getTodayPurchases;
  final GetPendingDebts _getPendingDebts;
  final GetOverdueDebts _getOverdueDebts;
  
  DashboardBloc({
    required GetDailyStatistics getDailyStatistics,
    required GetMonthlyStatistics getMonthlyStatistics,
    required GetTodaySales getTodaySales,
    required GetTodayPurchases getTodayPurchases,
    required GetPendingDebts getPendingDebts,
    required GetOverdueDebts getOverdueDebts,
  }) : _getDailyStatistics = getDailyStatistics,
       _getMonthlyStatistics = getMonthlyStatistics,
       _getTodaySales = getTodaySales,
       _getTodayPurchases = getTodayPurchases,
       _getPendingDebts = getPendingDebts,
       _getOverdueDebts = getOverdueDebts,
       super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }
  
  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(DashboardLoading());
      
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // جلب جميع البيانات بشكل متوازي
      final results = await Future.wait([
        _getDailyStatistics(GetDailyStatisticsParams(date: today)),
        _getTodaySales(today),
        _getTodayPurchases(today),
        _getPendingDebts(NoParams()),
        _getOverdueDebts(today),
        _getMonthlyStats(),
      ]);
      
      emit(DashboardLoaded(
        todayStats: results[0] as DailyStatistics,
        todaySales: results[1] as List<Sale>,
        todayPurchases: results[2] as List<Purchase>,
        pendingDebts: results[3] as List<Debt>,
        overdueDebts: results[4] as List<Debt>,
        monthlyProgress: _calculateMonthlyProgress(results[5] as List<DailyStatistics>),
      ));
    } catch (e) {
      emit(DashboardError('فشل تحميل لوحة التحكم: ${e.toString()}'));
    }
  }
  
  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    await _onLoadDashboard(LoadDashboard(), emit);
  }
  
  Future<List<DailyStatistics>> _getMonthlyStats() async {
    final now = DateTime.now();
    return await _getMonthlyStatistics((year: now.year, month: now.month));
  }
  
  double _calculateMonthlyProgress(List<DailyStatistics> monthlyStats) {
    if (monthlyStats.isEmpty) return 0.0;
    
    final totalSales = monthlyStats.fold<double>(
      0,
      (sum, stat) => sum + stat.totalSales,
    );
    
    // هدف افتراضي للمبيعات الشهرية
    const monthlyTarget = 100000.0;
    
    return (totalSales / monthlyTarget).clamp(0.0, 1.0);
  }
}
