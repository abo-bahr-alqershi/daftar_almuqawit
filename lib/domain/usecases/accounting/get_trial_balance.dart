// ignore_for_file: public_member_api_docs

import '../base/base_usecase.dart';

class GetTrialBalance implements UseCase<void, ({String from, String to})> {
  GetTrialBalance();
  @override
  Future<void> call(({String from, String to}) params) async {
    // Placeholder: ميزان المراجعة لاحقاً
  }
}
