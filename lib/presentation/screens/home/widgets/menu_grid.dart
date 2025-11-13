import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'menu_card.dart';
import '../../../navigation/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../blocs/settings/settings_bloc.dart';
import '../../../blocs/settings/settings_state.dart';
import '../../../../core/services/qat_types_tutorial_manager.dart';

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
  final List<_MenuItemData> operationItems = [];

  @override
  void initState() {
    super.initState();
    _initializeMenuItems();
    _initializeOperationItems();
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
        title: 'المخزون',
        icon: Icons.inventory_rounded,
        color: const Color(0xFF00BCD4),
        route: RouteNames.inventory,
        subtitle: 'إدارة المخزون',
        isNew: true,
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

  void _initializeOperationItems() {
    operationItems.addAll([
      _MenuItemData(
        title: 'إضافة نوع قات',
        icon: Icons.add_circle_rounded,
        color: AppColors.success,
        route: RouteNames.addQatType,
        subtitle: 'إضافة صنف جديد',
      ),
      _MenuItemData(
        title: 'تعديل نوع قات',
        icon: Icons.edit_rounded,
        color: AppColors.info,
        route: RouteNames.qatTypes,
        subtitle: 'تعديل الأصناف',
      ),
      _MenuItemData(
        title: 'حذف نوع قات',
        icon: Icons.delete_rounded,
        color: AppColors.danger,
        route: RouteNames.qatTypes,
        subtitle: 'حذف الأصناف',
      ),
      _MenuItemData(
        title: 'إضافة مورد',
        icon: Icons.person_add_rounded,
        color: AppColors.primary,
        route: RouteNames.suppliers,
        subtitle: 'إضافة مورد جديد',
      ),
      _MenuItemData(
        title: 'تعديل مورد',
        icon: Icons.person_outline_rounded,
        color: AppColors.accent,
        route: RouteNames.suppliers,
        subtitle: 'تعديل بيانات المورد',
      ),
      _MenuItemData(
        title: 'حذف مورد',
        icon: Icons.person_remove_rounded,
        color: AppColors.warning,
        route: RouteNames.suppliers,
        subtitle: 'حذف المورد',
      ),
      _MenuItemData(
        title: 'إضافة عميل',
        icon: Icons.group_add_rounded,
        color: AppColors.success,
        route: RouteNames.customers,
        subtitle: 'إضافة عميل جديد',
      ),
      _MenuItemData(
        title: 'تعديل عميل',
        icon: Icons.people_outline_rounded,
        color: AppColors.info,
        route: RouteNames.customers,
        subtitle: 'تعديل بيانات العميل',
      ),
      _MenuItemData(
        title: 'حذف عميل',
        icon: Icons.group_remove_rounded,
        color: AppColors.danger,
        route: RouteNames.customers,
        subtitle: 'حذف العميل',
      ),
      _MenuItemData(
        title: 'إضافة مبيعة',
        icon: Icons.shopping_cart_checkout_rounded,
        color: AppColors.purchases,
        route: RouteNames.sales,
        subtitle: 'تسجيل مبيعة جديدة',
      ),
      _MenuItemData(
        title: 'تعديل مبيعة',
        icon: Icons.receipt_long_rounded,
        color: AppColors.warning,
        route: RouteNames.sales,
        subtitle: 'تعديل المبيعة',
      ),
      _MenuItemData(
        title: 'إضافة مشترى',
        icon: Icons.add_shopping_cart_rounded,
        color: const Color(0xFF00BCD4),
        route: RouteNames.purchases,
        subtitle: 'تسجيل مشترى جديد',
      ),
    ]);
  }

  void _initializeAnimations() {
    final maxLength = menuItems.length > operationItems.length 
        ? menuItems.length 
        : operationItems.length;
    
    _controllers = List.generate(
      maxLength,
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
  Widget build(BuildContext context) => BlocBuilder<SettingsBloc, SettingsState>(
    builder: (context, state) {
      final isLearningMode = state is SettingsLoaded && state.learningModeEnabled;
      final currentItems = isLearningMode ? operationItems : menuItems;
      
      return Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            // Header with mode indicator
            if (isLearningMode) _buildLearningModeHeader(),
            const SizedBox(height: 16),

            // Grid View (precise two-column layout using Wrap)
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: List.generate(currentItems.length, (index) {
                final item = currentItems[index];
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
                      child: index < _controllers.length
                          ? AnimatedBuilder(
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
                                    onTap: () => _navigateToRoute(
                                      context, 
                                      item.route,
                                      operation: _getOperationFromTitle(item.title),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : MenuCard(
                              title: item.title,
                              icon: item.icon,
                              color: item.color,
                              subtitle: item.subtitle,
                              badge: item.badge,
                              isNew: item.isNew,
                              isPremium: item.isPremium,
                              onTap: () => _navigateToRoute(
                                context, 
                                item.route,
                                operation: _getOperationFromTitle(item.title),
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
    },
  );

  Widget _buildLearningModeHeader() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.purchases.withOpacity(0.1),
          AppColors.purchases.withOpacity(0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.purchases.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.purchases.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.school_rounded,
            color: AppColors.purchases,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'وضع التعلم مفعل',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.purchases,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'عرض أزرار العمليات للتعلم',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.lightbulb_rounded,
          color: AppColors.purchases.withOpacity(0.7),
          size: 18,
        ),
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

  void _navigateToRoute(BuildContext context, String route, {String? operation}) {
    HapticFeedback.mediumImpact();
    
    // التحقق من وضع التعلم
    final settingsState = context.read<SettingsBloc>().state;
    final isLearningMode = settingsState is SettingsLoaded && settingsState.learningModeEnabled;
    
    if (isLearningMode && _isQatTypeRoute(route) && operation != null) {
      // عرض التعليمات قبل التنقل لأنواع القات
      _showQatTypesTutorial(context, operation, route);
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  void _showQatTypesTutorial(BuildContext context, String operation, String route) {
    // عرض حوار تأكيد بدء التعليمات
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00BCD4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.school_rounded,
                color: const Color(0xFF00BCD4),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'تعليمات تفاعلية',
                style: AppTextStyles.titleMedium.copyWith(
                  color: const Color(0xFF00BCD4),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getTutorialDescription(operation),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.info,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ستحصل على إرشادات تفاعلية خطوة بخطوة',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, route);
            },
            child: Text(
              'تخطي التعليمات',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context, 
                route,
                arguments: {'showTutorial': true, 'operation': operation},
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('بدء التعليمات'),
          ),
        ],
      ),
    );
  }

  bool _isQatTypeRoute(String route) {
    return route == RouteNames.qatTypes || 
           route == RouteNames.addQatType || 
           route == RouteNames.editQatType;
  }

  String? _getOperationFromTitle(String title) {
    if (title.contains('إضافة')) return 'add';
    if (title.contains('تعديل')) return 'edit';
    if (title.contains('حذف')) return 'delete';
    return null;
  }

  String _getTutorialDescription(String operation) {
    switch (operation) {
      case 'add':
        return 'سنوضح لك كيفية إضافة نوع قات جديد خطوة بخطوة، من إدخال الاسم والسعر حتى حفظ البيانات.';
      case 'edit':
        return 'سنعرض لك كيفية تعديل بيانات نوع قات موجود، وكيفية تحديث المعلومات بسهولة.';
      case 'delete':
        return 'سنشرح لك عملية حذف نوع قات بأمان، مع التأكيدات اللازمة لتجنب الأخطاء.';
      default:
        return 'سنقدم لك إرشادات تفاعلية لتعلم هذه العملية بسهولة.';
    }
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
