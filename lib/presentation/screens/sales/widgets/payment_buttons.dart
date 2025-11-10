import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// أزرار الدفع السريعة
/// 
/// توفر أزرار سريعة لإتمام عملية الدفع
class PaymentButtons extends StatelessWidget {
  final double totalAmount;
  final VoidCallback onPayCash;
  final VoidCallback onPayLater;
  final VoidCallback onPayPartial;
  final bool isProcessing;

  const PaymentButtons({
    super.key,
    required this.totalAmount,
    required this.onPayCash,
    required this.onPayLater,
    required this.onPayPartial,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // المجموع الكلي
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                'المجموع الكلي',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textOnDark.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${totalAmount.toStringAsFixed(2)} ريال',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.textOnDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // زر الدفع النقدي
        _buildPaymentButton(
          label: 'دفع نقدي',
          icon: Icons.money,
          color: AppColors.success,
          onPressed: isProcessing ? null : onPayCash,
        ),
        const SizedBox(height: 12),

        // زر الدفع الآجل
        _buildPaymentButton(
          label: 'دفع آجل',
          icon: Icons.schedule,
          color: AppColors.warning,
          onPressed: isProcessing ? null : onPayLater,
        ),
        const SizedBox(height: 12),

        // زر الدفع الجزئي
        _buildPaymentButton(
          label: 'دفع جزئي',
          icon: Icons.payment,
          color: AppColors.info,
          onPressed: isProcessing ? null : onPayPartial,
          isOutlined: true,
        ),
      ],
    );
  }

  Widget _buildPaymentButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    bool isOutlined = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(
        label,
        style: AppTextStyles.button.copyWith(
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.transparent : color,
        foregroundColor: isOutlined ? color : AppColors.textOnDark,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isOutlined 
              ? BorderSide(color: color, width: 2)
              : BorderSide.none,
        ),
        elevation: isOutlined ? 0 : 2,
      ),
    );
  }
}
