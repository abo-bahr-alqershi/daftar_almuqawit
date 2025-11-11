import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'menu_card.dart';
import '../../../navigation/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// شبكة القوائم الرئيسية - تصميم متطور
class MenuGrid extends StatefulWidget {
  const MenuGrid({super.key, this.pendingDebtsCount, this.overdueDebtsCount});
  final int? pendingDebtsCount;
  final int? overdueDebtsCount;

  @override
  State<MenuGrid> createState() => _MenuGridState();
}

class _MenuGridState extends State<MenuGrid> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;

  final List<_MenuItemData> menuItems = [];

  @override
  void initState() {
    super.initState();
    _initializeMenuItems();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeMenuItems() {
    menuItems.addAll([
      _MenuItemData(
        title: 'الموردين',
        icon: Icons.local_shipping_rounded,
        color: AppColors.primary,
        route: RouteNames.suppliers,
        subtitle: 'إدارة الموردين',
      ),
      _MenuItemData(
        title: 'العملاء',
        icon: Icons.people_rounded,
        color: AppColors.accent,
        route: RouteNames.customers,
        subtitle: 'قائمة العملاء',
      ),
      _MenuItemData(
        title: 'المبيعات',
        icon: Icons.point_of_sale_rounded,
        color: AppColors.success,
        route: RouteNames.sales,
        subtitle: 'عمليات البيع',
        isNew: true,
      ),
      _MenuItemData(
        title: 'المشتريات',
        icon: Icons.shopping_cart_rounded,
        color: AppColors.info,
        route: RouteNames.purchases,
        subtitle: 'عمليات الشراء',
      ),
      _MenuItemData(
        title: 'الديون',
        icon: Icons.receipt_long_rounded,
        color: AppColors.warning,
        route: RouteNames.debts,
        subtitle: 'إدارة الديون',
        badge: widget.overdueDebtsCount != null && widget.overdueDebtsCount! > 0
            ? widget.overdueDebtsCount.toString()
            : null,
      ),
      _MenuItemData(
        title: 'المصروفات',
        icon: Icons.money_off_rounded,
        color: AppColors.danger,
        route: RouteNames.expenses,
        subtitle: 'تتبع المصروفات',
      ),
      _MenuItemData(
        title: 'الحسابات',
        icon: Icons.account_balance_rounded,
        color: const Color(0xFF6C63FF),
        route: RouteNames.accounts,
        subtitle: 'الحسابات المالية',
        isPremium: true,
      ),
      _MenuItemData(
        title: 'الإحصائيات',
        icon: Icons.analytics_rounded,
        color: const Color(0xFFFF6584),
        route: RouteNames.statistics,
        subtitle: 'تحليلات مفصلة',
      ),
      _MenuItemData(
        title: 'التقارير',
        icon: Icons.assessment_rounded,
        color: const Color(0xFF9C27B0),
        route: RouteNames.reports,
        subtitle: 'تقارير شاملة',
      ),
      _MenuItemData(
        title: 'أنواع القات',
        icon: Icons.category_rounded,
        color: const Color(0xFF00BCD4),
        route: RouteNames.qatTypes,
        subtitle: 'إدارة الأصناف',
      ),
      _MenuItemData(
        title: 'الإعدادات',
        icon: Icons.settings_rounded,
        color: const Color(0xFF607D8B),
        route: RouteNames.settings,
        subtitle: 'إعدادات التطبيق',
      ),
      _MenuItemData(
        title: 'دفعات الديون',
        icon: Icons.payment_rounded,
        color: const Color(0xFF795548),
        route: RouteNames.debtPayments,
        subtitle: 'سداد الديون',
      ),
    ]);
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      menuItems.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 50)),
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

    _fadeAnimations = _controllers
        .map(
          (controller) => Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: controller,
              curve: const Interval(0, 0.8, curve: Curves.easeIn),
            ),
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
    padding: const EdgeInsets.only(left: 20, right: 20),
    child: Column(
      children: [
        // Header with view toggle
        // _buildHeader(),
        const SizedBox(height: 16),

        // Grid View (precise two-column layout using Wrap)
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(menuItems.length, (index) {
            final item = menuItems[index];
            return LayoutBuilder(
              builder: (context, constraints) {
                // Calculate the width for each card (2 columns)
                final screenWidth = MediaQuery.of(context).size.width;
                const horizontalPadding = 40.0; // 20 left + 20 right
                const spacing = 16.0;
                final tileWidth =
                    (screenWidth - horizontalPadding - spacing) / 2;

                return SizedBox(
                  width: tileWidth,
                  height: 140, // Fixed height for consistency
                  child: AnimatedBuilder(
                    animation: _controllers[index],
                    builder: (context, child) => FadeTransition(
                      opacity: _fadeAnimations[index],
                      child: ScaleTransition(
                        scale: _scaleAnimations[index],
                        child: MenuCard(
                          title: item.title,
                          icon: item.icon,
                          color: item.color,
                          subtitle: item.subtitle,
                          badge: item.badge,
                          isNew: item.isNew,
                          isPremium: item.isPremium,
                          onTap: () => _navigateToRoute(context, item.route),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),

        // Quick Access Section
        const SizedBox(height: 32),
        _buildQuickAccessSection(),
      ],
    ),
  );

  Widget _buildQuickAccessSection() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.05),
          AppColors.accent.withOpacity(0.03),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border.withOpacity(0.1)),
    ),
    child: Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.rocket_launch_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'وصول سريع',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickAccessButton(
                icon: Icons.qr_code_scanner_rounded,
                label: 'مسح باركود',
                color: AppColors.info,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAccessButton(
                icon: Icons.calculate_rounded,
                label: 'آلة حاسبة',
                color: AppColors.success,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAccessButton(
                icon: Icons.support_agent_rounded,
                label: 'الدعم',
                color: AppColors.warning,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    ),
  );

  void _navigateToRoute(BuildContext context, String route) {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, route);
  }
}

// بيانات عنصر القائمة
class _MenuItemData {
  _MenuItemData({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    this.subtitle,
    this.badge,
    this.isNew = false,
    this.isPremium = false,
  });
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  final String? subtitle;
  final String? badge;
  final bool isNew;
  final bool isPremium;
}

// زر الوصول السريع
class _QuickAccessButton extends StatefulWidget {
  const _QuickAccessButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_QuickAccessButton> createState() => _QuickAccessButtonState();
}

class _QuickAccessButtonState extends State<_QuickAccessButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) {
      setState(() => _isPressed = true);
      _controller.forward();
    },
    onTapUp: (_) {
      setState(() => _isPressed = false);
      _controller.reverse();
    },
    onTapCancel: () {
      setState(() => _isPressed = false);
      _controller.reverse();
    },
    onTap: () {
      HapticFeedback.lightImpact();
      widget.onTap();
    },
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _isPressed
                ? widget.color.withOpacity(0.15)
                : widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(widget.icon, color: widget.color, size: 24),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
