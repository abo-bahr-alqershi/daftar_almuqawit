import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/supplier.dart';

/// بطاقة عرض المورد
class SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SupplierCard({
    super.key,
    required this.supplier,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name and Actions
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.business,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                supplier.name,
                                style: AppTextStyles.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (supplier.area != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: AppColors.textTertiary,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        supplier.area!,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textTertiary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  Row(
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: Icon(Icons.edit, size: 20),
                          color: AppColors.primary,
                          onPressed: onEdit,
                          tooltip: 'تعديل',
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: Icon(Icons.delete, size: 20),
                          color: AppColors.danger,
                          onPressed: onDelete,
                          tooltip: 'حذف',
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Content: Phone, Rating, Trust Level
              Row(
                children: [
                  // Phone
                  if (supplier.phone != null)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              supplier.phone!,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 16),

                  // Quality Rating
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRatingColor(supplier.qualityRating).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: _getRatingColor(supplier.qualityRating),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          supplier.qualityRating.toString(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: _getRatingColor(supplier.qualityRating),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Trust Level
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTrustLevelColor(supplier.trustLevel).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getTrustLevelColor(supplier.trustLevel).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  supplier.trustLevel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _getTrustLevelColor(supplier.trustLevel),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Financial Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFinancialItem(
                        label: 'إجمالي المشتريات',
                        value: supplier.totalPurchases,
                        color: AppColors.purchases,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: AppColors.divider,
                    ),
                    Expanded(
                      child: _buildFinancialItem(
                        label: 'الدين له',
                        value: supplier.totalDebtToHim,
                        color: AppColors.debt,
                      ),
                    ),
                  ],
                ),
              ),

              // Notes
              if (supplier.notes != null && supplier.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          supplier.notes!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialItem({
    required String label,
    required double value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(2)} ر.س',
          style: AppTextStyles.labelMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return AppColors.success;
    if (rating >= 3) return AppColors.warning;
    return AppColors.danger;
  }

  Color _getTrustLevelColor(String trustLevel) {
    switch (trustLevel) {
      case 'موثوق':
        return AppColors.success;
      case 'متوسط':
        return AppColors.warning;
      case 'غير موثوق':
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }
}
