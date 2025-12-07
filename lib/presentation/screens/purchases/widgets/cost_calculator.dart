import 'package:flutter/material.dart';

/// بطاقة حاسبة التكلفة والدفع - تصميم راقي ونظيف
class CostCalculator extends StatelessWidget {
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;

  const CostCalculator({
    super.key,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
  });

  @override
  Widget build(BuildContext context) {
    final paymentPercentage = totalAmount > 0
        ? (paidAmount / totalAmount)
        : 0.0;
    final progressColor = _getProgressColor(paymentPercentage * 100);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calculate_outlined,
                  size: 18,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ملخص التكلفة',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // إجمالي المشتريات
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                        size: 18,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'إجمالي المشتريات',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0, end: totalAmount),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(
                      '${value.toStringAsFixed(0)} ر.ي',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8B5CF6),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // المدفوع والمتبقي
          Row(
            children: [
              Expanded(
                child: _buildAmountCard(
                  icon: Icons.check_circle_outline,
                  label: 'المدفوع',
                  amount: paidAmount,
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAmountCard(
                  icon: Icons.pending_outlined,
                  label: 'المتبقي',
                  amount: remainingAmount,
                  color: remainingAmount > 0
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF16A34A),
                ),
              ),
            ],
          ),

          if (remainingAmount > 0) ...[
            const SizedBox(height: 16),
            _buildProgressBar(paymentPercentage, progressColor),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountCard({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0, end: amount),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                '${value.toStringAsFixed(0)} ر.ي',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'نسبة الدفع',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0, end: percentage),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return FractionallySizedBox(
                widthFactor: value.clamp(0.0, 1.0),
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return const Color(0xFF16A34A);
    if (percentage >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }
}
