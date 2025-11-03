/// Bloc إدارة شاشة البداية
/// يدير عرض شاشة البداية والانتقال للشاشة الرئيسية

import 'package:bloc/bloc.dart';
import 'splash_event.dart';
import 'splash_state.dart';

/// Bloc شاشة البداية
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  /// معالج بدء شاشة البداية
  Future<void> _onSplashStarted(SplashStarted event, Emitter<SplashState> emit) async {
    await Future.delayed(const Duration(milliseconds: 600));
    emit(SplashNavigateToHome());
  }
}
