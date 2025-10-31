// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// محليّات مبسطة لتحميل ملفات JSON
class AppLocalizationsLoader {
  static Future<Map<String, dynamic>> load(String locale) async {
    final data = await rootBundle.loadString('assets/translations/'
        '${locale.substring(0,2)}.json');
    return json.decode(data) as Map<String, dynamic>;
  }
}
