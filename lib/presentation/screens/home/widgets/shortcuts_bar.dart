import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// شريط الاختصارات السريعة
class ShortcutsBar extends StatelessWidget {
  final VoidCallback? onQuickSale;
  final VoidCallback? onAddPurchase;
  final VoidCallback? onAddExpense;
  final VoidCallback? onViewReports;

  const ShortcutsBar({
    super.key,
    this.onQuickSale,
    this.onAddPurchase,
    this.onAddExpense,
    this.onViewReports,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ShortcutButton(
            icon: Icons.flash_on,
            label: 'بيع سريع',
            color: AppColors.success,
            onTap: onQuickSale,
          ),
          _ShortcutButton(
            icon: Icons.add_shopping_cart,
            label: 'شراء',
            color: AppColors.info,
            onTap: onAddPurchase,
          ),
          _ShortcutButton(
            icon: Icons.payment,
            label: 'مصروف',
            color: AppColors.danger,
            onTap: onAddExpense,
          ),
          _ShortcutButton(
            icon: Icons.bar_chart,
            label: 'تقارير',
            color: AppColors.primary,
            onTap: onViewReports,
          ),
        ],
      ),
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ShortcutButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
