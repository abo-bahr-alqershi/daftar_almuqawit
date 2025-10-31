// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeStarted>((event, emit) async {
      // TODO: تحميل بيانات البداية للشاشة الرئيسية
      emit(HomeInitial());
    });
  }
}
