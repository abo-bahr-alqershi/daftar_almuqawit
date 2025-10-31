// ignore_for_file: public_member_api_docs

import 'package:shared_preferences/shared_preferences.dart';

/// غلاف مبسّط لـ SharedPreferences
class SharedPreferencesService {
  Future<bool> setString(String key, String value) async {
    final sp = await SharedPreferences.getInstance();
    return sp.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(key);
  }
}
