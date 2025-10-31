// ignore_for_file: public_member_api_docs

import 'package:sqflite/sqflite.dart';

class MigrationV1 {
  static Future<void> apply(Database db) async {
    // الإصدار الأول: عادة يُنشأ عبر onCreate في DatabaseHelper
    // لا حاجة لتغييرات هنا إذا كانت الجداول أُنشئت في onCreate.
  }
}
