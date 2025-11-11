import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../navigation/route_names.dart';
import 'widgets/logo_animation.dart';
import '../../blocs/splash/splash_bloc.dart';
import '../../blocs/splash/splash_event.dart';
import '../../blocs/splash/splash_state.dart';

/// شاشة Splash - أول شاشة تظهر عند فتح التطبيق
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SplashBloc>().add(SplashStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateToHome) {
          Navigator.of(context).pushReplacementNamed(RouteNames.home);
        }
      },
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                const LogoAnimation(),
                
                const SizedBox(height: 32),
                
                Text(
                  'دفتر المقوت',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textOnDark,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'نظام محاسبي متكامل لإدارة تجارة القات',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textOnDark.withOpacity(0.9),
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const Spacer(),
                
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.textOnDark,
                    ),
                    strokeWidth: 3,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'جاري التحميل...',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textOnDark.withOpacity(0.7),
                  ),
                ),
                
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
