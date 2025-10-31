// ignore_for_file: public_member_api_docs

/// استثناءات مخصّصة للطبقة البيانات/الشبكة
class AppException implements Exception {
  final String message;
  final Object? cause;
  AppException(this.message, {this.cause});
  @override
  String toString() => 'AppException: $message';
}

class DatabaseException extends AppException {
  DatabaseException(super.message, {super.cause});
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.cause});
}
