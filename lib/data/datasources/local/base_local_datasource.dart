// ignore_for_file: public_member_api_docs

import 'package:sqflite/sqflite.dart';
import '../../database/database_helper.dart';

/// أساس لمصادر البيانات المحلية باستخدام SQLite
abstract class BaseLocalDataSource {
  final DatabaseHelper dbHelper;
  BaseLocalDataSource(this.dbHelper);

  Future<Database> get db async => dbHelper.database;
}
