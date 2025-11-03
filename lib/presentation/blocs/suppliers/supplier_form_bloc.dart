/// Bloc إدارة نموذج المورد
/// يدير حالة نموذج إضافة وتعديل الموردين

import 'package:bloc/bloc.dart';
import 'supplier_form_event.dart';
import 'supplier_form_state.dart';

/// Bloc نموذج المورد
class SupplierFormBloc extends Bloc<SupplierFormEvent, SupplierFormState> {
  
  SupplierFormBloc() : super(SupplierFormInitial()) {
    on<LoadSupplierForEdit>(_onLoadSupplierForEdit);
    on<SupplierNameChanged>(_onNameChanged);
    on<SupplierPhoneChanged>(_onPhoneChanged);
    on<SupplierAddressChanged>(_onAddressChanged);
    on<SaveSupplier>(_onSaveSupplier);
    on<ResetSupplierForm>(_onResetForm);
  }

  /// معالج تحميل بيانات المورد للتعديل
  Future<void> _onLoadSupplierForEdit(LoadSupplierForEdit event, Emitter<SupplierFormState> emit) async {
    try {
      emit(SupplierFormLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(SupplierFormReady(
        name: 'مورد تجريبي',
        phone: '0500000000',
        address: 'العنوان التجريبي',
        isValid: true,
      ));
    } catch (e) {
      emit(SupplierFormError('فشل تحميل بيانات المورد: ${e.toString()}'));
    }
  }

  /// معالج تغيير اسم المورد
  void _onNameChanged(SupplierNameChanged event, Emitter<SupplierFormState> emit) {
    final currentState = state;
    if (currentState is SupplierFormReady) {
      emit(currentState.copyWith(
        name: event.name,
        isValid: _validateForm(event.name, currentState.phone),
      ));
    }
  }

  /// معالج تغيير رقم الهاتف
  void _onPhoneChanged(SupplierPhoneChanged event, Emitter<SupplierFormState> emit) {
    final currentState = state;
    if (currentState is SupplierFormReady) {
      emit(currentState.copyWith(
        phone: event.phone,
        isValid: _validateForm(currentState.name, event.phone),
      ));
    }
  }

  /// معالج تغيير العنوان
  void _onAddressChanged(SupplierAddressChanged event, Emitter<SupplierFormState> emit) {
    final currentState = state;
    if (currentState is SupplierFormReady) {
      emit(currentState.copyWith(address: event.address));
    }
  }

  /// معالج حفظ المورد
  Future<void> _onSaveSupplier(SaveSupplier event, Emitter<SupplierFormState> emit) async {
    final currentState = state;
    if (currentState is SupplierFormReady) {
      try {
        emit(SupplierFormLoading());
        await Future.delayed(const Duration(seconds: 1));
        emit(SupplierFormSuccess('تم حفظ المورد بنجاح'));
      } catch (e) {
        emit(SupplierFormError('فشل حفظ المورد: ${e.toString()}'));
      }
    }
  }

  /// معالج إعادة تعيين النموذج
  void _onResetForm(ResetSupplierForm event, Emitter<SupplierFormState> emit) {
    emit(SupplierFormReady());
  }

  /// التحقق من صحة النموذج
  bool _validateForm(String name, String phone) {
    return name.isNotEmpty && phone.isNotEmpty;
  }
}
