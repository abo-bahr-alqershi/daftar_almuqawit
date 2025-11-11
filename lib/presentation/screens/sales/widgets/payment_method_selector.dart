import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// محدد طريقة الدفع - تصميم Tesla/iOS متطور
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

class _PaymentMethodSelectorState extends State<PaymentMethodSelector>
    with TickerProviderStateMixin {
  late AnimationController _selectionAnimationController;
  late AnimationController _rippleAnimationController;
  late Animation<double> _selectionScaleAnimation;
  late Animation<double> _rippleAnimation;

  static final List<PaymentMethodOption> paymentMethods = [
    PaymentMethodOption(
      value: 'نقدي',
      label: 'نقدي',
      icon: Icons.payments,
      color: AppColors.success,
      description: 'دفع فوري نقدي',
    ),
    PaymentMethodOption(
      value: 'آجل',
      label: 'آجل',
      icon: Icons.schedule,
      color: AppColors.warning,
      description: 'دفع مؤجل',
    ),
    PaymentMethodOption(
      value: 'حوالة',
      label: 'حوالة',
      icon: Icons.swap_horiz,
      color: AppColors.info,
      description: 'حوالة بنكية',
    ),
    PaymentMethodOption(
      value: 'محفظة',
      label: 'محفظة',
      icon: Icons.account_balance_wallet,
      color: AppColors.primary,
      description: 'محفظة إلكترونية',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _selectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rippleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _selectionScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _selectionAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleAnimationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _selectionAnimationController.dispose();
    _rippleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        _buildHeader(),

        const SizedBox(height: 16),

        // Payment Methods Grid
        _buildPaymentMethodsGrid(),

        const SizedBox(height: 16),

        // Selected Method Details
        _buildSelectedMethodDetails(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.accent.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.payment, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طريقة الدفع',
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'اختر طريقة الدفع المناسبة',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: paymentMethods.length,
      itemBuilder: (context, index) {
        final method = paymentMethods[index];
        final isSelected = widget.selectedMethod == method.value;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (value * 0.2),
              child: Opacity(
                opacity: value,
                child: _ModernPaymentMethodCard(
                  method: method,
                  isSelected: isSelected,
                  enabled: widget.enabled,
                  onTap: () => _selectMethod(method.value),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSelectedMethodDetails() {
    final selectedMethodOption = paymentMethods.firstWhere(
      (m) => m.value == widget.selectedMethod,
      orElse: () => paymentMethods.first,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            selectedMethodOption.color.withOpacity(0.05),
            selectedMethodOption.color.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selectedMethodOption.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: selectedMethodOption.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              selectedMethodOption.icon,
              color: selectedMethodOption.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الطريقة المختارة',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedMethodOption.label,
                  style: TextStyle(
                    color: selectedMethodOption.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: selectedMethodOption.color,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  void _selectMethod(String method) {
    if (!widget.enabled) return;

    HapticFeedback.selectionClick();

    widget.onChanged(method);

    _selectionAnimationController.forward(from: 0);
    _rippleAnimationController.forward(from: 0);
  }
}

// بطاقة طريقة الدفع المحسنة
class _ModernPaymentMethodCard extends StatefulWidget {
  final PaymentMethodOption method;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _ModernPaymentMethodCard({
    required this.method,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_ModernPaymentMethodCard> createState() =>
      _ModernPaymentMethodCardState();
}

class _ModernPaymentMethodCardState extends State<_ModernPaymentMethodCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      onTapDown: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onTapUp: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      onTapCancel: () {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: widget.isSelected
                  ? LinearGradient(
                      colors: [
                        widget.method.color,
                        widget.method.color.withOpacity(0.8),
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
                    ? widget.method.color
                    : widget.method.color.withOpacity(0.2),
                width: widget.isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isSelected
                      ? widget.method.color.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: _isHovered ? 20 : 12,
                  offset: Offset(0, _isHovered ? 8 : 4),
                  spreadRadius: _isHovered ? 2 : 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Ripple Effect
                if (_isHovered)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: RadialGradient(
                          colors: [
                            widget.method.color.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: 1.0 + (_hoverAnimation.value * 0.1),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: widget.isSelected
                                ? Colors.white.withOpacity(0.2)
                                : widget.method.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            widget.method.icon,
                            color: widget.isSelected
                                ? Colors.white
                                : widget.method.color,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.method.label,
                        style: TextStyle(
                          color: widget.isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.method.description,
                        style: TextStyle(
                          color: widget.isSelected
                              ? Colors.white.withOpacity(0.8)
                              : AppColors.textSecondary,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Selected Indicator
                if (widget.isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: widget.method.color,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
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
