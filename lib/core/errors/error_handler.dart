// ignore_for_file: public_member_api_docs

import 'exceptions.dart';
import 'failures.dart';

/// محول الاستثناءات إلى إخفاقات مقروءة
class ErrorHandler {
  static Failure toFailure(Object e) {
    if (e is DatabaseException) return DatabaseFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    return const UnknownFailure('حدث خطأ غير متوقع');
  }
}
