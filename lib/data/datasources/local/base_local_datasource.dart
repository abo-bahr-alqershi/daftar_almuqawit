// ignore_for_file: public_member_api_docs

import 'package:sqflite/sqflite.dart';
import '../../database/database_helper.dart';
import '../../models/base/base_model.dart';

/// أساس لمصادر البيانات المحلية باستخدام SQLite
/// 
/// الوظائف المطلوبة:
/// - عمليات CRUD الأساسية (Create, Read, Update, Delete)
/// - البحث والفلترة
/// - عمليات Batch للأداء العالي
/// - معالجة الأخطاء
/// - دعم المزامنة
abstract class BaseLocalDataSource<T extends BaseModel> {
  final DatabaseHelper dbHelper;
  
  BaseLocalDataSource(this.dbHelper);

  /// الحصول على قاعدة البيانات
  Future<Database> get db async => dbHelper.database;

  /// اسم الجدول - يجب تنفيذه في كل مصدر بيانات
  String get tableName;

  /// تحويل Map إلى Model - يجب تنفيذه في كل مصدر بيانات
  T fromMap(Map<String, dynamic> map);

  // ==================== عمليات CRUD الأساسية ====================

  /// إدراج سجل جديد
  /// يرجع ID السجل المدرج
  Future<int> insert(T model) async {
    try {
      final database = await db;
      return await database.insert(
        tableName,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('خطأ في إدراج البيانات: $e');
    }
  }

  /// إدراج عدة سجلات دفعة واحدة (Batch Insert)
  Future<List<int>> insertBatch(List<T> models) async {
    try {
      final database = await db;
      final batch = database.batch();
      
      for (final model in models) {
        batch.insert(
          tableName,
          model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      final results = await batch.commit(noResult: false);
      return results.cast<int>();
    } catch (e) {
      throw Exception('خطأ في إدراج البيانات المتعددة: $e');
    }
  }

  /// تحديث سجل موجود
  Future<int> update(T model) async {
    try {
      final database = await db;
      return await database.update(
        tableName,
        model.toMap(),
        where: 'id = ?',
        whereArgs: [model.id],
      );
    } catch (e) {
      throw Exception('خطأ في تحديث البيانات: $e');
    }
  }

  /// تحديث عدة سجلات دفعة واحدة
  Future<void> updateBatch(List<T> models) async {
    try {
      final database = await db;
      final batch = database.batch();
      
      for (final model in models) {
        batch.update(
          tableName,
          model.toMap(),
          where: 'id = ?',
          whereArgs: [model.id],
        );
      }
      
      await batch.commit(noResult: true);
    } catch (e) {
      throw Exception('خطأ في تحديث البيانات المتعددة: $e');
    }
  }

  /// حذف سجل بواسطة ID
  Future<int> delete(int id) async {
    try {
      final database = await db;
      return await database.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('خطأ في حذف البيانات: $e');
    }
  }

  /// حذف عدة سجلات بواسطة IDs
  Future<int> deleteBatch(List<int> ids) async {
    try {
      final database = await db;
      final placeholders = List.filled(ids.length, '?').join(',');
      return await database.delete(
        tableName,
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
    } catch (e) {
      throw Exception('خطأ في حذف البيانات المتعددة: $e');
    }
  }

  /// حذف جميع السجلات
  Future<int> deleteAll() async {
    try {
      final database = await db;
      return await database.delete(tableName);
    } catch (e) {
      throw Exception('خطأ في حذف جميع البيانات: $e');
    }
  }

  // ==================== عمليات القراءة ====================

  /// جلب سجل بواسطة ID
  Future<T?> getById(int id) async {
    try {
      final database = await db;
      final rows = await database.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (rows.isEmpty) return null;
      return fromMap(rows.first);
    } catch (e) {
      throw Exception('خطأ في جلب البيانات: $e');
    }
  }

  /// جلب جميع السجلات
  Future<List<T>> getAll({
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final database = await db;
      final rows = await database.query(
        tableName,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      
      return rows.map((row) => fromMap(row)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب جميع البيانات: $e');
    }
  }

  /// جلب سجلات بشرط معين
  Future<List<T>> getWhere({
    required String where,
    required List<dynamic> whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final database = await db;
      final rows = await database.query(
        tableName,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      
      return rows.map((row) => fromMap(row)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب البيانات بشرط: $e');
    }
  }

  /// عد السجلات
  Future<int> count({String? where, List<dynamic>? whereArgs}) async {
    try {
      final database = await db;
      final result = await database.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName${where != null ? ' WHERE $where' : ''}',
        whereArgs,
      );
      
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('خطأ في عد السجلات: $e');
    }
  }

  /// التحقق من وجود سجل
  Future<bool> exists(int id) async {
    try {
      final count = await this.count(where: 'id = ?', whereArgs: [id]);
      return count > 0;
    } catch (e) {
      throw Exception('خطأ في التحقق من وجود السجل: $e');
    }
  }

  // ==================== عمليات المزامنة ====================

  /// جلب السجلات المعلقة للمزامنة
  Future<List<T>> getPendingSync({int? limit}) async {
    try {
      return await getWhere(
        where: 'sync_status = ?',
        whereArgs: ['pending'],
        limit: limit,
      );
    } catch (e) {
      throw Exception('خطأ في جلب السجلات المعلقة: $e');
    }
  }

  /// تحديث حالة المزامنة
  Future<int> updateSyncStatus(int id, String status) async {
    try {
      final database = await db;
      return await database.update(
        tableName,
        {'sync_status': status, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('خطأ في تحديث حالة المزامنة: $e');
    }
  }

  /// تحديث Firebase ID
  Future<int> updateFirebaseId(int id, String firebaseId) async {
    try {
      final database = await db;
      return await database.update(
        tableName,
        {'firebase_id': firebaseId, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('خطأ في تحديث Firebase ID: $e');
    }
  }

  // ==================== عمليات البحث ====================

  /// بحث في حقل معين
  Future<List<T>> search({
    required String column,
    required String query,
    String? orderBy,
    int? limit,
  }) async {
    try {
      return await getWhere(
        where: '$column LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: orderBy,
        limit: limit,
      );
    } catch (e) {
      throw Exception('خطأ في البحث: $e');
    }
  }

  // ==================== عمليات متقدمة ====================

  /// تنفيذ استعلام SQL مخصص
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    try {
      final database = await db;
      return await database.rawQuery(sql, arguments);
    } catch (e) {
      throw Exception('خطأ في تنفيذ الاستعلام: $e');
    }
  }

  /// تنفيذ أمر SQL مخصص
  Future<int> rawUpdate(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    try {
      final database = await db;
      return await database.rawUpdate(sql, arguments);
    } catch (e) {
      throw Exception('خطأ في تنفيذ الأمر: $e');
    }
  }
}
