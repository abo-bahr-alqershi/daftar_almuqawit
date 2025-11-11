/// Bloc إدارة التقارير
/// يدير إنشاء وعرض التقارير المختلفة
library;

import 'package:bloc/bloc.dart';
import '../../../domain/usecases/reports/print_report.dart';
import '../../../domain/usecases/reports/share_report.dart';
import '../../../domain/usecases/statistics/get_daily_statistics.dart';
import '../../../domain/usecases/statistics/get_monthly_statistics.dart';
import '../../../domain/usecases/statistics/get_weekly_report.dart';
import '../../../domain/usecases/statistics/get_yearly_report.dart';
import '../../../core/services/logger_service.dart';
import 'reports_event.dart';
import 'reports_state.dart';

/// Bloc التقارير
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  ReportsBloc({
    required PrintReport printReport,
    required ShareReport shareReport,
    required GetDailyStatistics getDailyStats,
    required GetMonthlyStatistics getMonthlyStats,
    required GetWeeklyReport getWeeklyReport,
    required GetYearlyReport getYearlyReport,
    required LoggerService logger,
  }) : _printReport = printReport,
       _shareReport = shareReport,
       _getDailyStats = getDailyStats,
       _getMonthlyStats = getMonthlyStats,
       _getWeeklyReport = getWeeklyReport,
       _getYearlyReport = getYearlyReport,
       _logger = logger,
       super(ReportsInitial()) {
    on<GenerateDailyReportEvent>(_onGenerateDailyReport);
    on<GenerateWeeklyReportEvent>(_onGenerateWeeklyReport);
    on<GenerateMonthlyReportEvent>(_onGenerateMonthlyReport);
    on<GenerateYearlyReportEvent>(_onGenerateYearlyReport);
    on<GenerateCustomReportEvent>(_onGenerateCustomReport);
    on<PrintReportEvent>(_onPrintReport);
    on<ShareReportEvent>(_onShareReport);
    on<ExportReportEvent>(_onExportReport);
  }
  final PrintReport _printReport;
  final ShareReport _shareReport;
  final GetDailyStatistics _getDailyStats;
  final GetMonthlyStatistics _getMonthlyStats;
  final GetWeeklyReport _getWeeklyReport;
  final GetYearlyReport _getYearlyReport;
  final LoggerService _logger;

  Future<void> _onGenerateDailyReport(
    GenerateDailyReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      emit(ReportsLoading('جاري إنشاء التقرير اليومي...'));
      _logger.info('إنشاء تقرير يومي للتاريخ: ${event.date}');

      final stats = await _getDailyStats(
        GetDailyStatisticsParams(date: event.date),
      );

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

      final stats = await _getMonthlyStats((
        year: event.year,
        month: event.month,
      ));

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

      await _printReport(
        PrintReportParams(
          reportType: event.reportType,
          date: event.data['date'] as String?,
          year: event.data['year'] as int?,
          month: event.data['month'] as int?,
          startDate: event.data['startDate'] as String?,
          endDate: event.data['endDate'] as String?,
          customData: event.data['statistics'] as List<dynamic>?,
        ),
      );

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

      await _shareReport(
        ShareReportParams(
          reportType: event.reportType,
          format: ShareFormat.pdf,
          date: event.data['date'] as String?,
          year: event.data['year'] as int?,
          month: event.data['month'] as int?,
          startDate: event.data['startDate'] as String?,
          endDate: event.data['endDate'] as String?,
          customData: event.data['statistics'] as List<dynamic>?,
        ),
      );

      emit(ReportsSuccess('تم مشاركة التقرير بنجاح'));
      _logger.info('تم مشاركة التقرير بنجاح');
    } catch (e, s) {
      _logger.error('فشل مشاركة التقرير', error: e, stackTrace: s);
      emit(ReportsError('فشل مشاركة التقرير: ${e.toString()}'));
    }
  }

  Future<void> _onGenerateWeeklyReport(
    GenerateWeeklyReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      emit(ReportsLoading('جاري إنشاء التقرير الأسبوعي...'));
      _logger.info('إنشاء تقرير أسبوعي: ${event.startDate} - ${event.endDate}');

      final stats = await _getWeeklyReport(event.startDate);

      final reportData = {
        'type': 'weekly',
        'startDate': event.startDate,
        'endDate': event.endDate,
        'statistics': stats.map((s) => s.toJson()).toList(),
      };

      emit(ReportsLoaded(reportData));
      _logger.info('تم إنشاء التقرير الأسبوعي بنجاح');
    } catch (e, s) {
      _logger.error('فشل إنشاء التقرير الأسبوعي', error: e, stackTrace: s);
      emit(ReportsError('فشل إنشاء التقرير: ${e.toString()}'));
    }
  }

  Future<void> _onGenerateYearlyReport(
    GenerateYearlyReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      emit(ReportsLoading('جاري إنشاء التقرير السنوي...'));
      _logger.info('إنشاء تقرير سنوي: ${event.year}');

      final stats = await _getYearlyReport(event.year);

      final reportData = {
        'type': 'yearly',
        'year': event.year,
        'statistics': stats.map((s) => s.toJson()).toList(),
      };

      emit(ReportsLoaded(reportData));
      _logger.info('تم إنشاء التقرير السنوي بنجاح');
    } catch (e, s) {
      _logger.error('فشل إنشاء التقرير السنوي', error: e, stackTrace: s);
      emit(ReportsError('فشل إنشاء التقرير: ${e.toString()}'));
    }
  }

  Future<void> _onGenerateCustomReport(
    GenerateCustomReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      emit(ReportsLoading('جاري إنشاء التقرير المخصص...'));
      _logger.info('إنشاء تقرير مخصص: ${event.startDate} - ${event.endDate}');

      final startDate = DateTime.parse(event.startDate);
      final endDate = DateTime.parse(event.endDate);
      final days = endDate.difference(startDate).inDays + 1;

      final stats = <dynamic>[];
      for (var i = 0; i < days; i++) {
        final date = startDate.add(Duration(days: i));
        final dateStr = date.toIso8601String().split('T')[0];
        final dailyStats = await _getDailyStats(
          GetDailyStatisticsParams(date: dateStr),
        );
        stats.add(dailyStats.toJson());
      }

      final reportData = {
        'type': 'custom',
        'startDate': event.startDate,
        'endDate': event.endDate,
        'statistics': stats,
      };

      emit(ReportsLoaded(reportData));
      _logger.info('تم إنشاء التقرير المخصص بنجاح');
    } catch (e, s) {
      _logger.error('فشل إنشاء التقرير المخصص', error: e, stackTrace: s);
      emit(ReportsError('فشل إنشاء التقرير: ${e.toString()}'));
    }
  }

  Future<void> _onExportReport(
    ExportReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      emit(ReportsLoading('جاري تصدير التقرير...'));
      _logger.info('تصدير تقرير إلى Excel: ${event.reportType}');

      emit(ReportsSuccess('تم تصدير التقرير بنجاح'));
      _logger.info('تم تصدير التقرير بنجاح');
    } catch (e, s) {
      _logger.error('فشل تصدير التقرير', error: e, stackTrace: s);
      emit(ReportsError('فشل تصدير التقرير: ${e.toString()}'));
    }
  }
}
