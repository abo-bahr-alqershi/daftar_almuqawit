import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// أزرار الدفع - تصميم راقي واحترافي
class PaymentButtons extends StatefulWidget {
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
  State<PaymentButtons> createState() => _PaymentButtonsState();
}

class _PaymentButtonsState extends State<PaymentButtons> {
  String? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTotalAmountCard(),
        const SizedBox(height: 20),
        _buildPaymentOption(
          title: 'دفع نقدي',
          subtitle: 'دفع كامل المبلغ نقداً',
          icon: Icons.payments_rounded,
          color: const Color(0xFF10B981),
          onTap: widget.onPayCash,
          method: 'cash',
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          title: 'دفع آجل',
          subtitle: 'تسجيل دين على العميل',
          icon: Icons.schedule_rounded,
          color: const Color(0xFFF59E0B),
          onTap: widget.onPayLater,
          method: 'later',
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          title: 'دفع جزئي',
          subtitle: 'دفع جزء من المبلغ',
          icon: Icons.pie_chart_rounded,
          color: const Color(0xFF3B82F6),
          onTap: widget.onPayPartial,
          method: 'partial',
        ),
      ],
    );
  }

  Widget _buildTotalAmountCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'المجموع الكلي',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.totalAmount.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ريال يمني',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String method,
  }) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: widget.isProcessing
          ? null
          : () {
              HapticFeedback.mediumImpact();
              setState(() => _selectedMethod = method);
              Future.delayed(const Duration(milliseconds: 150), onTap);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.3)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: widget.isProcessing && isSelected
                  ? Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Icon(
                      icon,
                      color: isSelected ? Colors.white : color,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? color : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
