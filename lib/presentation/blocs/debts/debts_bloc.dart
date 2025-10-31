// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import 'debts_event.dart';
import 'debts_state.dart';

class DebtsBloc extends Bloc<DebtsEvent, DebtsState> {
  DebtsBloc() : super(DebtsInitial()) {
    on<DebtsStarted>((event, emit) => emit(DebtsInitial()));
  }
}
