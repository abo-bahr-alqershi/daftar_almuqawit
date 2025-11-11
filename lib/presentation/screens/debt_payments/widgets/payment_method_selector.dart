import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// ويدجت اختيار طريقة الدفع
/// يعرض خيارات طرق الدفع المختلفة (نقد، تحويل، حوالة)
class PaymentMethodSelector extends StatelessWidget {
  /// طريقة الدفع المختارة حالياً
  final String selectedMethod;
  
  /// دالة استدعاء عند تغيير طريقة الدفع
  final ValueChanged<String> onMethodChanged;
  
  /// قائمة طرق الدفع المتاحة
  final List<PaymentMethodOption> methods;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
    List<PaymentMethodOption>? methods,
  }) : methods = methods ?? _defaultMethods;

  /// طرق الدفع الافتراضية
  static const List<PaymentMethodOption> _defaultMethods = [
    PaymentMethodOption(
      value: 'نقد',
      label: 'نقد',
      icon: Icons.money,
      color: AppColors.success,
    ),
    PaymentMethodOption(
      value: 'تحويل',
      label: 'محفظة',
      icon: Icons.account_balance,
      color: AppColors.info,
    ),
    PaymentMethodOption(
      value: 'حوالة',
      label: 'حوالة',
      icon: Icons.receipt_long,
      color: AppColors.warning,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة الدفع',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // عرض الخيارات في صف
        Row(
          children: methods.map((method) {
            final isSelected = selectedMethod == method.value;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _PaymentMethodCard(
                  method: method,
                  isSelected: isSelected,
                  onTap: () => onMethodChanged(method.value),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// كارت خيار طريقة الدفع
class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethodOption method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? method.color.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? method.color
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الأيقونة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? method.color.withOpacity(0.2)
                    : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                method.icon,
                color: isSelected
                    ? method.color
                    : AppColors.textSecondary,
                size: 28,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // النص
            Text(
              method.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected
                    ? method.color
                    : AppColors.textSecondary,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            
            // علامة الاختيار
            if (isSelected) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.check_circle,
                color: method.color,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// نموذج بيانات خيار طريقة الدفع
class PaymentMethodOption {
  /// القيمة المخزنة
  final String value;
  
  /// النص المعروض
  final String label;
  
  /// الأيقونة
  final IconData icon;
  
  /// اللون المميز
  final Color color;

  const PaymentMethodOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}
