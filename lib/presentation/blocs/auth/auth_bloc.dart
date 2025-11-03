/// Bloc إدارة المصادقة
/// يدير جميع العمليات المتعلقة بتسجيل الدخول والخروج

import 'package:bloc/bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Bloc المصادقة
class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<SignUpEvent>(_onSignUp);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<UpdateUserInfoEvent>(_onUpdateUserInfo);
  }

  /// معالج تسجيل الدخول بالبريد وكلمة المرور
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      // TODO: استدعاء Firebase Auth Service
      // التحقق من صحة البيانات
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(AuthError('الرجاء إدخال البريد الإلكتروني وكلمة المرور'));
        return;
      }
      
      // محاكاة تسجيل الدخول
      await Future.delayed(const Duration(seconds: 1));
      
      // حفظ حالة "تذكرني" إذا كانت مفعلة
      if (event.rememberMe) {
        // TODO: حفظ في SharedPreferences
      }
      
      emit(AuthAuthenticated('user_123', 'المستخدم', event.email));
    } catch (e) {
      emit(AuthError('فشل تسجيل الدخول: ${e.toString()}'));
    }
  }

  /// معالج تسجيل حساب جديد
  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      // TODO: استدعاء Firebase Auth Service
      // التحقق من صحة البيانات
      if (event.email.isEmpty || event.password.isEmpty || event.name.isEmpty) {
        emit(AuthError('الرجاء إدخال جميع البيانات المطلوبة'));
        return;
      }
      
      // التحقق من قوة كلمة المرور
      if (event.password.length < 6) {
        emit(AuthError('كلمة المرور يجب أن تكون 6 أحرف على الأقل'));
        return;
      }
      
      await Future.delayed(const Duration(seconds: 1));
      emit(AuthAuthenticated('user_new', event.name, event.email));
    } catch (e) {
      emit(AuthError('فشل التسجيل: ${e.toString()}'));
    }
  }

  /// معالج تسجيل الخروج
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      // TODO: استدعاء Firebase Auth Service للخروج
      // مسح البيانات المحفوظة
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('فشل تسجيل الخروج: ${e.toString()}'));
    }
  }

  /// معالج التحقق من حالة المصادقة
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      
      // TODO: التحقق من Firebase Auth
      // التحقق من وجود مستخدم مسجل في SharedPreferences
      await Future.delayed(const Duration(milliseconds: 500));
      
      // إذا كان هناك مستخدم محفوظ
      // emit(AuthAuthenticated(userId, userName, email));
      
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('فشل التحقق: ${e.toString()}'));
    }
  }

  /// معالج استعادة كلمة المرور
  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      
      // TODO: استدعاء Firebase Auth لإرسال رابط إعادة تعيين كلمة المرور
      if (event.email.isEmpty) {
        emit(AuthError('الرجاء إدخال البريد الإلكتروني'));
        return;
      }
      
      await Future.delayed(const Duration(seconds: 1));
      emit(AuthPasswordResetSent(event.email));
    } catch (e) {
      emit(AuthError('فشل إرسال رابط إعادة التعيين: ${e.toString()}'));
    }
  }

  /// معالج تحديث معلومات المستخدم
  Future<void> _onUpdateUserInfo(
    UpdateUserInfoEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! AuthAuthenticated) {
        emit(AuthError('يجب تسجيل الدخول أولاً'));
        return;
      }
      
      emit(AuthLoading());
      
      // TODO: تحديث معلومات المستخدم في Firebase
      await Future.delayed(const Duration(milliseconds: 500));
      
      // تحديث الحالة بالمعلومات الجديدة
      emit(AuthAuthenticated(
        currentState.userId,
        event.name ?? currentState.userName,
        currentState.email,
        phone: event.phone ?? currentState.phone,
        photoUrl: event.photoUrl ?? currentState.photoUrl,
      ));
    } catch (e) {
      emit(AuthError('فشل تحديث المعلومات: ${e.toString()}'));
    }
  }
}
