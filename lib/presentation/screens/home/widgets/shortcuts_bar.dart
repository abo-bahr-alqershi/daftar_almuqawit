import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// شريط الاختصارات السريعة - تصميم Tesla/iOS متطور
class ShortcutsBar extends StatefulWidget {
  const ShortcutsBar({
    super.key,
    this.onQuickSale,
    this.onAddPurchase,
    this.onAddExpense,
    this.onViewReports,
  });
  final VoidCallback? onQuickSale;
  final VoidCallback? onAddPurchase;
  final VoidCallback? onAddExpense;
  final VoidCallback? onViewReports;

  @override
  State<ShortcutsBar> createState() => _ShortcutsBarState();
}

class _ShortcutsBarState extends State<ShortcutsBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _rotateAnimations;

  int? _selectedIndex;

  final List<_ShortcutItem> shortcuts = [];

  @override
  void initState() {
    super.initState();

    _initializeShortcuts();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeShortcuts() {
    shortcuts.addAll([
      _ShortcutItem(
        icon: Icons.flash_on_rounded,
        label: 'بيع سريع',
        color: AppColors.success,
        gradientColors: [AppColors.success, AppColors.success.withOpacity(0.7)],
        onTap: widget.onQuickSale,
        description: 'إضافة عملية بيع',
      ),
      _ShortcutItem(
        icon: Icons.add_shopping_cart_rounded,
        label: 'شراء',
        color: AppColors.info,
        gradientColors: [AppColors.info, AppColors.info.withOpacity(0.7)],
        onTap: widget.onAddPurchase,
        description: 'تسجيل مشتريات',
      ),
      _ShortcutItem(
        icon: Icons.payment_rounded,
        label: 'مصروف',
        color: AppColors.danger,
        gradientColors: [AppColors.danger, AppColors.danger.withOpacity(0.7)],
        onTap: widget.onAddExpense,
        description: 'إضافة مصروف',
      ),
      _ShortcutItem(
        icon: Icons.bar_chart_rounded,
        label: 'تقارير',
        color: AppColors.primary,
        gradientColors: [AppColors.primary, AppColors.primaryDark],
        onTap: widget.onViewReports,
        description: 'عرض التقارير',
      ),
    ]);
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      shortcuts.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 100)),
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers
        .map(
          (controller) => Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut),
          ),
        )
        .toList();

    _rotateAnimations = _controllers
        .map(
          (controller) => Tween<double>(begin: -0.1, end: 0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
          ),
        )
        .toList();
  }

  Future<void> _startAnimations() async {
    for (var i = 0; i < _controllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        _controllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header (Optional)
        _buildHeader(),

        const SizedBox(height: 12),

        // Shortcuts Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: shortcuts.asMap().entries.map((entry) {
              final index = entry.key;
              final shortcut = entry.value;

              return AnimatedBuilder(
                animation: _controllers[index],
                builder: (context, child) => Transform.rotate(
                  angle: _rotateAnimations[index].value,
                  child: Transform.scale(
                    scale: _scaleAnimations[index].value,
                    child: _ModernShortcutButton(
                      item: shortcut,
                      isSelected: _selectedIndex == index,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        setState(() => _selectedIndex = index);
                        Future.delayed(const Duration(milliseconds: 200), () {
                          if (shortcut.onTap != null) {
                            shortcut.onTap!();
                          }
                          setState(() => _selectedIndex = null);
                        });
                      },
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'إجراءات سريعة',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const Text(
          'اسحب لليسار',
          style: TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
      ],
    ),
  );
}

// زر الاختصار المحسن
class _ModernShortcutButton extends StatefulWidget {
  const _ModernShortcutButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });
  final _ShortcutItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_ModernShortcutButton> createState() => _ModernShortcutButtonState();
}

class _ModernShortcutButtonState extends State<_ModernShortcutButton>
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

    _hoverAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    child: MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        width: widget.isSelected || _isHovered ? 140 : 120,
        child: Stack(
          children: [
            // Main Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isSelected
                      ? widget.item.gradientColors
                      : [
                          widget.item.color.withOpacity(0.1),
                          widget.item.color.withOpacity(0.05),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected
                      ? Colors.white.withOpacity(0.3)
                      : widget.item.color.withOpacity(0.2),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.item.color.withOpacity(
                      widget.isSelected ? 0.4 : 0.2,
                    ),
                    blurRadius: widget.isSelected ? 20 : 12,
                    offset: const Offset(0, 6),
                    spreadRadius: widget.isSelected ? 2 : 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with Animation
                  AnimatedBuilder(
                    animation: _hoverAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: 1.0 + (_hoverAnimation.value * 0.1),
                      child: Transform.rotate(
                        angle: _hoverAnimation.value * 0.05,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: widget.isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: widget.item.color.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.item.icon,
                            color: widget.isSelected
                                ? Colors.white
                                : widget.item.color,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Label
                  Text(
                    widget.item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: widget.isSelected
                          ? Colors.white
                          : AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),

                  // Description (shown on hover)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: _isHovered ? 16 : 0,
                    child: Text(
                      widget.item.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.isSelected
                            ? Colors.white.withOpacity(0.8)
                            : AppColors.textHint,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Ripple Effect
            if (widget.isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

            // New Badge (Optional)
            if (widget.item.isNew)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'جديد',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

// بيانات عنصر الاختصار
class _ShortcutItem {
  _ShortcutItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.gradientColors,
    required this.description,
    this.onTap,
    this.isNew = false,
  });
  final IconData icon;
  final String label;
  final Color color;
  final List<Color> gradientColors;
  final VoidCallback? onTap;
  final String description;
  final bool isNew;
}
