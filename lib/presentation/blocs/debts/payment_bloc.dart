/// Bloc إدارة الدفعات
/// يدير عمليات دفع وسداد الديون

import 'package:bloc/bloc.dart';
import 'payment_event.dart';
import 'payment_state.dart';

/// Bloc الدفعات
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  
  PaymentBloc() : super(PaymentInitial()) {
    on<ProcessPayment>(_onProcessPayment);
    on<LoadPaymentHistory>(_onLoadPaymentHistory);
  }

  /// معالج معالجة الدفعة
  Future<void> _onProcessPayment(ProcessPayment event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentProcessing());
      await Future.delayed(const Duration(seconds: 1));
      emit(PaymentSuccess('تم معالجة الدفعة بنجاح'));
    } catch (e) {
      emit(PaymentError('فشلت معالجة الدفعة: ${e.toString()}'));
    }
  }

  /// معالج تحميل سجل الدفعات
  Future<void> _onLoadPaymentHistory(LoadPaymentHistory event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentProcessing());
      await Future.delayed(const Duration(milliseconds: 500));
      final payments = [
        {'id': '1', 'amount': 100.0, 'date': '2025-01-01'},
        {'id': '2', 'amount': 200.0, 'date': '2025-01-02'},
      ];
      emit(PaymentHistoryLoaded(payments));
    } catch (e) {
      emit(PaymentError('فشل تحميل سجل الدفعات: ${e.toString()}'));
    }
  }
}
