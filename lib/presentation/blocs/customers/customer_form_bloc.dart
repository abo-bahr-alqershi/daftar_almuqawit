/// Bloc إدارة نموذج العميل
/// يدير حالة نموذج إضافة وتعديل العملاء

import 'package:bloc/bloc.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/usecases/base/base_usecase.dart';
import '../../../domain/usecases/customers/add_customer.dart';
import '../../../domain/usecases/customers/get_customers.dart';
import '../../../domain/usecases/customers/update_customer.dart';
import 'customer_form_event.dart';
import 'customer_form_state.dart';

/// Bloc نموذج العميل
class CustomerFormBloc extends Bloc<CustomerFormEvent, CustomerFormState> {
  final AddCustomer addCustomer;
  final UpdateCustomer updateCustomer;
  final GetCustomers getCustomers;
  
  CustomerFormBloc({
    required this.addCustomer,
    required this.updateCustomer,
    required this.getCustomers,
  }) : super(CustomerFormInitial()) {
    on<LoadCustomerForEdit>(_onLoadCustomerForEdit);
    on<CustomerNameChanged>(_onNameChanged);
    on<CustomerPhoneChanged>(_onPhoneChanged);
    on<CustomerAddressChanged>(_onAddressChanged);
    on<SaveCustomer>(_onSaveCustomer);
    on<ResetCustomerForm>(_onResetForm);
  }

  /// معالج تحميل بيانات العميل للتعديل
  Future<void> _onLoadCustomerForEdit(LoadCustomerForEdit event, Emitter<CustomerFormState> emit) async {
    try {
      emit(CustomerFormLoading());
      final customers = await getCustomers(const NoParams());
      final customer = customers.firstWhere((c) => c.id.toString() == event.customerId);
      emit(CustomerFormReady(
        name: customer.name,
        phone: customer.phone ?? '',
        address: customer.notes ?? '',
        isValid: true,
      ));
    } catch (e) {
      emit(CustomerFormError('فشل تحميل بيانات العميل: ${e.toString()}'));
    }
  }

  /// معالج تغيير اسم العميل
  void _onNameChanged(CustomerNameChanged event, Emitter<CustomerFormState> emit) {
    final currentState = state;
    if (currentState is CustomerFormReady) {
      emit(currentState.copyWith(
        name: event.name,
        isValid: _validateForm(event.name, currentState.phone),
      ));
    }
  }

  /// معالج تغيير رقم الهاتف
  void _onPhoneChanged(CustomerPhoneChanged event, Emitter<CustomerFormState> emit) {
    final currentState = state;
    if (currentState is CustomerFormReady) {
      emit(currentState.copyWith(
        phone: event.phone,
        isValid: _validateForm(currentState.name, event.phone),
      ));
    }
  }

  /// معالج تغيير العنوان
  void _onAddressChanged(CustomerAddressChanged event, Emitter<CustomerFormState> emit) {
    final currentState = state;
    if (currentState is CustomerFormReady) {
      emit(currentState.copyWith(address: event.address));
    }
  }

  /// معالج حفظ العميل
  Future<void> _onSaveCustomer(SaveCustomer event, Emitter<CustomerFormState> emit) async {
    final currentState = state;
    if (currentState is CustomerFormReady) {
      try {
        emit(CustomerFormLoading());
        final customer = Customer(
          name: currentState.name,
          phone: currentState.phone,
          notes: currentState.address,
          customerType: 'عادي',
          creditLimit: 0,
          totalPurchases: 0,
          currentDebt: 0,
          isBlocked: false,
        );
        await addCustomer(customer);
        emit(CustomerFormSuccess('تم حفظ العميل بنجاح'));
      } catch (e) {
        emit(CustomerFormError('فشل حفظ العميل: ${e.toString()}'));
      }
    }
  }

  /// معالج إعادة تعيين النموذج
  void _onResetForm(ResetCustomerForm event, Emitter<CustomerFormState> emit) {
    emit(CustomerFormReady());
  }

  /// التحقق من صحة النموذج
  bool _validateForm(String name, String phone) {
    return name.isNotEmpty && phone.isNotEmpty;
  }
}
