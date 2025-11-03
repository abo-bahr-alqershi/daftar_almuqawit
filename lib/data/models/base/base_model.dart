// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';

/// النموذج الأساسي لجميع نماذج البيانات في التطبيق
/// 
/// الوظائف المطلوبة:
/// - خصائص أساسية (id, createdAt, updatedAt)
/// - دوال التحويل (toJson, fromJson, toMap, fromMap)
/// - دوال المساواة والـ hashing (باستخدام Equatable)
/// - التحقق من الصلاحية
/// - دعم المزامنة مع Firebase
abstract class BaseModel extends Equatable {
  /// المعرف الفريد
  final int? id;
  
  /// تاريخ الإنشاء
  final DateTime? createdAt;
  
  /// تاريخ آخر تحديث
  final DateTime? updatedAt;
  
  /// حالة المزامنة (pending, synced, failed)
  final String? syncStatus;
  
  /// معرف Firebase (للمزامنة السحابية)
  final String? firebaseId;

  const BaseModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.syncStatus = 'pending',
    this.firebaseId,
  });

  /// تحويل النموذج إلى Map لقاعدة البيانات المحلية
  Map<String, dynamic> toMap();

  /// تحويل النموذج إلى JSON للمزامنة مع Firebase
  Map<String, dynamic> toJson();

  /// نسخ النموذج مع تحديث بعض الحقول
  BaseModel copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    String? firebaseId,
  });

  /// التحقق من صحة البيانات
  /// يجب على كل نموذج تنفيذ هذه الدالة
  bool validate() => true;

  /// التحقق من أن النموذج جديد (غير محفوظ في قاعدة البيانات)
  bool get isNew => id == null || id! <= 0;

  /// التحقق من أن النموذج تم مزامنته
  bool get isSynced => syncStatus == 'synced';

  /// التحقق من أن النموذج في انتظار المزامنة
  bool get isPendingSync => syncStatus == 'pending';

  /// التحقق من فشل المزامنة
  bool get isSyncFailed => syncStatus == 'failed';

  /// الحصول على التاريخ الحالي بصيغة ISO
  static String getCurrentTimestamp() => DateTime.now().toIso8601String();

  /// تحويل النص إلى DateTime
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// تحويل DateTime إلى نص
  static String? dateTimeToString(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }

  /// دوال Equatable للمقارنة
  @override
  List<Object?> get props => [id, createdAt, updatedAt, syncStatus, firebaseId];

  @override
  bool get stringify => true;
}

/// نموذج أساسي للكيانات التي يمكن حذفها بشكل ناعم (Soft Delete)
abstract class SoftDeletableModel extends BaseModel {
  /// هل تم حذف السجل؟
  final bool isDeleted;
  
  /// تاريخ الحذف
  final DateTime? deletedAt;

  const SoftDeletableModel({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.syncStatus,
    super.firebaseId,
    this.isDeleted = false,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [...super.props, isDeleted, deletedAt];
}

/// نموذج أساسي للكيانات التي لها حالة (نشط، ملغي، مكتمل، إلخ)
abstract class StatefulModel extends BaseModel {
  /// حالة السجل
  final String status;

  const StatefulModel({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.syncStatus,
    super.firebaseId,
    this.status = 'نشط',
  });

  /// التحقق من أن السجل نشط
  bool get isActive => status == 'نشط';

  /// التحقق من أن السجل ملغي
  bool get isCancelled => status == 'ملغي';

  @override
  List<Object?> get props => [...super.props, status];
}

/// استثناء التحقق من صحة البيانات
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;

  ValidationException(this.message, {this.errors});

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return 'ValidationException: $message\nErrors: $errors';
    }
    return 'ValidationException: $message';
  }
}
