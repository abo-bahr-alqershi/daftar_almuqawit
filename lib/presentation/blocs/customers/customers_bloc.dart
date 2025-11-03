// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import '../../../domain/usecases/base/base_usecase.dart';
import '../../../domain/usecases/customers/add_customer.dart';
import '../../../domain/usecases/customers/block_customer.dart';
import '../../../domain/usecases/customers/delete_customer.dart';
import '../../../domain/usecases/customers/get_customers.dart';
import '../../../domain/usecases/customers/search_customers.dart';
import '../../../domain/usecases/customers/update_customer.dart';
import 'customers_event.dart';
import 'customers_state.dart';

class CustomersBloc extends Bloc<CustomersEvent, CustomersState> {
  final GetCustomers getCustomers;
  final AddCustomer addCustomer;
  final UpdateCustomer updateCustomer;
  final DeleteCustomer deleteCustomer;
  final BlockCustomer blockCustomer;
  final SearchCustomers searchCustomersUseCase;

  CustomersBloc({
    required this.getCustomers,
    required this.addCustomer,
    required this.updateCustomer,
    required this.deleteCustomer,
    required this.blockCustomer,
    required this.searchCustomersUseCase,
  }) : super(CustomersInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<AddCustomerEvent>(_onAddCustomer);
    on<UpdateCustomerEvent>(_onUpdateCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
    on<BlockCustomerEvent>(_onBlockCustomer);
    on<SearchCustomersEvent>(_onSearchCustomers);
  }

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomersState> emit,
  ) async {
    try {
      emit(CustomersLoading());
      final customers = await getCustomers(NoParams());
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(CustomersError('فشل تحميل العملاء: ${e.toString()}'));
    }
  }

  Future<void> _onAddCustomer(
    AddCustomerEvent event,
    Emitter<CustomersState> emit,
  ) async {
    try {
      await addCustomer(event.customer);
      emit(CustomerOperationSuccess('تم إضافة العميل بنجاح'));
      add(LoadCustomers());
    } catch (e) {
      emit(CustomersError('فشل إضافة العميل: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomerEvent event,
    Emitter<CustomersState> emit,
  ) async {
    try {
      await updateCustomer(event.customer);
      emit(CustomerOperationSuccess('تم تحديث العميل بنجاح'));
      add(LoadCustomers());
    } catch (e) {
      emit(CustomersError('فشل تحديث العميل: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomerEvent event,
    Emitter<CustomersState> emit,
  ) async {
    try {
      await deleteCustomer(event.id);
      emit(CustomerOperationSuccess('تم حذف العميل بنجاح'));
      add(LoadCustomers());
    } catch (e) {
      emit(CustomersError('فشل حذف العميل: ${e.toString()}'));
    }
  }

  Future<void> _onBlockCustomer(
    BlockCustomerEvent event,
    Emitter<CustomersState> emit,
  ) async {
    try {
      await blockCustomer((id: event.id, isBlocked: event.block));
      final msg = event.block ? 'تم حظر العميل' : 'تم إلغاء حظر العميل';
      emit(CustomerOperationSuccess(msg));
      add(LoadCustomers());
    } catch (e) {
      emit(CustomersError('فشل العملية: ${e.toString()}'));
    }
  }

  Future<void> _onSearchCustomers(
    SearchCustomersEvent event,
    Emitter<CustomersState> emit,
  ) async {
    try {
      emit(CustomersLoading());
      final customers = await searchCustomersUseCase(event.query);
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(CustomersError('فشل البحث: ${e.toString()}'));
    }
  }
}
