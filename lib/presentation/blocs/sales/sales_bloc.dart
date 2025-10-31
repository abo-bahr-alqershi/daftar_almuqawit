// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import 'sales_event.dart';
import 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  SalesBloc() : super(SalesInitial()) {
    on<SalesStarted>((event, emit) => emit(SalesInitial()));
  }
}
