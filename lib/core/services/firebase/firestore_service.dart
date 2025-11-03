import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;

import '../../errors/exceptions.dart' as app_exceptions;

/// خدمة Firestore للتعامل مع قاعدة البيانات السحابية
/// 
/// يوفر عمليات CRUD والاستعلامات والمعاملات
class FirestoreService {
  FirestoreService._();
  
  static final FirestoreService _instance = FirestoreService._();
  static FirestoreService get instance => _instance;

  /// الحصول على مثيل Firestore
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // ========== عمليات المجموعات ==========

  /// الحصول على مرجع مجموعة
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return firestore.collection(path);
  }

  /// الحصول على مرجع مستند
  DocumentReference<Map<String, dynamic>> document(String path) {
    return firestore.doc(path);
  }

  // ========== عمليات القراءة ==========

  /// جلب مستند واحد
  Future<Map<String, dynamic>?> getDocument(String path) async {
    try {
      final doc = await document(path).get();
      if (!doc.exists) {
        return null;
      }
      return doc.data();
    } on firebase_core.FirebaseException catch (e) {
      throw app_exceptions.FirestoreException(e.message ?? 'فشل جلب المستند', code: e.code);
    } catch (e) {
      throw app_exceptions.FirestoreException('فشل جلب المستند: $e');
    }
  }

  /// جلب مجموعة مستندات
  Future<List<Map<String, dynamic>>> getCollection(
    String path, {
    Query<Map<String, dynamic>>? Function(CollectionReference<Map<String, dynamic>>)? queryBuilder,
  }) async {
    try {
      var query = collection(path) as Query<Map<String, dynamic>>;
      
      if (queryBuilder != null) {
        final builtQuery = queryBuilder(collection(path));
        if (builtQuery != null) {
          query = builtQuery;
        }
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } on firebase_core.FirebaseException catch (e) {
      throw app_exceptions.FirestoreException(e.message ?? 'فشل جلب المجموعة', code: e.code);
    } catch (e) {
      throw app_exceptions.FirestoreException('فشل جلب المجموعة: $e');
    }
  }

  // ========== عمليات الكتابة ==========

  /// إضافة مستند جديد
  Future<String> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = await collection(collectionPath).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } on firebase_core.FirebaseException catch (e) {
      throw app_exceptions.FirestoreException(e.message ?? 'فشل إضافة المستند', code: e.code);
    } catch (e) {
      throw app_exceptions.FirestoreException('فشل إضافة المستند: $e');
    }
  }

  /// تعيين مستند بمعرف محدد
  Future<void> setDocument(
    String path,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      await document(path).set(
        {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: merge),
      );
    } on firebase_core.FirebaseException catch (e) {
      throw app_exceptions.FirestoreException(e.message ?? 'فشل حفظ المستند', code: e.code);
    } catch (e) {
      throw app_exceptions.FirestoreException('فشل حفظ المستند: $e');
    }
  }

  /// تحديث مستند
  Future<void> updateDocument(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      await document(path).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on firebase_core.FirebaseException catch (e) {
      throw app_exceptions.FirestoreException(e.message ?? 'فشل تحديث المستند', code: e.code);
    } catch (e) {
      throw app_exceptions.FirestoreException('فشل تحديث المستند: $e');
    }
  }

  /// حذف مستند
  Future<void> deleteDocument(String path) async {
    try {
      await document(path).delete();
    } on firebase_core.FirebaseException catch (e) {
      throw app_exceptions.FirestoreException(e.message ?? 'فشل حذف المستند', code: e.code);
    } catch (e) {
      throw app_exceptions.FirestoreException('فشل حذف المستند: $e');
    }
  }

  // ========== عمليات الدفعات ==========

  /// تنفيذ دفعة من العمليات
  Future<void> batch(Function(WriteBatch) operations) async {
    try {
      final batch = firestore.batch();
      operations(batch);
      await batch.commit();
    } on firebase_core.FirebaseException catch (e) {
      throw app_exceptions.FirestoreException(e.message ?? 'فشل تنفيذ الدفعة', code: e.code);
    } catch (e) {
      throw app_exceptions.FirestoreException('فشل تنفيذ الدفعة: $e');
    }
  }

  /// تنفيذ معاملة
  Future<T> transaction<T>(Future<T> Function(Transaction) operations) async {
    try {
      return await firestore.runTransaction(operations);
    } on firebase_core.FirebaseException catch (e) {
      throw app_exceptions.FirestoreException(e.message ?? 'فشل تنفيذ المعاملة', code: e.code);
    } catch (e) {
      throw app_exceptions.FirestoreException('فشل تنفيذ المعاملة: $e');
    }
  }

  // ========== الاستماع للتغييرات ==========

  /// الاستماع لتغييرات مستند
  Stream<Map<String, dynamic>?> watchDocument(String path) {
    return document(path).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return snapshot.data();
    });
  }

  /// الاستماع لتغييرات مجموعة
  Stream<List<Map<String, dynamic>>> watchCollection(
    String path, {
    Query<Map<String, dynamic>>? Function(CollectionReference<Map<String, dynamic>>)? queryBuilder,
  }) {
    var query = collection(path) as Query<Map<String, dynamic>>;
    
    if (queryBuilder != null) {
      final builtQuery = queryBuilder(collection(path));
      if (builtQuery != null) {
        query = builtQuery;
      }
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList(),
    );
  }
}
