// ignore_for_file: public_member_api_docs

/// إخفاقات يتم تمريرها لطبقة الدومين/الواجهة
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
