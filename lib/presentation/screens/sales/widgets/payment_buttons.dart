import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// أزرار الدفع السريعة - تصميم Tesla/iOS متطور
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

class _PaymentButtonsState extends State<PaymentButtons>
    with TickerProviderStateMixin {
  late AnimationController _amountAnimationController;
  late AnimationController _buttonsAnimationController;
  late Animation<double> _amountScaleAnimation;
  late List<Animation<double>> _buttonSlideAnimations;

  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _amountAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _amountScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _amountAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _buttonSlideAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 100.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _buttonsAnimationController,
          curve: Interval(
            index * 0.2,
            0.6 + index * 0.2,
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });

    _amountAnimationController.forward();
    _buttonsAnimationController.forward();
  }

  @override
  void dispose() {
    _amountAnimationController.dispose();
    _buttonsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // المجموع الكلي المتحرك
        _buildAnimatedTotalAmount(),

        const SizedBox(height: 24),

        // أزرار الدفع
        _buildPaymentButtonsGrid(),
      ],
    );
  }

  Widget _buildAnimatedTotalAmount() {
    return AnimatedBuilder(
      animation: _amountScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _amountScaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: value * 2 * math.pi,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.payments,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'المجموع الكلي',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: widget.totalAmount),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(
                      '${value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    );
                  },
                ),
                Text(
                  'ريال سعودي',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentButtonsGrid() {
    final buttons = [
      _PaymentButtonData(
        title: 'دفع نقدي',
        subtitle: 'دفع كامل المبلغ نقداً',
        icon: Icons.payments,
        color: AppColors.success,
        onPressed: () => _handlePayment('cash', widget.onPayCash),
      ),
      _PaymentButtonData(
        title: 'دفع آجل',
        subtitle: 'تسجيل دين على العميل',
        icon: Icons.schedule,
        color: AppColors.warning,
        onPressed: () => _handlePayment('later', widget.onPayLater),
      ),
      _PaymentButtonData(
        title: 'دفع جزئي',
        subtitle: 'دفع جزء من المبلغ',
        icon: Icons.pie_chart,
        color: AppColors.info,
        onPressed: () => _handlePayment('partial', widget.onPayPartial),
      ),
    ];

    return Column(
      children: buttons.asMap().entries.map((entry) {
        final index = entry.key;
        final button = entry.value;

        return AnimatedBuilder(
          animation: _buttonSlideAnimations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_buttonSlideAnimations[index].value, 0),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ModernPaymentButton(
                  data: button,
                  isSelected: _selectedPaymentMethod == button.title,
                  isProcessing: widget.isProcessing,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  void _handlePayment(String method, VoidCallback onPressed) {
    if (widget.isProcessing) return;

    HapticFeedback.mediumImpact();
    setState(() => _selectedPaymentMethod = method);

    Future.delayed(const Duration(milliseconds: 300), () {
      onPressed();
    });
  }
}

// زر الدفع المحسن
class _ModernPaymentButton extends StatefulWidget {
  final _PaymentButtonData data;
  final bool isSelected;
  final bool isProcessing;

  const _ModernPaymentButton({
    required this.data,
    required this.isSelected,
    required this.isProcessing,
  });

  @override
  State<_ModernPaymentButton> createState() => _ModernPaymentButtonState();
}

class _ModernPaymentButtonState extends State<_ModernPaymentButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _pressController.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _pressController.reverse();
              if (!widget.isProcessing) {
                widget.data.onPressed();
              }
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _pressController.reverse();
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(
                        colors: [
                          widget.data.color,
                          widget.data.color.withOpacity(0.8),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          AppColors.surface,
                          AppColors.surface.withOpacity(0.95),
                        ],
                      ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected
                      ? widget.data.color
                      : widget.data.color.withOpacity(0.3),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? widget.data.color.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: _isPressed ? 25 : 20,
                    offset: Offset(0, _isPressed ? 10 : 8),
                    spreadRadius: _isPressed ? 2 : 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? Colors.white.withOpacity(0.2)
                          : widget.data.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: widget.isProcessing
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.isSelected
                                      ? Colors.white
                                      : widget.data.color,
                                ),
                              ),
                            )
                          : Icon(
                              widget.data.icon,
                              color: widget.isSelected
                                  ? Colors.white
                                  : widget.data.color,
                              size: 28,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data.title,
                          style: TextStyle(
                            color: widget.isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.data.subtitle,
                          style: TextStyle(
                            color: widget.isSelected
                                ? Colors.white.withOpacity(0.9)
                                : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: widget.isSelected
                        ? Colors.white
                        : AppColors.textHint,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// بيانات زر الدفع
class _PaymentButtonData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  _PaymentButtonData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
}
