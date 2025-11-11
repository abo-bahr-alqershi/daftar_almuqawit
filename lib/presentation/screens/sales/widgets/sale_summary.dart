import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';

/// ويدجت ملخص المبيعات - تصميم متطور
class SaleSummary extends StatefulWidget {
  final double totalAmount;
  final double totalProfit;
  final double totalPaid;
  final double totalRemaining;
  final int salesCount;

  const SaleSummary({
    super.key,
    required this.totalAmount,
    required this.totalProfit,
    required this.totalPaid,
    required this.totalRemaining,
    required this.salesCount,
  });

  @override
  State<SaleSummary> createState() => _SaleSummaryState();
}

class _SaleSummaryState extends State<SaleSummary>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _numberAnimationController;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _numberAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _cardAnimations = List.generate(
      5,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardAnimationController,
          curve: Interval(
            index * 0.15,
            0.5 + (index * 0.1),
            curve: Curves.easeOutBack,
          ),
        ),
      ),
    );

    _cardAnimationController.forward();
    _numberAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _numberAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Main Summary Card
          AnimatedBuilder(
            animation: _cardAnimations[0],
            builder: (context, child) {
              return Transform.scale(
                scale: _cardAnimations[0].value,
                child: Opacity(
                  opacity: _cardAnimations[0].value,
                  child: _buildMainSummaryCard(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Metrics Grid
          _buildMetricsGrid(),

          // Warning Card if there's remaining amount
          if (widget.totalRemaining > 0) ...[
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _cardAnimations[4],
              builder: (context, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(_cardAnimations[4]),
                  child: FadeTransition(
                    opacity: _cardAnimations[4],
                    child: _buildRemainingCard(),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.9),
            AppColors.accent.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Content
          Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.analytics_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ملخص المبيعات',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedBuilder(
                          animation: _numberAnimationController,
                          builder: (context, child) {
                            return Text(
                              '${(widget.salesCount * _numberAnimationController.value).toInt()} عملية',
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      icon: Icons.attach_money_rounded,
                      label: 'الإجمالي',
                      value: widget.totalAmount,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    _buildSummaryItem(
                      icon: Icons.trending_up_rounded,
                      label: 'الربح',
                      value: widget.totalProfit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required double value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: _numberAnimationController,
          builder: (context, child) {
            return Text(
              Formatters.currency(value * _numberAnimationController.value),
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return Row(
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: _cardAnimations[1],
            builder: (context, child) {
              return Transform.scale(
                scale: _cardAnimations[1].value,
                child: Opacity(
                  opacity: _cardAnimations[1].value,
                  child: _MetricTile(
                    icon: Icons.check_circle_rounded,
                    label: 'المدفوع',
                    value: widget.totalPaid,
                    color: AppColors.success,
                    delay: 0,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnimatedBuilder(
            animation: _cardAnimations[2],
            builder: (context, child) {
              return Transform.scale(
                scale: _cardAnimations[2].value,
                child: Opacity(
                  opacity: _cardAnimations[2].value,
                  child: _MetricTile(
                    icon: Icons.pending_rounded,
                    label: 'المعلق',
                    value: widget.totalRemaining,
                    color: AppColors.warning,
                    delay: 100,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRemainingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withOpacity(0.15),
            AppColors.warning.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'يوجد مبالغ غير مدفوعة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.currency(widget.totalRemaining),
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.warning,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;
  final int delay;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });

  @override
  State<_MetricTile> createState() => _MetricTileState();
}

class _MetricTileState extends State<_MetricTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.color.withOpacity(
                0.2 + (_glowAnimation.value * 0.2),
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.1 * _glowAnimation.value),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.color.withOpacity(0.15),
                      widget.color.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                Formatters.currency(widget.value),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: widget.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
