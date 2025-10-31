// ignore_for_file: public_member_api_docs

/// واجهة مستودع عامة (CRUD) لكيانات الدومين
abstract class BaseRepository<T> {
  Future<int> add(T entity); // إرجاع المعرّف الجديد
  Future<void> update(T entity);
  Future<void> delete(int id);
  Future<T?> getById(int id);
  Future<List<T>> getAll();
}
