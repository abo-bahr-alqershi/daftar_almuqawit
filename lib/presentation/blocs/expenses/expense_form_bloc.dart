/// Bloc إدارة نموذج المصروفات
/// يدير حالة نموذج إضافة وتعديل المصروفات

import 'package:bloc/bloc.dart';
import 'expense_form_event.dart';
import 'expense_form_state.dart';

/// Bloc نموذج المصروفات
class ExpenseFormBloc extends Bloc<ExpenseFormEvent, ExpenseFormState> {
  
  ExpenseFormBloc() : super(ExpenseFormInitial()) {
    on<ExpenseAmountChanged>(_onAmountChanged);
    on<ExpenseDescriptionChanged>(_onDescriptionChanged);
    on<SaveExpense>(_onSaveExpense);
  }

  void _onAmountChanged(ExpenseAmountChanged event, Emitter<ExpenseFormState> emit) {
    final currentState = state;
    if (currentState is ExpenseFormReady) {
      emit(currentState.copyWith(amount: event.amount, isValid: event.amount > 0 && currentState.description.isNotEmpty));
    } else {
      emit(ExpenseFormReady(amount: event.amount, isValid: event.amount > 0));
    }
  }

  void _onDescriptionChanged(ExpenseDescriptionChanged event, Emitter<ExpenseFormState> emit) {
    final currentState = state;
    if (currentState is ExpenseFormReady) {
      emit(currentState.copyWith(description: event.description, isValid: currentState.amount > 0 && event.description.isNotEmpty));
    } else {
      emit(ExpenseFormReady(description: event.description, isValid: event.description.isNotEmpty));
    }
  }

  Future<void> _onSaveExpense(SaveExpense event, Emitter<ExpenseFormState> emit) async {
    final currentState = state;
    if (currentState is ExpenseFormReady) {
      try {
        emit(ExpenseFormLoading());
        await Future.delayed(const Duration(seconds: 1));
        emit(ExpenseFormSuccess('تم حفظ المصروف بنجاح'));
      } catch (e) {
        emit(ExpenseFormError('فشل حفظ المصروف: ${e.toString()}'));
      }
    }
  }
}
