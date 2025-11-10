import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/sales/sales_bloc.dart';
import '../../blocs/sales/sales_event.dart';
import '../../blocs/sales/sales_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;

/// شاشة مبيعات اليوم
class TodaySalesScreen extends StatelessWidget {
  const TodaySalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مبيعات اليوم'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<SalesBloc, SalesState>(
        builder: (context, state) {
          if (state is SalesLoading) {
            return const LoadingWidget();
          }

          if (state is SalesError) {
            return AppErrorWidget(
              title: 'حدث خطأ',
              message: state.message,
            );
          }

          if (state is SalesLoaded) {
            final sales = state.sales;
            
            return Column(
              children: [
                _buildSummaryCard(sales.length, sales.fold(0.0, (sum, s) => sum + s.totalAmount)),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return Card(
                        child: ListTile(
                          title: Text('${sale.quantity} كيس'),
                          subtitle: Text(sale.customerName ?? 'بيع مباشر'),
                          trailing: Text('${sale.totalAmount} ريال', style: const TextStyle(fontWeight: FontWeight.bold)),
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('لا توجد مبيعات اليوم'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(int count, double total) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('عدد العمليات', count.toString()),
          _buildStat('الإجمالي', '$total ريال'),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
