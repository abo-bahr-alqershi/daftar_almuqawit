// ignore_for_file: public_member_api_docs

import 'package:intl/intl.dart';
import '../../entities/daily_statistics.dart';
import '../../repositories/statistics_repository.dart';
import '../base/base_usecase.dart';

typedef ProfitRange = ({String from, String to});

class GetProfitAnalysis implements UseCase<({double gross, double net}), ProfitRange> {
  final StatisticsRepository repo;
  GetProfitAnalysis(this.repo);
  @override
  Future<({double gross, double net})> call(ProfitRange params) async {
    final df = DateFormat('yyyy-MM-dd');
    final from = df.parse(params.from);
    final to = df.parse(params.to);
    double gross = 0, net = 0;
    for (DateTime d = from; !d.isAfter(to); d = d.add(const Duration(days: 1))) {
      final s = await repo.getDaily(df.format(d));
      gross += s.grossProfit;
      net += s.netProfit;
    }
    return (gross: gross, net: net);
  }
}
