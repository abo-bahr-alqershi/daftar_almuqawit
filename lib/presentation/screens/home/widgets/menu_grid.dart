import 'package:flutter/material.dart';
import 'menu_card.dart';
import '../../../navigation/route_names.dart';
import '../../../../core/theme/app_colors.dart';

/// شبكة القوائم الرئيسية
class MenuGrid extends StatelessWidget {
  final int? pendingDebtsCount;
  final int? overdueDebtsCount;

  const MenuGrid({
    super.key,
    this.pendingDebtsCount,
    this.overdueDebtsCount,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        MenuCard(
          title: 'الموردين',
          icon: Icons.local_shipping_rounded,
          color: AppColors.primary,
          onTap: () => Navigator.pushNamed(context, RouteNames.suppliers),
        ),
        MenuCard(
          title: 'العملاء',
          icon: Icons.people_rounded,
          color: AppColors.accent,
          onTap: () => Navigator.pushNamed(context, RouteNames.customers),
        ),
        MenuCard(
          title: 'المبيعات',
          icon: Icons.point_of_sale_rounded,
          color: AppColors.success,
          onTap: () => Navigator.pushNamed(context, RouteNames.sales),
        ),
        MenuCard(
          title: 'المشتريات',
          icon: Icons.shopping_cart_rounded,
          color: AppColors.info,
          onTap: () => Navigator.pushNamed(context, RouteNames.purchases),
        ),
        MenuCard(
          title: 'الديون',
          icon: Icons.receipt_long_rounded,
          color: AppColors.warning,
          onTap: () => Navigator.pushNamed(context, RouteNames.debts),
          badge: overdueDebtsCount != null && overdueDebtsCount! > 0
              ? overdueDebtsCount.toString()
              : null,
        ),
        MenuCard(
          title: 'المصروفات',
          icon: Icons.money_off_rounded,
          color: AppColors.danger,
          onTap: () => Navigator.pushNamed(context, RouteNames.expenses),
        ),
        MenuCard(
          title: 'الحسابات',
          icon: Icons.account_balance_rounded,
          color: const Color(0xFF6C63FF),
          onTap: () => Navigator.pushNamed(context, RouteNames.accounts),
        ),
        MenuCard(
          title: 'الإحصائيات',
          icon: Icons.analytics_rounded,
          color: const Color(0xFFFF6584),
          onTap: () => Navigator.pushNamed(context, RouteNames.statistics),
        ),
      ],
    );
  }
}
