/// Bloc إدارة التقارير
/// يدير إنشاء وعرض التقارير المختلفة

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/usecases/reports/print_report.dart';
import '../../../domain/usecases/reports/share_report.dart';
import '../../../domain/usecases/statistics/get_daily_statistics.dart';
import '../../../domain/usecases/statistics/get_monthly_statistics.dart';
import '../../../core/services/logger_service.dart';

// Events
abstract class ReportsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GenerateDailyReportEvent extends ReportsEvent {
  final String date;
  
  GenerateDailyReportEvent(this.date);
  
  @override
  List<Object?> get props => [date];
}

class GenerateMonthlyReportEvent extends ReportsEvent {
  final int year;
  final int month;
  
  GenerateMonthlyReportEvent(this.year, this.month);
  
  @override
  List<Object?> get props => [year, month];
}

class PrintReportEvent extends ReportsEvent {
  final String reportType;
  final Map<String, dynamic> data;
  
  PrintReportEvent(this.reportType, this.data);
  
  @override
  List<Object?> get props => [reportType, data];
}

class ShareReportEvent extends ReportsEvent {
  final String reportType;
  final Map<String, dynamic> data;
  
  ShareReportEvent(this.reportType, this.data);
  
  @override
  List<Object?> get props => [reportType, data];
}

// States
abstract class ReportsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {
  final String message;
  
  ReportsLoading(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ReportsLoaded extends ReportsState {
  final Map<String, dynamic> reportData;
  
  ReportsLoaded(this.reportData);
  
  @override
  List<Object?> get props => [reportData];
}

class ReportsSuccess extends ReportsState {
  final String message;
  
  ReportsSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ReportsError extends ReportsState {
  final String message;
  
  ReportsError(this.message);
  
  @override
  List<Object?> get props => [message];
}

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
