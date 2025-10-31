// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import 'accounting_event.dart';
import 'accounting_state.dart';

class AccountingBloc extends Bloc<AccountingEvent, AccountingState> {
  AccountingBloc() : super(AccountingInitial()) {
    on<AccountingStarted>((event, emit) => emit(AccountingInitial()));
  }
}
