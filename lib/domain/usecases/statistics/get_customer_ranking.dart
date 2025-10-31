// ignore_for_file: public_member_api_docs

import '../../entities/sale.dart';
import '../../repositories/sales_repository.dart';
import '../base/base_usecase.dart';

typedef RankParams = ({String from, String to, int topN});

typedef CustomerRank = ({int? customerId, double totalAmount});

class GetCustomerRanking implements UseCase<List<CustomerRank>, RankParams> {
  final SalesRepository sales;
  GetCustomerRanking(this.sales);
  @override
  Future<List<CustomerRank>> call(RankParams params) async {
    final all = await sales.getAll();
    final filtered = all.where((s) => s.date.compareTo(params.from) >= 0 && s.date.compareTo(params.to) <= 0);
    final Map<int?, double> agg = {};
    for (final Sale s in filtered) {
      agg[s.customerId] = (agg[s.customerId] ?? 0) + s.totalAmount;
    }
    final list = agg.entries
        .map<CustomerRank>((e) => (customerId: e.key, totalAmount: e.value))
        .toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return list.take(params.topN).toList();
  }
}
