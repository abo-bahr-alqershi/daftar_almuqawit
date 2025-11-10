/// Bloc إدارة التقارير
/// يدير إنشاء وعرض التقارير المختلفة

import 'package:bloc/bloc.dart';
import '../../../domain/usecases/reports/print_report.dart';
import '../../../domain/usecases/reports/share_report.dart';
import '../../../domain/usecases/statistics/get_daily_statistics.dart';
import '../../../domain/usecases/statistics/get_monthly_statistics.dart';
import '../../../core/services/logger_service.dart';
import 'reports_event.dart';
import 'reports_state.dart';

/// Bloc التقارير
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final PrintReport _printReport;
  final ShareReport _shareReport;
  final GetDailyStatistics _getDailyStats;
  final GetMonthlyStatistics _getMonthlyStats;
  final LoggerService _logger;
  
  ReportsBloc({
    required PrintReport printReport,
    required ShareReport shareReport,
    required GetDailyStatistics getDailyStats,
    required GetMonthlyStatistics getMonthlyStats,
    required LoggerService logger,
  })  : _printReport = printReport,
        _shareReport = shareReport,
        _getDailyStats = getDailyStats,
        _getMonthlyStats = getMonthlyStats,
        _logger = logger,
        super(ReportsInitial()) {
    on<GenerateDailyReportEvent>(_onGenerateDailyReport);
    on<GenerateMonthlyReportEvent>(_onGenerateMonthlyReport);
    on<PrintReportEvent>(_onPrintReport);
    on<ShareReportEvent>(_onShareReport);
  }
  
  Future<void> _onGenerateDailyReport(
    GenerateDailyReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      emit(ReportsLoading('جاري إنشاء التقرير اليومي...'));
      _logger.info('إنشاء تقرير يومي للتاريخ: ${event.date}');
      
      final stats = await _getDailyStats(
        GetDailyStatisticsParams(date: event.date)
      );
      
      if (stats == null) {
        emit(ReportsError('لا توجد بيانات لهذا التاريخ'));
        return;
      }
      
      final reportData = {
        'type': 'daily',
        'date': event.date,
        'statistics': stats.toJson(),
      };
      
      emit(ReportsLoaded(reportData));
      _logger.info('تم إنشاء التقرير اليومي بنجاح');
    } catch (e, s) {
      _logger.error('فشل إنشاء التقرير اليومي', error: e, stackTrace: s);
      emit(ReportsError('فشل إنشاء التقرير: ${e.toString()}'));
    }
  }
  
  Future<void> _onGenerateMonthlyReport(
    GenerateMonthlyReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      emit(ReportsLoading('جاري إنشاء التقرير الشهري...'));
      _logger.info('إنشاء تقرير شهري: ${event.year}/${event.month}');
      
      final stats = await _getMonthlyStats(
        (year: event.year, month: event.month),
      );
      
      final reportData = {
        'type': 'monthly',
        'year': event.year,
        'month': event.month,
        'statistics': stats.map((s) => s.toJson()).toList(),
      };
      
      emit(ReportsLoaded(reportData));
      _logger.info('تم إنشاء التقرير الشهري بنجاح');
    } catch (e, s) {
      _logger.error('فشل إنشاء التقرير الشهري', error: e, stackTrace: s);
      emit(ReportsError('فشل إنشاء التقرير: ${e.toString()}'));
    }
  }
  
  Future<void> _onPrintReport(
    PrintReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      emit(ReportsLoading('جاري طباعة التقرير...'));
      _logger.info('طباعة تقرير: ${event.reportType}');
      
      await _printReport(PrintReportParams(
        reportType: event.reportType,
        date: event.data['date'] as String?,
        year: event.data['year'] as int?,
        month: event.data['month'] as int?,
      ));
      
      emit(ReportsSuccess('تم إرسال التقرير للطباعة'));
      _logger.info('تم طباعة التقرير بنجاح');
    } catch (e, s) {
      _logger.error('فشل طباعة التقرير', error: e, stackTrace: s);
      emit(ReportsError('فشل طباعة التقرير: ${e.toString()}'));
    }
  }
  
  Future<void> _onShareReport(
    ShareReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      emit(ReportsLoading('جاري مشاركة التقرير...'));
      _logger.info('مشاركة تقرير: ${event.reportType}');
      
      await _shareReport(ShareReportParams(
        reportType: event.reportType,
        format: ShareFormat.pdf,
        date: event.data['date'] as String?,
        year: event.data['year'] as int?,
        month: event.data['month'] as int?,
      ));
      
      emit(ReportsSuccess('تم مشاركة التقرير بنجاح'));
      _logger.info('تم مشاركة التقرير بنجاح');
    } catch (e, s) {
      _logger.error('فشل مشاركة التقرير', error: e, stackTrace: s);
      emit(ReportsError('فشل مشاركة التقرير: ${e.toString()}'));
    }
  }
}
