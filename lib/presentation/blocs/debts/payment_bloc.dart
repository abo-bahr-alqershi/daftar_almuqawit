/// Bloc إدارة الدفعات
/// يدير عمليات إضافة وتحديث وحذف دفعات الديون باستخدام Use Cases

import 'package:bloc/bloc.dart';
import '../../../domain/usecases/debt_payments/add_debt_payment.dart';
import '../../../domain/usecases/debt_payments/update_debt_payment.dart';
import '../../../domain/usecases/debt_payments/delete_debt_payment.dart';
import '../../../domain/usecases/debt_payments/get_debt_payments_by_debt.dart';
import 'payment_event.dart';
import 'payment_state.dart';

/// Bloc الدفعات مع تكامل حقيقي مع Use Cases
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  /// حالة استخدام إضافة دفعة
  final AddDebtPayment addDebtPayment;
  
  /// حالة استخدام تحديث دفعة
  final UpdateDebtPayment updateDebtPayment;
  
  /// حالة استخدام حذف دفعة
  final DeleteDebtPayment deleteDebtPayment;
  
  /// حالة استخدام جلب دفعات دين معين
  final GetDebtPaymentsByDebt getDebtPaymentsByDebt;

  /// المُنشئ
  PaymentBloc({
    required this.addDebtPayment,
    required this.updateDebtPayment,
    required this.deleteDebtPayment,
    required this.getDebtPaymentsByDebt,
  }) : super(PaymentInitial()) {
    on<AddPaymentEvent>(_onAddPayment);
    on<UpdatePaymentEvent>(_onUpdatePayment);
    on<DeletePaymentEvent>(_onDeletePayment);
    on<LoadPaymentsByDebtEvent>(_onLoadPaymentsByDebt);
    on<ResetPaymentStateEvent>(_onResetState);
  }

  /// معالج إضافة دفعة جديدة
  Future<void> _onAddPayment(
    AddPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(PaymentLoading());
      
      // استدعاء Use Case لإضافة الدفعة
      final result = await addDebtPayment(event.payment);
      
      if (result > 0) {
        emit(PaymentAdded('تمت إضافة الدفعة بنجاح'));
      } else {
        emit(PaymentError('فشل في إضافة الدفعة'));
      }
    } catch (e) {
      emit(PaymentError('خطأ في إضافة الدفعة: ${e.toString()}'));
    }
  }

  /// معالج تحديث دفعة موجودة
  Future<void> _onUpdatePayment(
    UpdatePaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(PaymentLoading());
      
      // استدعاء Use Case لتحديث الدفعة
      await updateDebtPayment(event.payment);
      
      emit(PaymentUpdated('تم تحديث الدفعة بنجاح'));
    } catch (e) {
      emit(PaymentError('خطأ في تحديث الدفعة: ${e.toString()}'));
    }
  }

  /// معالج حذف دفعة
  Future<void> _onDeletePayment(
    DeletePaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(PaymentLoading());
      
      // استدعاء Use Case لحذف الدفعة
      await deleteDebtPayment(event.paymentId);
      
      emit(PaymentDeleted('تم حذف الدفعة بنجاح'));
    } catch (e) {
      emit(PaymentError('خطأ في حذف الدفعة: ${e.toString()}'));
    }
  }

  /// معالج تحميل دفعات دين معين
  Future<void> _onLoadPaymentsByDebt(
    LoadPaymentsByDebtEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(PaymentLoading());
      
      // استدعاء Use Case لجلب الدفعات
      final payments = await getDebtPaymentsByDebt(event.debtId);
      
      emit(PaymentsLoaded(payments));
    } catch (e) {
      emit(PaymentError('خطأ في تحميل الدفعات: ${e.toString()}'));
    }
  }

  /// معالج إعادة تعيين الحالة
  void _onResetState(
    ResetPaymentStateEvent event,
    Emitter<PaymentState> emit,
  ) {
    emit(PaymentInitial());
  }
}
