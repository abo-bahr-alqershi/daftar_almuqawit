// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import 'expenses_event.dart';
import 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  ExpensesBloc() : super(ExpensesInitial()) {
    on<ExpensesStarted>((event, emit) => emit(ExpensesInitial()));
  }
}
