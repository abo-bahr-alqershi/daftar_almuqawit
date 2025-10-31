// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppInitial()) {
    on<AppStarted>((event, emit) async {
      emit(AppReady());
    });
  }
}
