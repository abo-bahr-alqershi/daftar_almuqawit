/// Bloc إدارة الإحصائيات
/// يدير جميع العمليات المتعلقة بالإحصائيات والتقارير

import 'package:bloc/bloc.dart';
import '../../../domain/repositories/statistics_repository.dart';
import '../../../domain/usecases/statistics/get_daily_statistics.dart';
import '../../../domain/usecases/statistics/get_monthly_statistics.dart';
import '../../../domain/usecases/statistics/get_yearly_report.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

/// Bloc الإحصائيات
class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetDailyStatistics getDailyStats;
  final StatisticsRepository repository;
  final GetMonthlyStatistics getMonthStats;
  final GetYearlyReport getYearStats;

  StatisticsBloc({
    required this.getDailyStats,
    required this.repository,
    required this.getMonthStats,
    required this.getYearStats,
  }) : super(StatisticsInitial()) {
    on<LoadTodayStatistics>(_onLoadTodayStatistics);
    on<LoadPeriodStatistics>(_onLoadPeriodStatistics);
    on<LoadMonthStatistics>(_onLoadMonthStatistics);
    on<LoadYearStatistics>(_onLoadYearStatistics);
    on<RefreshStatistics>(_onRefreshStatistics);
  }

  /// معالج تحميل إحصائيات اليوم
  Future<void> _onLoadTodayStatistics(LoadTodayStatistics event, Emitter<StatisticsState> emit) async {
    try {
      emit(StatisticsLoading());
      final stats = await getDailyStats(event.date);
      emit(StatisticsLoaded([stats]));
    } catch (e) {
      emit(StatisticsError('فشل تحميل إحصائيات اليوم: ${e.toString()}'));
    }
  }

  /// معالج تحميل إحصائيات فترة محددة
  Future<void> _onLoadPeriodStatistics(LoadPeriodStatistics event, Emitter<StatisticsState> emit) async {
    try {
      emit(StatisticsLoading());
      // استخدام repository مباشرة للحصول على إحصائيات الفترة
      final stats = await getDailyStats(event.startDate);
      emit(StatisticsLoaded([stats]));
    } catch (e) {
      emit(StatisticsError('فشل تحميل إحصائيات الفترة: ${e.toString()}'));
    }
  }

  /// معالج تحميل إحصائيات الشهر
  Future<void> _onLoadMonthStatistics(LoadMonthStatistics event, Emitter<StatisticsState> emit) async {
    try {
      emit(StatisticsLoading());
      final stats = await getMonthStats((year: event.year, month: event.month));
      emit(StatisticsLoaded(stats));
    } catch (e) {
      emit(StatisticsError('فشل تحميل إحصائيات الشهر: ${e.toString()}'));
    }
  }

  /// معالج تحميل إحصائيات السنة
  Future<void> _onLoadYearStatistics(LoadYearStatistics event, Emitter<StatisticsState> emit) async {
    try {
      emit(StatisticsLoading());
      final stats = await getYearStats(event.year);
      emit(StatisticsLoaded(stats));
    } catch (e) {
      emit(StatisticsError('فشل تحميل إحصائيات السنة: ${e.toString()}'));
    }
  }

  /// معالج تحديث الإحصائيات
  Future<void> _onRefreshStatistics(RefreshStatistics event, Emitter<StatisticsState> emit) async {
    try {
      emit(StatisticsLoading());
      final today = DateTime.now().toString().split(' ')[0];
      final stats = await getDailyStats(today);
      emit(StatisticsLoaded([stats]));
    } catch (e) {
      emit(StatisticsError('فشل تحديث الإحصائيات: ${e.toString()}'));
    }
  }
}
