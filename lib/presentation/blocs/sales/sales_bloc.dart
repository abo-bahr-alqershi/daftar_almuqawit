// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import '../../../domain/usecases/base/base_usecase.dart';
import '../../../domain/usecases/sales/add_sale.dart';
import '../../../domain/usecases/sales/cancel_sale.dart';
import '../../../domain/usecases/sales/delete_sale.dart';
import '../../../domain/usecases/sales/get_sales.dart';
import '../../../domain/usecases/sales/get_sales_by_customer.dart';
import '../../../domain/usecases/sales/get_today_sales.dart';
import '../../../domain/usecases/sales/update_sale.dart';
import 'sales_event.dart';
import 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final GetSales getSales;
  final GetTodaySales getTodaySales;
  final GetSalesByCustomer getSalesByCustomer;
  final AddSale addSale;
  final UpdateSale updateSale;
  final DeleteSale deleteSale;
  final CancelSale cancelSale;

  SalesBloc({
    required this.getSales,
    required this.getTodaySales,
    required this.getSalesByCustomer,
    required this.addSale,
    required this.updateSale,
    required this.deleteSale,
    required this.cancelSale,
  }) : super(SalesInitial()) {
    on<LoadSales>(_onLoadSales);
    on<LoadTodaySales>(_onLoadTodaySales);
    on<LoadSalesByCustomer>(_onLoadSalesByCustomer);
    on<AddSaleEvent>(_onAddSale);
    on<UpdateSaleEvent>(_onUpdateSale);
    on<DeleteSaleEvent>(_onDeleteSale);
    on<CancelSaleEvent>(_onCancelSale);
  }

  Future<void> _onLoadSales(LoadSales event, Emitter<SalesState> emit) async {
    try {
      emit(SalesLoading());
      final sales = await getSales(NoParams());
      emit(SalesLoaded(sales));
    } catch (e) {
      emit(SalesError('فشل تحميل المبيعات: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTodaySales(LoadTodaySales event, Emitter<SalesState> emit) async {
    try {
      emit(SalesLoading());
      final sales = await getTodaySales(event.date);
      emit(SalesLoaded(sales));
    } catch (e) {
      emit(SalesError('فشل تحميل مبيعات اليوم: ${e.toString()}'));
    }
  }

  Future<void> _onLoadSalesByCustomer(LoadSalesByCustomer event, Emitter<SalesState> emit) async {
    try {
      emit(SalesLoading());
      final sales = await getSalesByCustomer(event.customerId);
      emit(SalesLoaded(sales));
    } catch (e) {
      emit(SalesError('فشل تحميل مبيعات العميل: ${e.toString()}'));
    }
  }

  Future<void> _onAddSale(AddSaleEvent event, Emitter<SalesState> emit) async {
    try {
      await addSale(event.sale);
      emit(SaleOperationSuccess('تم إضافة البيع بنجاح'));
      add(LoadSales());
    } catch (e) {
      emit(SalesError('فشل إضافة البيع: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateSale(UpdateSaleEvent event, Emitter<SalesState> emit) async {
    try {
      await updateSale(event.sale);
      emit(SaleOperationSuccess('تم تحديث البيع بنجاح'));
      add(LoadSales());
    } catch (e) {
      emit(SalesError('فشل تحديث البيع: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteSale(DeleteSaleEvent event, Emitter<SalesState> emit) async {
    try {
      await deleteSale(event.id);
      emit(SaleOperationSuccess('تم حذف البيع بنجاح'));
      add(LoadSales());
    } catch (e) {
      emit(SalesError('فشل حذف البيع: ${e.toString()}'));
    }
  }

  Future<void> _onCancelSale(CancelSaleEvent event, Emitter<SalesState> emit) async {
    try {
      await cancelSale(event.id);
      emit(SaleOperationSuccess('تم إلغاء البيع بنجاح'));
      add(LoadSales());
    } catch (e) {
      emit(SalesError('فشل إلغاء البيع: ${e.toString()}'));
    }
  }
}
