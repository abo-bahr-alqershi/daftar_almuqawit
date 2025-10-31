// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>((event, emit) async {
      await Future.delayed(const Duration(milliseconds: 600));
      emit(SplashNavigateToHome());
    });
  }
}
