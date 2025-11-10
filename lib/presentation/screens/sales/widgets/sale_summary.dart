import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// ملخص عملية البيع
/// 
/// يعرض ملخص تفاصيل عملية البيع قبل التأكيد
class SaleSummary extends StatelessWidget {
  final String? qatTypeName;
  final double quantity;
  final double pricePerUnit;
  final double? discount;
  final String paymentMethod;
  final String? customerName;
  final double totalAmount;

  const SaleSummary({
    super.key,
    this.qatTypeName,
    required this.quantity,
    required this.pricePerUnit,
    this.discount,
    required this.paymentMethod,
    this.customerName,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = quantity * pricePerUnit;
    final discountAmount = discount ?? 0;
    final finalTotal = subtotal - discountAmount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'ملخص العملية',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // التفاصيل
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (customerName != null)
                  _buildRow('العميل', customerName!, Icons.person),
                if (qatTypeName != null)
                  _buildRow('نوع القات', qatTypeName!, Icons.grass),
                _buildRow('الكمية', '$quantity كيس', Icons.inventory),
                _buildRow('السعر', '${pricePerUnit.toStringAsFixed(2)} ريال', Icons.attach_money),
                
                const Divider(height: 24),
                
                _buildRow('المجموع الفرعي', '${subtotal.toStringAsFixed(2)} ريال', null, isBold: false),
                
                if (discountAmount > 0) ...[
                  _buildRow('الخصم', '- ${discountAmount.toStringAsFixed(2)} ريال', Icons.local_offer, valueColor: AppColors.success),
                  const Divider(height: 24),
                ],
                
                _buildRow('المجموع الكلي', '${finalTotal.toStringAsFixed(2)} ريال', null, isBold: true, isTotal: true),
                
                const Divider(height: 24),
                
                _buildRow('طريقة الدفع', paymentMethod, Icons.payment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value,
    IconData? icon, {
    bool isBold = false,
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: isTotal
                ? AppTextStyles.headlineMedium.copyWith(
                    color: valueColor ?? AppColors.primary,
                    fontWeight: FontWeight.bold,
                  )
                : AppTextStyles.bodyMedium.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                    fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                  ),
          ),
        ],
      ),
    );
  }
}
