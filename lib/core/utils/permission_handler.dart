// ignore_for_file: public_member_api_docs

import 'package:permission_handler/permission_handler.dart' as ph;

/// غلاف مبسط لإدارة الصلاحيات
class AppPermissionHandler {
  AppPermissionHandler._();

  static Future<bool> requestStorage() async {
    final s = await ph.Permission.storage.request();
    return s.isGranted;
  }
}
