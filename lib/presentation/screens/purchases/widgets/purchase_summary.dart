import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// بطاقة ملخص المشتريات - تصميم راقي متطور
class PurchaseSummary extends StatefulWidget {
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final int purchaseCount;
  final VoidCallback? onTap;

  const PurchaseSummary({
    super.key,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.purchaseCount,
    this.onTap,
  });

  @override
  State<PurchaseSummary> createState() => _PurchaseSummaryState();
}

class _PurchaseSummaryState extends State<PurchaseSummary>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _numberController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _numberController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeIn),
    );

    _mainController.forward();
    _numberController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              if (widget.onTap != null) {
                HapticFeedback.lightImpact();
                widget.onTap!();
              }
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.purchases, AppColors.info],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purchases.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(color: Colors.white.withOpacity(0.05)),
                      ),
                    ),
                  ),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ملخص المشتريات',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.purchaseCount} عملية شراء',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.shopping_cart_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1200),
                        tween: Tween(begin: 0, end: widget.totalAmount),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                value.toStringAsFixed(0),
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'ر.ي',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      
                      const SizedBox(height: 8),
                      const Text(
                        'الإجمالي',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.check_circle_rounded,
                              label: 'مدفوع',
                              value: widget.paidAmount,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.schedule_rounded,
                              label: 'متبقي',
                              value: widget.remainingAmount,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0, end: value),
            curve: Curves.easeOutCubic,
            builder: (context, animValue, child) {
              return Text(
                '${animValue.toStringAsFixed(0)} ر.ي',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

