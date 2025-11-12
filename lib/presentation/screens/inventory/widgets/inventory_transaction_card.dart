import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/inventory_transaction.dart';

/// بطاقة عرض حركة المخزون - تصميم راقي هادئ
class InventoryTransactionCard extends StatelessWidget {
  final InventoryTransaction transaction;
  final VoidCallback? onTap;

  const InventoryTransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  Color _getTransactionColor() {
    switch (transaction.transactionType) {
      case 'شراء':
      case 'مرتجع':
        return AppColors.success;
      case 'بيع':
      case 'تالف':
        return AppColors.danger;
      case 'تعديل':
      case 'جرد':
        return AppColors.info;
      case 'تحويل':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTransactionIcon() {
    switch (transaction.transactionType) {
      case 'شراء':
        return Icons.add_shopping_cart_rounded;
      case 'بيع':
        return Icons.sell_rounded;
      case 'تعديل':
        return Icons.edit_rounded;
      case 'تحويل':
        return Icons.compare_arrows_rounded;
      case 'تالف':
        return Icons.broken_image_rounded;
      case 'مرتجع':
        return Icons.keyboard_return_rounded;
      case 'جرد':
        return Icons.inventory_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  bool get isIncrease => transaction.quantityChange > 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onTap?.call();
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _getTransactionColor().withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 12),
                  _buildDetails(),
                ],
              ),
            ),
          ),
        ),
      ),
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
                _getTransactionColor().withOpacity(0.15),
                _getTransactionColor().withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTransactionIcon(),
            color: _getTransactionColor(),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.qatTypeName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${transaction.transactionDate} ${transaction.transactionTime}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _getTransactionColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            transaction.transactionType,
            style: TextStyle(
              fontSize: 12,
              color: _getTransactionColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricItem(
              icon: Icons.straighten_rounded,
              label: 'الوحدة',
              value: transaction.unit,
              color: AppColors.info,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border.withOpacity(0.2),
          ),
          Expanded(
            child: _MetricItem(
              icon: isIncrease
                  ? Icons.add_circle_rounded
                  : Icons.remove_circle_rounded,
              label: 'التغيير',
              value: '${isIncrease ? '+' : ''}${transaction.quantityChange.toStringAsFixed(1)}',
              color: isIncrease ? AppColors.success : AppColors.danger,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border.withOpacity(0.2),
          ),
          Expanded(
            child: _MetricItem(
              icon: Icons.inventory_rounded,
              label: 'المتبقي',
              value: transaction.quantityAfter.toStringAsFixed(1),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
