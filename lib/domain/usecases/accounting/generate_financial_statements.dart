// ignore_for_file: public_member_api_docs

import '../base/base_usecase.dart';

class GenerateFinancialStatements implements UseCase<void, ({String from, String to})> {
  GenerateFinancialStatements();
  @override
  Future<void> call(({String from, String to}) params) async {
    // Placeholder: إنشاء القوائم المالية لاحقاً
  }
}
