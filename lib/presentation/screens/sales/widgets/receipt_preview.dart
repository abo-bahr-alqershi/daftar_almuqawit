import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/sale.dart';

/// معاينة الفاتورة
class ReceiptPreview extends StatelessWidget {
  final Sale sale;
  final String? storeName;
  final String? storeAddress;
  final String? storePhone;

  const ReceiptPreview({
    super.key,
    required this.sale,
    this.storeName,
    this.storeAddress,
    this.storePhone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(storeName ?? 'دفتر المقاويت', style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
          if (storeAddress != null) Text(storeAddress!, style: AppTextStyles.bodySmall),
          if (storePhone != null) Text(storePhone!, style: AppTextStyles.bodySmall),
          const Divider(height: 24),
          _buildRow('رقم الفاتورة:', '#${sale.id?.toString().padLeft(8, '0') ?? 'N/A'}'),
          _buildRow('التاريخ:', sale.date),
          if (sale.customerName != null) _buildRow('العميل:', sale.customerName!),
          const Divider(height: 24),
          _buildRow('الكمية:', '${sale.quantity} كيس'),
          _buildRow('السعر:', '${sale.price} ريال'),
          const Divider(height: 24),
          _buildRow('المجموع:', '${sale.totalAmount} ريال', isBold: true),
          _buildRow('طريقة الدفع:', sale.paymentMethod),
          const SizedBox(height: 16),
          Text('شكراً لتعاملكم معنا', style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
