// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/navigation/route_names.dart';
// import 'presentation/screens/splash/splash_screen.dart'; // TODO: سيتم استخدامها لاحقاً
import 'presentation/navigation/route_observers.dart';
import 'core/di/service_locator.dart';
import 'presentation/blocs/app/app_bloc.dart';
import 'presentation/blocs/app/app_event.dart';
import 'presentation/blocs/splash/splash_bloc.dart';
import 'presentation/blocs/home/home_bloc.dart';

/// ملف التطبيق الرئيسي App
/// يحتوي على التهيئة العامة للتطبيق، السمات، التوجيه، والتعريب.
class App extends StatelessWidget {
  /// تطبيق دفتر المقاوت
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppBloc>(create: (_) => sl<AppBloc>()..add(AppStarted())),
        BlocProvider<SplashBloc>(create: (_) => sl<SplashBloc>()),
        BlocProvider<HomeBloc>(create: (_) => sl<HomeBloc>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'دفتر المقاوت',
        theme: AppTheme.light,
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: RouteNames.splash,
        navigatorObservers: [AppRouteObservers.routeObserver],
      ),
    );
  }
}
