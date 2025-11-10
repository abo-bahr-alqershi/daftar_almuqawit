import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/sale.dart';

/// شاشة تفاصيل عملية البيع
class SaleDetailsScreen extends StatelessWidget {
  final Sale sale;

  const SaleDetailsScreen({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل البيع'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
          IconButton(icon: const Icon(Icons.print), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard('رقم العملية', sale.id),
          _buildInfoCard('التاريخ', sale.date.toString().split(' ')[0]),
          _buildInfoCard('الكمية', '${sale.quantity} كيس'),
          _buildInfoCard('السعر', '${sale.price} ريال'),
          _buildInfoCard('المجموع', '${sale.totalAmount} ريال'),
          if (sale.customerName != null)
            _buildInfoCard('العميل', sale.customerName!),
          _buildInfoCard('طريقة الدفع', sale.paymentMethod),
          if (sale.notes?.isNotEmpty == true)
            _buildInfoCard('ملاحظات', sale.notes!),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
