import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onGoogleLogin;
  final VoidCallback? onFacebookLogin;
  final VoidCallback? onAppleLogin;

  const SocialLoginButtons({
    super.key,
    this.onGoogleLogin,
    this.onFacebookLogin,
    this.onAppleLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SocialLoginButton(
          icon: Icons.g_mobiledata,
          label: 'الدخول باستخدام Google',
          backgroundColor: Colors.white,
          textColor: AppColors.textPrimary,
          onPressed: onGoogleLogin,
        ),
        
        const SizedBox(height: 12),
        
        _SocialLoginButton(
          icon: Icons.facebook,
          label: 'الدخول باستخدام Facebook',
          backgroundColor: const Color(0xFF1877F2),
          textColor: Colors.white,
          onPressed: onFacebookLogin,
        ),
        
        if (Theme.of(context).platform == TargetPlatform.iOS) ...[
          const SizedBox(height: 12),
          _SocialLoginButton(
            icon: Icons.apple,
            label: 'الدخول باستخدام Apple',
            backgroundColor: Colors.black,
            textColor: Colors.white,
            onPressed: onAppleLogin,
          ),
        ],
      ],
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor, size: 24),
        label: Text(
          label,
          style: AppTextStyles.button.copyWith(color: textColor),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: backgroundColor == Colors.white ? AppColors.border : backgroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/loading_widget.dart';
import 'widgets/auth_header.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            ForgotPasswordEvent(_emailController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthPasswordResetSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إرسال رابط إعادة تعيين كلمة المرور إلى ${state.email}'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
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
                          title: 'نسيت كلمة المرور',
                          subtitle: 'أدخل بريدك الإلكتروني لإعادة تعيين كلمة المرور',
                          showLogo: false,
                        ),
                        
                        const SizedBox(height: 40),
                        
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.infoLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.info.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.info,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'سنرسل لك رابطاً لإعادة تعيين كلمة المرور عبر البريد الإلكتروني',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.info,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        AppTextField(
                          controller: _emailController,
                          label: 'البريد الإلكتروني',
                          hint: 'أدخل بريدك الإلكتروني',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          validator: Validators.validateEmail,
                          onSubmitted: (_) => _handleResetPassword(),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        AppButton.primary(
                          text: 'إرسال رابط إعادة التعيين',
                          onPressed: _handleResetPassword,
                          fullWidth: true,
                          icon: Icons.send,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'العودة لتسجيل الدخول',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
