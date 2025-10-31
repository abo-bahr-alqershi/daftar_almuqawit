// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthStarted>((event, emit) => emit(AuthInitial()));
  }
}
