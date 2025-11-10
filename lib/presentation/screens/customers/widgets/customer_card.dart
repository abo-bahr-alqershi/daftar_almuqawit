import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../domain/entities/customer.dart';
import '../../../../core/utils/currency_utils.dart';

/// بطاقة عرض بيانات العميل
class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(
              color: statusColor.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصف الأول: الاسم والحالة
              Row(
                children: [
                  // أيقونة العميل
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: Icon(
                      Icons.person,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceM),
                  // اسم العميل والكنية
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: AppTextStyles.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (customer.nickname != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            customer.nickname!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceS),
                  // شارة الحالة
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          customer.getCustomerStatus(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceM),
              // الصف الثاني: معلومات مالية
              Row(
                children: [
                  // الدين الحالي
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.account_balance_wallet,
                      label: 'الدين',
                      value: CurrencyUtils.format(customer.currentDebt),
                      color: customer.currentDebt > 0 ? AppColors.debt : AppColors.success,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.divider,
                    margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceS),
                  ),
                  // إجمالي المشتريات
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.shopping_cart,
                      label: 'المشتريات',
                      value: CurrencyUtils.format(customer.totalPurchases),
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              // الصف الثالث: الهاتف ونوع العميل
              if (customer.phone != null || customer.customerType != 'عادي') ...[
                const SizedBox(height: AppDimensions.spaceM),
                Row(
                  children: [
                    if (customer.phone != null) ...[
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          customer.phone!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (customer.phone != null && customer.customerType != 'عادي')
                      const SizedBox(width: AppDimensions.spaceS),
                    if (customer.customerType != 'عادي')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCustomerTypeColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                        ),
                        child: Text(
                          customer.customerType,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: _getCustomerTypeColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              // أزرار الإجراءات
              if (showActions) ...[
                const SizedBox(height: AppDimensions.spaceM),
                const Divider(height: 1),
                const SizedBox(height: AppDimensions.spaceS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('تعديل'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.info,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    if (onDelete != null) ...[
                      const SizedBox(width: AppDimensions.spaceS),
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('حذف'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (customer.isBlocked) return AppColors.danger;
    if (customer.hasExceededCreditLimit) return AppColors.warning;
    if (customer.currentDebt > 0) return AppColors.debt;
    return AppColors.success;
  }

  IconData _getStatusIcon() {
    if (customer.isBlocked) return Icons.block;
    if (customer.hasExceededCreditLimit) return Icons.warning;
    if (customer.currentDebt > 0) return Icons.trending_up;
    return Icons.check_circle;
  }

  Color _getCustomerTypeColor() {
    switch (customer.customerType) {
      case 'VIP':
        return AppColors.warning;
      case 'جديد':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }
}
