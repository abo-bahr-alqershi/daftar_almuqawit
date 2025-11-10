import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../domain/entities/purchase.dart';
import '../../../../core/utils/currency_utils.dart';

/// بطاقة عرض بيانات عملية الشراء
class PurchaseItemCard extends StatelessWidget {
  final Purchase purchase;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;
  final bool showActions;

  const PurchaseItemCard({
    super.key,
    required this.purchase,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onCancel,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final paymentColor = _getPaymentStatusColor();
    final statusColor = purchase.status == 'نشط' ? AppColors.success : AppColors.warning;

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
              color: paymentColor.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: paymentColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: const Icon(
                      Icons.shopping_cart,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          purchase.supplierName ?? 'مورد غير محدد',
                          style: AppTextStyles.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${purchase.quantity} ${purchase.unit}${purchase.qatTypeName != null ? ' - ${purchase.qatTypeName}' : ''}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: paymentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      purchase.paymentStatus,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: paymentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceM),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.calculate,
                      label: 'الإجمالي',
                      value: CurrencyUtils.format(purchase.totalAmount),
                      color: AppColors.primary,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.divider,
                    margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceS),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.account_balance_wallet,
                      label: 'المدفوع',
                      value: CurrencyUtils.format(purchase.paidAmount),
                      color: AppColors.success,
                    ),
                  ),
                  if (purchase.remainingAmount > 0) ...[
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.divider,
                      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceS),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.trending_up,
                        label: 'المتبقي',
                        value: CurrencyUtils.format(purchase.remainingAmount),
                        color: AppColors.debt,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppDimensions.spaceM),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    purchase.date,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceM),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    purchase.time,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (purchase.status != 'نشط')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cancel,
                            size: 12,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ملغي',
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
              if (showActions) ...[
                const SizedBox(height: AppDimensions.spaceM),
                const Divider(height: 1),
                const SizedBox(height: AppDimensions.spaceS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null && purchase.status == 'نشط')
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
                    if (onCancel != null && purchase.status == 'نشط') ...[
                      const SizedBox(width: AppDimensions.spaceS),
                      TextButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('إلغاء'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
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

  Color _getPaymentStatusColor() {
    switch (purchase.paymentStatus) {
      case 'مدفوع':
        return AppColors.success;
      case 'مدفوع جزئياً':
        return AppColors.warning;
      case 'غير مدفوع':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }
}

