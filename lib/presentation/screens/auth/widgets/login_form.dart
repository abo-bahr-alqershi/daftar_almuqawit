import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showLogo;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showLogo) ...[
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.eco,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text(
          title,
          style: AppTextStyles.h1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../widgets/common/app_text_field.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onForgotPassword;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.onTogglePassword,
    required this.onRememberMeChanged,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: emailController,
          label: 'البريد الإلكتروني',
          hint: 'أدخل بريدك الإلكتروني',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: Validators.validateEmail,
        ),
        
        const SizedBox(height: 16),
        
        AppTextField(
          controller: passwordController,
          label: 'كلمة المرور',
          hint: 'أدخل كلمة المرور',
          prefixIcon: Icons.lock_outline,
          suffixIcon: obscurePassword ? Icons.visibility : Icons.visibility_off,
          onSuffixIconTap: onTogglePassword,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          validator: Validators.validatePassword,
        ),
        
        const SizedBox(height: 12),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: onRememberMeChanged,
                  activeColor: AppColors.primary,
                ),
                Text(
                  'تذكرني',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: onForgotPassword,
              child: Text(
                'نسيت كلمة المرور؟',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
