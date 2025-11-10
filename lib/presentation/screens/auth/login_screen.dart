import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../navigation/route_names.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/loading_widget.dart';
import 'widgets/auth_header.dart';
import 'widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              rememberMe: _rememberMe,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.of(context).pushReplacementNamed(RouteNames.home);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger,
                ),
              );
            }
          },
          child: SafeArea(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Center(child: LoadingWidget());
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        
                        const AuthHeader(
                          title: 'مرحباً بك',
                          subtitle: 'سجل دخولك للمتابعة',
                        ),
                        
                        const SizedBox(height: 40),
                        
                        LoginForm(
                          emailController: _emailController,
                          passwordController: _passwordController,
                          obscurePassword: _obscurePassword,
                          rememberMe: _rememberMe,
                          onTogglePassword: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          onRememberMeChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          onForgotPassword: () {
                            Navigator.pushNamed(context, RouteNames.forgotPassword);
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        AppButton.primary(
                          text: 'تسجيل الدخول',
                          onPressed: _handleLogin,
                          fullWidth: true,
                          icon: Icons.login,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        AppButton.secondary(
                          text: 'إنشاء حساب جديد',
                          onPressed: () {
                            Navigator.pushNamed(context, RouteNames.register);
                          },
                          fullWidth: true,
                          icon: Icons.person_add,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        Center(
                          child: Text(
                            'أو تسجيل الدخول باستخدام',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialLoginButton(
                              icon: Icons.g_mobiledata,
                              label: 'Google',
                              onPressed: () {},
                            ),
                            const SizedBox(width: 16),
                            _SocialLoginButton(
                              icon: Icons.facebook,
                              label: 'Facebook',
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
