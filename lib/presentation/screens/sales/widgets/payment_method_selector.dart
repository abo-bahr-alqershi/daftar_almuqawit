import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// محدد طريقة الدفع - تصميم راقي واحترافي
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
      value: 'نقد',
      label: 'نقد',
      icon: Icons.payments_rounded,
      color: const Color(0xFF10B981),
      description: 'دفع نقدي',
    ),
    PaymentMethodOption(
      value: 'محفظة',
      label: 'محفظة',
      icon: Icons.account_balance_wallet_rounded,
      color: const Color(0xFF3B82F6),
      description: 'محفظة إلكترونية',
    ),
    PaymentMethodOption(
      value: 'حوالة',
      label: 'حوالة',
      icon: Icons.swap_horiz_rounded,
      color: const Color(0xFFF59E0B),
      description: 'حوالة بنكية',
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
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.payment_rounded,
                color: Color(0xFF6366F1),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'طريقة الدفع',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: paymentMethods.map((method) {
            final isSelected = widget.selectedMethod == method.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: method == paymentMethods.last ? 0 : 10,
                ),
                child: GestureDetector(
                  onTap: widget.enabled
                      ? () {
                          HapticFeedback.selectionClick();
                          widget.onChanged(method.value);
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? method.color.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? method.color.withOpacity(0.3)
                            : const Color(0xFFE5E7EB),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? method.color
                                : method.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            method.icon,
                            color: isSelected ? Colors.white : method.color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          method.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? method.color
                                : const Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          method.description,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9CA3AF),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        _buildSelectedInfo(),
      ],
    );
  }

  Widget _buildSelectedInfo() {
    final selectedMethodOption = paymentMethods.firstWhere(
      (m) => m.value == widget.selectedMethod,
      orElse: () => paymentMethods.first,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selectedMethodOption.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selectedMethodOption.color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: selectedMethodOption.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              selectedMethodOption.icon,
              color: selectedMethodOption.color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الطريقة المختارة',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(height: 2),
                Text(
                  selectedMethodOption.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selectedMethodOption.color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF10B981),
              size: 14,
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
