// ignore_for_file: public_member_api_docs

import 'package:sqflite/sqflite.dart';

import 'migration_v1.dart';
import 'migration_v2.dart';
import 'migration_v3.dart';

class MigrationManager {
  static Future<void> upgrade(Database db, int oldVersion, int newVersion) async {
    for (int v = oldVersion + 1; v <= newVersion; v++) {
      if (v == 1) {
        await MigrationV1.apply(db);
      } else if (v == 2) {
        await MigrationV2.apply(db);
      } else if (v == 3) {
        await MigrationV3.apply(db);
      }
    }
  }
}
