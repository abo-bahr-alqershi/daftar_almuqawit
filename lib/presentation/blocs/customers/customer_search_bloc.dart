/// Bloc إدارة البحث عن العملاء
/// يدير عمليات البحث والفلترة للعملاء

import 'package:bloc/bloc.dart';
import 'customer_search_event.dart';
import 'customer_search_state.dart';

/// Bloc البحث عن العملاء
class CustomerSearchBloc extends Bloc<CustomerSearchEvent, CustomerSearchState> {
  
  CustomerSearchBloc() : super(CustomerSearchInitial()) {
    on<SearchCustomers>(_onSearchCustomers);
    on<ClearSearch>(_onClearSearch);
  }

  /// معالج البحث عن العملاء
  Future<void> _onSearchCustomers(SearchCustomers event, Emitter<CustomerSearchState> emit) async {
    if (event.query.isEmpty) {
      emit(CustomerSearchInitial());
      return;
    }

    try {
      emit(CustomerSearchLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      
      // محاكاة نتائج البحث
      final results = [
        {'id': '1', 'name': 'عميل 1', 'phone': '0500000001'},
        {'id': '2', 'name': 'عميل 2', 'phone': '0500000002'},
      ];
      
      if (results.isEmpty) {
        emit(CustomerSearchEmpty(event.query));
      } else {
        emit(CustomerSearchLoaded(results, event.query));
      }
    } catch (e) {
      emit(CustomerSearchError('فشل البحث: ${e.toString()}'));
    }
  }

  /// معالج مسح البحث
  void _onClearSearch(ClearSearch event, Emitter<CustomerSearchState> emit) {
    emit(CustomerSearchInitial());
  }
}
