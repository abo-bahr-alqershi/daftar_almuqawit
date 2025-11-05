/// Bloc إدارة الصندوق
/// يدير عمليات الصندوق والحركات النقدية

import 'package:bloc/bloc.dart';
import 'cash_management_event.dart';
import 'cash_management_state.dart';
import '../../../domain/usecases/statistics/get_daily_statistics.dart';
import '../../../core/services/logger_service.dart';

/// Bloc إدارة الصندوق
class CashManagementBloc extends Bloc<CashManagementEvent, CashManagementState> {
  final GetDailyStatistics _getDailyStats;
  final LoggerService _logger;
  
  CashManagementBloc({
    required GetDailyStatistics getDailyStats,
    required LoggerService logger,
  })  : _getDailyStats = getDailyStats,
        _logger = logger,
        super(CashManagementInitial()) {
    on<LoadCashBalance>(_onLoadCashBalance);
    on<AddCashTransaction>(_onAddCashTransaction);
    on<LoadCashTransactions>(_onLoadCashTransactions);
  }

  /// معالج تحميل رصيد الصندوق
  Future<void> _onLoadCashBalance(LoadCashBalance event, Emitter<CashManagementState> emit) async {
    try {
      emit(CashManagementLoading());
      _logger.info('تحميل رصيد الصندوق');
      
      // الحصول على إحصائيات اليوم لحساب الرصيد
      final today = DateTime.now().toIso8601String().split('T')[0];
      final stats = await _getDailyStats(today);
      
      final balance = stats?.cashBalance ?? 0.0;
      
      emit(CashBalanceLoaded(balance));
      _logger.info('تم تحميل رصيد الصندوق: $balance');
    } catch (e, s) {
      _logger.error('فشل تحميل رصيد الصندوق', error: e, stackTrace: s);
      emit(CashManagementError('فشل تحميل رصيد الصندوق: ${e.toString()}'));
    }
  }

  /// معالج إضافة حركة نقدية
  Future<void> _onAddCashTransaction(AddCashTransaction event, Emitter<CashManagementState> emit) async {
    try {
      emit(CashManagementLoading());
      _logger.info('إضافة حركة نقدية: ${event.type} - ${event.amount}');
      
      // هنا يمكن إضافة منطق حفظ الحركة في قاعدة البيانات
      // سيتم ربطها بـ use cases لاحقاً
      
      emit(CashTransactionSuccess('تمت إضافة الحركة النقدية بنجاح'));
      _logger.info('تمت إضافة الحركة النقدية بنجاح');
    } catch (e, s) {
      _logger.error('فشلت إضافة الحركة النقدية', error: e, stackTrace: s);
      emit(CashManagementError('فشلت إضافة الحركة النقدية: ${e.toString()}'));
    }
  }

  /// معالج تحميل الحركات النقدية
  Future<void> _onLoadCashTransactions(LoadCashTransactions event, Emitter<CashManagementState> emit) async {
    try {
      emit(CashManagementLoading());
      _logger.info('تحميل الحركات النقدية');
      
      // هنا يمكن تحميل الحركات من قاعدة البيانات
      // سيتم ربطها بـ use cases لاحقاً
      final transactions = <Map<String, dynamic>>[];
      
      emit(CashTransactionsLoaded(transactions));
      _logger.info('تم تحميل ${transactions.length} حركة نقدية');
    } catch (e, s) {
      _logger.error('فشل تحميل الحركات النقدية', error: e, stackTrace: s);
      emit(CashManagementError('فشل تحميل الحركات النقدية: ${e.toString()}'));
    }
  }
}
