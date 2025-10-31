// ignore_for_file: public_member_api_docs

import '../base/base_usecase.dart';

class CloseDailyAccounts implements UseCase<void, String> {
  CloseDailyAccounts();
  @override
  Future<void> call(String date) async {
    // Placeholder: إقفال يومي لاحقاً
  }
}
