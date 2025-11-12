import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// بطاقة حاسبة التكلفة والدفع - تصميم راقي متطور
class CostCalculator extends StatefulWidget {
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
  State<CostCalculator> createState() => _CostCalculatorState();
}

class _CostCalculatorState extends State<CostCalculator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    final paymentPercentage = widget.totalAmount > 0
        ? (widget.paidAmount / widget.totalAmount)
        : 0.0;

    _progressAnimation = Tween<double>(begin: 0, end: paymentPercentage).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.surface, AppColors.surface.withOpacity(0.98)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.purchases.withOpacity(0.2),
                          AppColors.purchases.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.calculate_rounded,
                      color: AppColors.purchases,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'ملخص الدفع',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.purchases.withOpacity(0.1),
                      AppColors.purchases.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.purchases.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    _buildAmountRow(
                      icon: Icons.shopping_cart_rounded,
                      label: 'إجمالي المشتريات',
                      amount: widget.totalAmount,
                      color: AppColors.purchases,
                      isLarge: true,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.border.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAmountRow(
                      icon: Icons.check_circle_rounded,
                      label: 'المبلغ المدفوع',
                      amount: widget.paidAmount,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 12),
                    _buildAmountRow(
                      icon: Icons.pending_rounded,
                      label: 'المبلغ المتبقي',
                      amount: widget.remainingAmount,
                      color: widget.remainingAmount > 0
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                  ],
                ),
              ),
              
              if (widget.remainingAmount > 0) ...[
                const SizedBox(height: 20),
                _buildProgressSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountRow({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
    bool isLarge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: isLarge ? 20 : 18, color: color),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: isLarge ? 15 : 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1200),
          tween: Tween(begin: 0, end: amount),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Text(
              '${value.toStringAsFixed(0)} ر.ي',
              style: TextStyle(
                fontSize: isLarge ? 22 : 18,
                color: color,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    final percentage = (widget.paidAmount / widget.totalAmount) * 100;
    final progressColor = _getProgressColor(percentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'نسبة الدفع',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(_progressAnimation.value * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: progressColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: progressColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                widthFactor: _progressAnimation.value,
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [progressColor, progressColor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 50) return AppColors.warning;
    return AppColors.danger;
  }
}

