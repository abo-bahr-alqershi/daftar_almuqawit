// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/navigation/route_names.dart';
import 'presentation/navigation/route_observers.dart';
import 'core/di/service_locator.dart';
import 'core/localization/app_localizations.dart';
import 'presentation/blocs/app/app_bloc.dart';
import 'presentation/blocs/app/app_event.dart';
import 'presentation/blocs/app/app_state.dart';
import 'presentation/blocs/app/app_settings_bloc.dart';
import 'presentation/blocs/splash/splash_bloc.dart';
import 'presentation/blocs/home/home_bloc.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/sync/sync_bloc.dart';
import 'presentation/blocs/home/dashboard_bloc.dart';
import 'presentation/blocs/suppliers/suppliers_bloc.dart';
import 'presentation/blocs/customers/customers_bloc.dart';
import 'presentation/blocs/customers/customer_form_bloc.dart';
import 'presentation/blocs/qat_types/qat_types_bloc.dart';
import 'presentation/blocs/sales/sales_bloc.dart';
import 'presentation/blocs/sales/quick_sale/quick_sale_bloc.dart';
import 'presentation/blocs/purchases/purchases_bloc.dart';
import 'presentation/blocs/debts/debts_bloc.dart';
import 'presentation/blocs/expenses/expenses_bloc.dart';
import 'presentation/blocs/statistics/statistics_bloc.dart';
import 'presentation/blocs/statistics/reports_bloc.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/blocs/debts/payment_bloc.dart';
import 'presentation/blocs/accounting/accounting_bloc.dart';

/// ملف التطبيق الرئيسي App
/// يحتوي على التهيئة العامة للتطبيق، السمات، التوجيه، والتعريب.
class App extends StatelessWidget {
  /// تطبيق دفتر المقوت
  const App({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      // Core Blocs
      BlocProvider<AppBloc>(create: (_) => sl<AppBloc>()..add(AppStarted())),
      BlocProvider<AppSettingsBloc>(create: (_) => sl<AppSettingsBloc>()),
      BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
      BlocProvider<SyncBloc>(create: (_) => sl<SyncBloc>()),

      // Screen Blocs
      BlocProvider<SplashBloc>(create: (_) => sl<SplashBloc>()),
      BlocProvider<HomeBloc>(create: (_) => sl<HomeBloc>()),
      BlocProvider<DashboardBloc>(create: (_) => sl<DashboardBloc>()),

      // Business Blocs
      BlocProvider<SuppliersBloc>(create: (_) => sl<SuppliersBloc>()),
      BlocProvider<CustomersBloc>(create: (_) => sl<CustomersBloc>()),
      BlocProvider<CustomerFormBloc>(create: (_) => sl<CustomerFormBloc>()),
      BlocProvider<QatTypesBloc>(create: (_) => sl<QatTypesBloc>()),
      BlocProvider<SalesBloc>(create: (_) => sl<SalesBloc>()),
      BlocProvider<QuickSaleBloc>(create: (_) => sl<QuickSaleBloc>()),
      BlocProvider<PurchasesBloc>(create: (_) => sl<PurchasesBloc>()),
      BlocProvider<DebtsBloc>(create: (_) => sl<DebtsBloc>()),
      BlocProvider<PaymentBloc>(create: (_) => sl<PaymentBloc>()),
      BlocProvider<ExpensesBloc>(create: (_) => sl<ExpensesBloc>()),
      BlocProvider<AccountingBloc>(create: (_) => sl<AccountingBloc>()),
      BlocProvider<StatisticsBloc>(create: (_) => sl<StatisticsBloc>()),
      BlocProvider<ReportsBloc>(create: (_) => sl<ReportsBloc>()),
      BlocProvider<SettingsBloc>(create: (_) => sl<SettingsBloc>()),
    ],
    child: BlocBuilder<AppSettingsBloc, AppSettingsState>(
      builder: (context, settingsState) => BlocBuilder<AppBloc, AppState>(
        builder: (context, appState) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'دفتر المقوت',

          // Theme configuration based on user settings
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settingsState.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,

          // Localization configuration
          locale: Locale(settingsState.languageCode),
          supportedLocales: const [
            Locale('ar', 'SA'), // العربية
            Locale('en', 'US'), // English
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate, // Custom localizations
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            // Default to Arabic if locale is not supported
            return supportedLocales.firstWhere(
              (supportedLocale) =>
                  supportedLocale.languageCode == locale?.languageCode,
              orElse: () => const Locale('ar', 'SA'),
            );
          },

          // Routing configuration
          onGenerateRoute: AppRouter.onGenerateRoute,
          initialRoute: RouteNames.splash,

          // Navigation observers for analytics and debugging
          navigatorObservers: [
            AppRouteObservers.routeObserver,
            AppRouteObservers.analyticsObserver,
            AppRouteObservers.loggingObserver,
          ],

          // App-wide configuration
          builder: (context, child) => GestureDetector(
            // Hide keyboard when tapping outside text fields
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: MediaQuery(
              // Disable text scaling for consistency
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            ),
          ),

          // Performance optimization
          restorationScopeId: 'daftar_almuqawit',
        ),
      ),
    ),
  );
}
