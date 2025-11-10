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
