// ignore_for_file: public_member_api_docs

/// واجهة عامة لحالات الاستخدام (UseCase)
abstract class UseCase<T, P> {
  Future<T> call(P params);
}

class NoParams {
  const NoParams();
}
