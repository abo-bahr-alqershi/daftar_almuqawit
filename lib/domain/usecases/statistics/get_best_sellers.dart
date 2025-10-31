// ignore_for_file: public_member_api_docs

import '../../entities/sale.dart';
import '../../repositories/sales_repository.dart';
import '../base/base_usecase.dart';

typedef BestParams = ({String from, String to, int topN});

typedef BestSeller = ({int? qatTypeId, double totalQuantity, double totalAmount});

class GetBestSellers implements UseCase<List<BestSeller>, BestParams> {
  final SalesRepository sales;
  GetBestSellers(this.sales);
  @override
  Future<List<BestSeller>> call(BestParams params) async {
    final all = await sales.getAll();
    final filtered = all.where((s) => s.date.compareTo(params.from) >= 0 && s.date.compareTo(params.to) <= 0);
    final Map<int?, ({double qty, double amt})> agg = {};
    for (final Sale s in filtered) {
      final cur = agg[s.qatTypeId] ?? (qty: 0.0, amt: 0.0);
      agg[s.qatTypeId] = (qty: cur.qty + s.quantity, amt: cur.amt + s.totalAmount);
    }
    final list = agg.entries
        .map<BestSeller>((e) => (qatTypeId: e.key, totalQuantity: e.value.qty, totalAmount: e.value.amt))
        .toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    final n = params.topN;
    return list.take(n).toList();
  }
}
