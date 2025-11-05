/// Bloc إدارة الديون
/// يدير جميع العمليات المتعلقة بالديون والمدفوعات

import 'package:bloc/bloc.dart';
import '../../../domain/entities/debt_payment.dart';
import '../../../domain/usecases/base/base_usecase.dart';
import '../../../domain/usecases/debts/add_debt.dart';
import '../../../domain/usecases/debts/delete_debt.dart';
import '../../../domain/usecases/debts/get_debts.dart';
import '../../../domain/usecases/debts/get_debts_by_person.dart';
import '../../../domain/usecases/debts/get_overdue_debts.dart';
import '../../../domain/usecases/debts/get_pending_debts.dart';
import '../../../domain/usecases/debts/partial_payment.dart';
import '../../../domain/usecases/debts/update_debt.dart';
import 'debts_event.dart';
import 'debts_state.dart';

/// Bloc الديون
class DebtsBloc extends Bloc<DebtsEvent, DebtsState> {
  final GetDebts getDebts;
  final GetPendingDebts getPendingDebts;
  final GetOverdueDebts getOverdueDebts;
  final GetDebtsByPerson getDebtsByPerson;
  final AddDebt addDebt;
  final UpdateDebt updateDebt;
  final DeleteDebt deleteDebt;
  final PartialPayment partialPayment;

  DebtsBloc({
    required this.getDebts,
    required this.getPendingDebts,
    required this.getOverdueDebts,
    required this.getDebtsByPerson,
    required this.addDebt,
    required this.updateDebt,
    required this.deleteDebt,
    required this.partialPayment,
  }) : super(DebtsInitial()) {
    on<LoadDebts>(_onLoadDebts);
    on<LoadPendingDebts>(_onLoadPendingDebts);
    on<LoadOverdueDebts>(_onLoadOverdueDebts);
    on<LoadDebtsByPerson>(_onLoadDebtsByPerson);
    on<AddDebtEvent>(_onAddDebt);
    on<UpdateDebtEvent>(_onUpdateDebt);
    on<DeleteDebtEvent>(_onDeleteDebt);
    on<PayDebtEvent>(_onPayDebt);
  }

  /// معالج تحميل جميع الديون
  Future<void> _onLoadDebts(LoadDebts event, Emitter<DebtsState> emit) async {
    try {
      emit(DebtsLoading());
      final debts = await getDebts(NoParams());
      emit(DebtsLoaded(debts));
    } catch (e) {
      emit(DebtsError('فشل تحميل الديون: ${e.toString()}'));
    }
  }

  /// معالج تحميل الديون المعلقة
  Future<void> _onLoadPendingDebts(LoadPendingDebts event, Emitter<DebtsState> emit) async {
    try {
      emit(DebtsLoading());
      final debts = await getPendingDebts(NoParams());
      emit(DebtsLoaded(debts));
    } catch (e) {
      emit(DebtsError('فشل تحميل الديون المعلقة: ${e.toString()}'));
    }
  }

  /// معالج تحميل الديون المتأخرة
  Future<void> _onLoadOverdueDebts(LoadOverdueDebts event, Emitter<DebtsState> emit) async {
    try {
      emit(DebtsLoading());
      final today = DateTime.now().toString().split(' ')[0];
      final debts = await getOverdueDebts(today);
      emit(DebtsLoaded(debts));
    } catch (e) {
      emit(DebtsError('فشل تحميل الديون المتأخرة: ${e.toString()}'));
    }
  }

  /// معالج تحميل ديون شخص معين
  Future<void> _onLoadDebtsByPerson(LoadDebtsByPerson event, Emitter<DebtsState> emit) async {
    try {
      emit(DebtsLoading());
      final debts = await getDebtsByPerson((personType: event.personType, personId: event.personId));
      emit(DebtsLoaded(debts));
    } catch (e) {
      emit(DebtsError('فشل تحميل ديون الشخص: ${e.toString()}'));
    }
  }

  /// معالج إضافة دين جديد
  Future<void> _onAddDebt(AddDebtEvent event, Emitter<DebtsState> emit) async {
    try {
      final debt = event.debt;
      final params = AddDebtParams(
        customerId: debt.personId,
        amount: debt.originalAmount,
        transactionType: debt.transactionType,
        transactionId: debt.transactionId,
        dueDate: debt.dueDate != null ? DateTime.parse(debt.dueDate!) : null,
        notes: debt.notes,
      );
      await addDebt(params);
      emit(DebtOperationSuccess('تم إضافة الدين بنجاح'));
      add(LoadDebts());
    } catch (e) {
      emit(DebtsError('فشل إضافة الدين: ${e.toString()}'));
    }
  }

  /// معالج تحديث دين
  Future<void> _onUpdateDebt(UpdateDebtEvent event, Emitter<DebtsState> emit) async {
    try {
      await updateDebt(event.debt);
      emit(DebtOperationSuccess('تم تحديث الدين بنجاح'));
      add(LoadDebts());
    } catch (e) {
      emit(DebtsError('فشل تحديث الدين: ${e.toString()}'));
    }
  }

  /// معالج حذف دين
  Future<void> _onDeleteDebt(DeleteDebtEvent event, Emitter<DebtsState> emit) async {
    try {
      await deleteDebt(event.id);
      emit(DebtOperationSuccess('تم حذف الدين بنجاح'));
      add(LoadDebts());
    } catch (e) {
      emit(DebtsError('فشل حذف الدين: ${e.toString()}'));
    }
  }

  /// معالج سداد دين (دفعة جزئية)
  Future<void> _onPayDebt(PayDebtEvent event, Emitter<DebtsState> emit) async {
    try {
      final now = DateTime.now();
      final payment = DebtPayment(
        debtId: event.id,
        amount: event.amount,
        paymentDate: now.toString().split(' ')[0],
        paymentTime: '${now.hour}:${now.minute}',
      );
      await partialPayment(payment);
      emit(DebtOperationSuccess('تم تسجيل الدفعة بنجاح'));
      add(LoadDebts());
    } catch (e) {
      emit(DebtsError('فشل تسجيل الدفعة: ${e.toString()}'));
    }
  }
}
