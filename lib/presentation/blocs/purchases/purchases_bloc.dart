// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import 'purchases_event.dart';
import 'purchases_state.dart';

class PurchasesBloc extends Bloc<PurchasesEvent, PurchasesState> {
  PurchasesBloc() : super(PurchasesInitial()) {
    on<PurchasesStarted>((event, emit) => emit(PurchasesInitial()));
  }
}
