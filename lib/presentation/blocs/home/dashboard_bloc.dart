/// Bloc إدارة لوحة التحكم
/// يدير بيانات وإحصائيات لوحة التحكم الرئيسية

import 'package:bloc/bloc.dart';
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
import 'dashboard_event.dart';
import 'dashboard_state.dart';

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
    on<FilterDashboardByDateRange>(_onFilterByDateRange);
    on<LoadTodayStatistics>(_onLoadTodayStatistics);
    on<LoadWeekStatistics>(_onLoadWeekStatistics);
    on<LoadMonthStatistics>(_onLoadMonthStatistics);
    on<LoadRecentActivities>(_onLoadRecentActivities);
    on<ExportDashboardData>(_onExportData);
  }
  
  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(DashboardLoading());
      
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final results = await Future.wait([
        _getDailyStatistics(GetDailyStatisticsParams(date: today)),
        _getTodaySales(today),
        _getTodayPurchases(today),
        _getPendingDebts(NoParams()),
        _getOverdueDebts(today),
        _getMonthlyStats(),
      ]);
      
      emit(DashboardLoaded(
        dailyStats: results[0] as DailyStatistics,
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
    if (state is DashboardLoaded) {
      emit(DashboardRefreshing(state as DashboardLoaded));
    }
    await _onLoadDashboard(LoadDashboard(), emit);
  }

  Future<void> _onFilterByDateRange(
    FilterDashboardByDateRange event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(DashboardLoading());
      
      final startDateStr = event.startDate.toIso8601String().split('T')[0];
      final endDateStr = event.endDate.toIso8601String().split('T')[0];
      
      final results = await Future.wait([
        _getDailyStatistics(GetDailyStatisticsParams(date: startDateStr)),
        _getTodaySales(startDateStr),
        _getTodayPurchases(startDateStr),
        _getPendingDebts(NoParams()),
        _getOverdueDebts(endDateStr),
        _getMonthlyStats(),
      ]);
      
      emit(DashboardLoaded(
        dailyStats: results[0] as DailyStatistics,
        todaySales: results[1] as List<Sale>,
        todayPurchases: results[2] as List<Purchase>,
        pendingDebts: results[3] as List<Debt>,
        overdueDebts: results[4] as List<Debt>,
        monthlyProgress: _calculateMonthlyProgress(results[5] as List<DailyStatistics>),
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(DashboardError('فشل تصفية البيانات: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTodayStatistics(
    LoadTodayStatistics event,
    Emitter<DashboardState> emit,
  ) async {
    await _onLoadDashboard(LoadDashboard(), emit);
  }

  Future<void> _onLoadWeekStatistics(
    LoadWeekStatistics event,
    Emitter<DashboardState> emit,
  ) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    add(FilterDashboardByDateRange(startDate: weekAgo, endDate: now));
  }

  Future<void> _onLoadMonthStatistics(
    LoadMonthStatistics event,
    Emitter<DashboardState> emit,
  ) async {
    final now = DateTime.now();
    final monthAgo = DateTime(now.year, now.month - 1, now.day);
    add(FilterDashboardByDateRange(startDate: monthAgo, endDate: now));
  }

  Future<void> _onLoadRecentActivities(
    LoadRecentActivities event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final results = await Future.wait([
        _getTodaySales(today),
        _getTodayPurchases(today),
      ]);
      
      if (state is DashboardLoaded) {
        final currentState = state as DashboardLoaded;
        emit(currentState.copyWith(
          todaySales: results[0] as List<Sale>,
          todayPurchases: results[1] as List<Purchase>,
        ));
      }
    } catch (e) {
      emit(DashboardError('فشل تحميل الأنشطة: ${e.toString()}'));
    }
  }

  Future<void> _onExportData(
    ExportDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(DashboardExporting());
      
      await Future.delayed(const Duration(seconds: 2));
      
      final filePath = '/storage/dashboard_export_${DateTime.now().millisecondsSinceEpoch}.${event.format}';
      
      emit(DashboardExported(filePath));
      
      if (state is DashboardLoaded) {
        emit(state as DashboardLoaded);
      } else {
        add(LoadDashboard());
      }
    } catch (e) {
      emit(DashboardError('فشل تصدير البيانات: ${e.toString()}'));
    }
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
    
    const monthlyTarget = 100000.0;
    
    return (totalSales / monthlyTarget).clamp(0.0, 1.0);
  }
}
