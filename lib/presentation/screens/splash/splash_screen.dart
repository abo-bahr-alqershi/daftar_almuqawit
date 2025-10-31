// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../navigation/route_names.dart';
import 'widgets/logo_animation.dart';
import '../../blocs/splash/splash_bloc.dart';
import '../../blocs/splash/splash_event.dart';
import '../../blocs/splash/splash_state.dart';

/// شاشة البداية (Splash)
/// تعرض شعارًا بسيطًا ثم تنتقل للصفحة الرئيسية
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // تشغيل حدث البداية للـ BLoC
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
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LogoAnimation(),
                const SizedBox(height: 16),
                Text('دفتر المقاوت', style: AppTextStyles.headline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
