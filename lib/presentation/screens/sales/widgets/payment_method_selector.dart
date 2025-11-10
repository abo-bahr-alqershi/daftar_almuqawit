import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// محدد طريقة الدفع
/// 
/// يعرض خيارات طرق الدفع المتاحة
class PaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
    this.enabled = true,
  });

  static const List<PaymentMethodOption> paymentMethods = [
    PaymentMethodOption(
      value: 'نقدي',
      label: 'نقدي',
      icon: Icons.money,
      color: AppColors.success,
    ),
    PaymentMethodOption(
      value: 'آجل',
      label: 'آجل',
      icon: Icons.schedule,
      color: AppColors.warning,
    ),
    PaymentMethodOption(
      value: 'شيك',
      label: 'شيك',
      icon: Icons.receipt,
      color: AppColors.info,
    ),
    PaymentMethodOption(
      value: 'تحويل بنكي',
      label: 'تحويل بنكي',
      icon: Icons.account_balance,
      color: AppColors.primary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'طريقة الدفع',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: paymentMethods.length,
          itemBuilder: (context, index) {
            final method = paymentMethods[index];
            final isSelected = selectedMethod == method.value;
            
            return InkWell(
              onTap: enabled ? () => onChanged(method.value) : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? method.color.withOpacity(0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? method.color : AppColors.border,
                    width: isSelected ? 2 : 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      method.icon,
                      color: isSelected ? method.color : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        method.label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected ? method.color : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// خيار طريقة الدفع
class PaymentMethodOption {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const PaymentMethodOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}
