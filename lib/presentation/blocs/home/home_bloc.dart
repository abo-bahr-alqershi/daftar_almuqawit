/// Bloc إدارة الشاشة الرئيسية
/// يدير بيانات وحالة الشاشة الرئيسية

import 'package:bloc/bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

/// Bloc الشاشة الرئيسية
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeStarted>(_onHomeStarted);
  }

  /// معالج بدء الشاشة الرئيسية
  Future<void> _onHomeStarted(HomeStarted event, Emitter<HomeState> emit) async {
    // تحميل بيانات البداية للشاشة الرئيسية
    emit(HomeInitial());
  }
}
