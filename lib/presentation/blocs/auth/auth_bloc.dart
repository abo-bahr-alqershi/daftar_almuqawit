/// Bloc إدارة المصادقة
/// يدير جميع العمليات المتعلقة بتسجيل الدخول والخروج

import 'package:bloc/bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'auth_validator.dart';
import '../../../core/services/firebase/firebase_auth_service.dart';
import '../../../core/services/local/shared_preferences_service.dart';

/// Bloc المصادقة
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthService _authService = FirebaseAuthService.instance;
  final SharedPreferencesService _prefsService = SharedPreferencesService.instance;

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
      
      // التحقق من صحة البيانات
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(AuthError('الرجاء إدخال البريد الإلكتروني وكلمة المرور'));
        return;
      }
      
      // استدعاء Firebase Auth Service
      final user = await _authService.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      
      if (user != null) {
        // حفظ حالة "تذكرني" إذا كانت مفعلة
        if (event.rememberMe) {
          await _prefsService.setBool('rememberMe', true);
          await _prefsService.setString('userEmail', event.email);
        }
        
        emit(AuthAuthenticated(
          user.uid,
          user.displayName ?? 'المستخدم',
          user.email ?? event.email,
        ));
      } else {
        emit(AuthError('فشل تسجيل الدخول. تحقق من البيانات المدخلة'));
      }
    } catch (e) {
      emit(AuthError('فشل تسجيل الدخول: ${e.toString()}'));
    }
  }

  /// معالج تسجيل حساب جديد
  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      // التحقق من صحة البيانات
      if (event.email.isEmpty || event.password.isEmpty || event.name.isEmpty) {
        emit(AuthError('الرجاء إدخال جميع البيانات المطلوبة'));
        return;
      }
      
      // التحقق من صحة البريد الإلكتروني
      if (!AuthValidator.isValidEmail(event.email)) {
        emit(AuthError('البريد الإلكتروني غير صالح'));
        return;
      }
      
      // التحقق من قوة كلمة المرور
      if (!AuthValidator.isStrongPassword(event.password)) {
        emit(AuthError('كلمة المرور ضعيفة. يجب أن تحتوي على 6 أحرف على الأقل'));
        return;
      }
      
      // استدعاء Firebase Auth Service
      final user = await _authService.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      
      if (user != null) {
        // تحديث اسم المستخدم
        await _authService.updateDisplayName(event.name);
        
        emit(AuthAuthenticated(
          user.uid,
          event.name,
          user.email ?? event.email,
        ));
      } else {
        emit(AuthError('فشل إنشاء الحساب. حاول مرة أخرى'));
      }
    } catch (e) {
      emit(AuthError('فشل التسجيل: ${e.toString()}'));
    }
  }

  /// معالج تسجيل الخروج
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      // استدعاء Firebase Auth Service للخروج
      await _authService.signOut();
      
      // مسح البيانات المحفوظة
      await _prefsService.remove('rememberMe');
      await _prefsService.remove('userEmail');
      
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
      
      // التحقق من Firebase Auth
      final currentUser = _authService.currentUser;
      
      if (currentUser != null) {
        emit(AuthAuthenticated(
          currentUser.uid,
          currentUser.displayName ?? 'المستخدم',
          currentUser.email ?? '',
        ));
      } else {
        // التحقق من وجود "تذكرني"
        final rememberMe = await _prefsService.getBool('rememberMe') ?? false;
        if (rememberMe) {
          final savedEmail = await _prefsService.getString('userEmail');
          if (savedEmail != null) {
            // يمكن محاولة تسجيل الدخول التلقائي هنا إذا كانت كلمة المرور محفوظة بشكل آمن
            emit(AuthUnauthenticated());
          } else {
            emit(AuthUnauthenticated());
          }
        } else {
          emit(AuthUnauthenticated());
        }
      }
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
      
      // التحقق من البريد الإلكتروني
      if (event.email.isEmpty) {
        emit(AuthError('الرجاء إدخال البريد الإلكتروني'));
        return;
      }
      
      if (!AuthValidator.isValidEmail(event.email)) {
        emit(AuthError('البريد الإلكتروني غير صالح'));
        return;
      }
      
      // استدعاء Firebase Auth لإرسال رابط إعادة تعيين كلمة المرور
      final result = await _authService.sendPasswordResetEmail(event.email);
      
      if (result) {
        emit(AuthPasswordResetSent(event.email));
      } else {
        emit(AuthError('فشل إرسال رابط إعادة تعيين كلمة المرور'));
      }
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
      
      // تحديث معلومات المستخدم في Firebase
      if (event.name != null) {
        await _authService.updateDisplayName(event.name!);
      }
      
      if (event.email != null) {
        await _authService.updateEmail(event.email!);
      }
      
      // تحديث الحالة بالمعلومات الجديدة
      final currentUser = _authService.currentUser;
      if (currentUser != null && currentState is AuthAuthenticated) {
        emit(AuthAuthenticated(
          currentUser.uid,
          currentUser.displayName ?? currentState.userName,
          currentUser.email ?? currentState.userEmail,
        ));
      }
    } catch (e) {
      emit(AuthError('فشل تحديث المعلومات: ${e.toString()}'));
    }
  }
}
