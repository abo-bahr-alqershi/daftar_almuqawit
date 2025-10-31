// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';

/// مراقبو التنقل لتتبع فتح/إغلاق الصفحات
class AppRouteObservers {
  AppRouteObservers._();

  static final RouteObserver<PageRoute<dynamic>> routeObserver =
      RouteObserver<PageRoute<dynamic>>();
}
