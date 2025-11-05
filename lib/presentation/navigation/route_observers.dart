// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';

/// مراقبو التنقل لتتبع فتح/إغلاق الصفحات
/// 
/// يوفر مراقبين مختلفين للتطبيق:
/// - [routeObserver]: للمراقبة الأساسية للتنقل
/// - [analyticsObserver]: لتتبع التحليلات
/// - [loggingObserver]: لتسجيل التنقلات في وضع التطوير
class AppRouteObservers {
  AppRouteObservers._();

  /// المراقب الأساسي للتنقل
  static final RouteObserver<PageRoute<dynamic>> routeObserver =
      RouteObserver<PageRoute<dynamic>>();
      
  /// مراقب التحليلات (سيتم ربطه بـ Firebase Analytics)
  static final RouteObserver<PageRoute<dynamic>> analyticsObserver =
      AnalyticsRouteObserver();
      
  /// مراقب التسجيل للتطوير
  static final RouteObserver<PageRoute<dynamic>> loggingObserver =
      LoggingRouteObserver();
}

/// مراقب التحليلات المخصص
class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _logScreenView(route);
    }
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute) {
      _logScreenView(previousRoute);
    }
  }
  
  void _logScreenView(PageRoute<dynamic> route) {
    // TODO: إرسال تحليلات الشاشة إلى Firebase Analytics
    // FirebaseAnalytics.instance.logScreenView(
    //   screenName: route.settings.name,
    // );
  }
}

/// مراقب التسجيل للتطوير
class LoggingRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log('PUSH', route, previousRoute);
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _log('POP', route, previousRoute);
  }
  
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log('REPLACE', newRoute, oldRoute);
  }
  
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _log('REMOVE', route, previousRoute);
  }
  
  void _log(String action, Route<dynamic>? route, Route<dynamic>? previousRoute) {
    debugPrint('[NAV] $action: ${route?.settings.name} (from: ${previousRoute?.settings.name})');
  }
}
