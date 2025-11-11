// ignore_for_file: public_member_api_docs

import 'package:sqflite/sqflite.dart';

class MigrationV4 {
  static Future<void> apply(Database db) async {
    await db.execute('''
      ALTER TABLE qat_types ADD COLUMN available_units TEXT;
    ''');
    
    await db.execute('''
      ALTER TABLE qat_types ADD COLUMN unit_prices TEXT;
    ''');
  }
}
