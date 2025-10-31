// ignore_for_file: public_member_api_docs

import 'package:sqflite/sqflite.dart';
import '../../../data/database/database_helper.dart';

class DatabaseService {
  final DatabaseHelper helper;
  DatabaseService(this.helper);

  Future<Database> get database => helper.database;
}
