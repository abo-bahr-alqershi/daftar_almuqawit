// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import 'suppliers_event.dart';
import 'suppliers_state.dart';

class SuppliersBloc extends Bloc<SuppliersEvent, SuppliersState> {
  SuppliersBloc() : super(SuppliersInitial()) {
    on<SuppliersStarted>((event, emit) async {
      emit(SuppliersInitial());
    });
  }
}
