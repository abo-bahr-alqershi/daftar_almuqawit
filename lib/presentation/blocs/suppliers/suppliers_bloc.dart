// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import '../../../domain/usecases/base/base_usecase.dart';
import '../../../domain/usecases/suppliers/add_supplier.dart';
import '../../../domain/usecases/suppliers/delete_supplier.dart';
import '../../../domain/usecases/suppliers/get_suppliers.dart';
import '../../../domain/usecases/suppliers/search_suppliers.dart';
import '../../../domain/usecases/suppliers/update_supplier.dart';
import 'suppliers_event.dart';
import 'suppliers_state.dart';

/// Bloc إدارة الموردين
class SuppliersBloc extends Bloc<SuppliersEvent, SuppliersState> {
  final GetSuppliers getSuppliers;
  final AddSupplier addSupplier;
  final UpdateSupplier updateSupplier;
  final DeleteSupplier deleteSupplier;
  final SearchSuppliers searchSuppliersUseCase;

  SuppliersBloc({
    required this.getSuppliers,
    required this.addSupplier,
    required this.updateSupplier,
    required this.deleteSupplier,
    required this.searchSuppliersUseCase,
  }) : super(SuppliersInitial()) {
    on<LoadSuppliers>(_onLoadSuppliers);
    on<AddSupplierEvent>(_onAddSupplier);
    on<UpdateSupplierEvent>(_onUpdateSupplier);
    on<DeleteSupplierEvent>(_onDeleteSupplier);
    on<SearchSuppliersEvent>(_onSearchSuppliers);
  }

  /// تحميل جميع الموردين
  Future<void> _onLoadSuppliers(
    LoadSuppliers event,
    Emitter<SuppliersState> emit,
  ) async {
    try {
      emit(SuppliersLoading());
      final suppliers = await getSuppliers(const GetSuppliersParams());
      emit(SuppliersLoaded(suppliers));
    } catch (e) {
      emit(SuppliersError('فشل تحميل الموردين: ${e.toString()}'));
    }
  }

  /// إضافة مورد جديد
  Future<void> _onAddSupplier(
    AddSupplierEvent event,
    Emitter<SuppliersState> emit,
  ) async {
    try {
      await addSupplier(event.supplier);
      emit(SupplierOperationSuccess('تم إضافة المورد بنجاح'));
      add(LoadSuppliers());
    } catch (e) {
      emit(SuppliersError('فشل إضافة المورد: ${e.toString()}'));
    }
  }

  /// تحديث مورد
  Future<void> _onUpdateSupplier(
    UpdateSupplierEvent event,
    Emitter<SuppliersState> emit,
  ) async {
    try {
      await updateSupplier(event.supplier);
      emit(SupplierOperationSuccess('تم تحديث المورد بنجاح'));
      add(LoadSuppliers());
    } catch (e) {
      emit(SuppliersError('فشل تحديث المورد: ${e.toString()}'));
    }
  }

  /// حذف مورد
  Future<void> _onDeleteSupplier(
    DeleteSupplierEvent event,
    Emitter<SuppliersState> emit,
  ) async {
    try {
      await deleteSupplier(event.id);
      emit(SupplierOperationSuccess('تم حذف المورد بنجاح'));
      add(LoadSuppliers());
    } catch (e) {
      emit(SuppliersError('فشل حذف المورد: ${e.toString()}'));
    }
  }

  /// البحث في الموردين
  Future<void> _onSearchSuppliers(
    SearchSuppliersEvent event,
    Emitter<SuppliersState> emit,
  ) async {
    try {
      emit(SuppliersLoading());
      final suppliers = await searchSuppliersUseCase(event.query);
      emit(SuppliersLoaded(suppliers));
    } catch (e) {
      emit(SuppliersError('فشل البحث: ${e.toString()}'));
    }
  }
}
