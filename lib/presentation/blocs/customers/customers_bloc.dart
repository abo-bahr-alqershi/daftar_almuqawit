// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import 'customers_event.dart';
import 'customers_state.dart';

class CustomersBloc extends Bloc<CustomersEvent, CustomersState> {
  CustomersBloc() : super(CustomersInitial()) {
    on<CustomersStarted>((event, emit) => emit(CustomersInitial()));
  }
}
