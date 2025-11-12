import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// محدد طريقة الدفع - تصميم راقي هادئ
class PaymentMethodSelector extends StatefulWidget {
  final String selectedMethod;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  static final List<PaymentMethodOption> paymentMethods = [
    PaymentMethodOption(
      value: 'نقدي',
      label: 'نقدي',
      icon: Icons.payments_rounded,
      color: AppColors.success,
      description: 'دفع فوري',
    ),
    PaymentMethodOption(
      value: 'آجل',
      label: 'آجل',
      icon: Icons.schedule_rounded,
      color: AppColors.warning,
      description: 'دفع مؤجل',
    ),
    PaymentMethodOption(
      value: 'حوالة',
      label: 'حوالة',
      icon: Icons.swap_horiz_rounded,
      color: AppColors.info,
      description: 'حوالة بنكية',
    ),
    PaymentMethodOption(
      value: 'محفظة',
      label: 'محفظة',
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.primary,
      description: 'محفظة إلكترونية',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.primary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.payment_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'طريقة الدفع',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: paymentMethods.length,
          itemBuilder: (context, index) {
            final method = paymentMethods[index];
            final isSelected = widget.selectedMethod == method.value;

            return GestureDetector(
              onTap: widget.enabled
                  ? () {
                      HapticFeedback.selectionClick();
                      widget.onChanged(method.value);
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            method.color.withOpacity(0.15),
                            method.color.withOpacity(0.08),
                          ],
                        )
                      : null,
                  color: isSelected ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? method.color.withOpacity(0.4)
                        : AppColors.border.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isSelected ? 0.05 : 0.02),
                      blurRadius: isSelected ? 10 : 6,
                      offset: Offset(0, isSelected ? 3 : 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [method.color, method.color.withOpacity(0.8)],
                              )
                            : null,
                        color: isSelected ? null : method.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        method.icon,
                        color: isSelected ? Colors.white : method.color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      method.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? method.color : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      method.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildSelectedMethodInfo(),
      ],
    );
  }

  Widget _buildSelectedMethodInfo() {
    final selectedMethodOption = paymentMethods.firstWhere(
      (m) => m.value == widget.selectedMethod,
      orElse: () => paymentMethods.first,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            selectedMethodOption.color.withOpacity(0.08),
            selectedMethodOption.color.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selectedMethodOption.color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selectedMethodOption.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              selectedMethodOption.icon,
              color: selectedMethodOption.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الطريقة المختارة',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  selectedMethodOption.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: selectedMethodOption.color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// خيار طريقة الدفع
class PaymentMethodOption {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final String description;

  const PaymentMethodOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.description,
  });
}
