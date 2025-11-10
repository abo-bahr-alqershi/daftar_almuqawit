import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart' as app_date;

/// بطاقة عرض دين العميل
class CustomerDebtCard extends StatelessWidget {
  final Debt debt;
  final VoidCallback? onTap;
  final VoidCallback? onPay;

  const CustomerDebtCard({
    super.key,
    required this.debt,
    this.onTap,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final progressPercentage = _calculateProgressPercentage();

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
              color: statusColor.withOpacity(0.3),
              width: 2,
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
              // الصف الأول: المبلغ المتبقي والحالة
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المبلغ المتبقي',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyUtils.format(debt.remainingAmount),
                          style: AppTextStyles.currencyLarge.copyWith(
                            color: statusColor,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // شارة الحالة
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      debt.status,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceM),
              
              // شريط التقدم
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تم السداد: ${CurrencyUtils.format(debt.paidAmount)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${progressPercentage.toStringAsFixed(0)}%',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    child: LinearProgressIndicator(
                      value: progressPercentage / 100,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceM),
              
              // الصف الثالث: تفاصيل إضافية
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.account_balance_wallet,
                      label: 'المبلغ الأصلي',
                      value: CurrencyUtils.format(debt.originalAmount),
                      color: AppColors.textSecondary,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'تاريخ الدين',
                      value: app_date.DateUtils.formatDate(debt.date),
                      color: AppColors.textSecondary,
                    ),
                    if (debt.dueDate != null) ...[
                      const Divider(height: 16),
                      _buildDetailRow(
                        icon: Icons.event,
                        label: 'تاريخ الاستحقاق',
                        value: app_date.DateUtils.formatDate(debt.dueDate!),
                        color: _isOverdue() ? AppColors.danger : AppColors.textSecondary,
                      ),
                    ],
                    if (debt.lastPaymentDate != null) ...[
                      const Divider(height: 16),
                      _buildDetailRow(
                        icon: Icons.payment,
                        label: 'آخر دفعة',
                        value: app_date.DateUtils.formatDate(debt.lastPaymentDate!),
                        color: AppColors.success,
                      ),
                    ],
                  ],
                ),
              ),
              
              // الملاحظات
              if (debt.notes != null && debt.notes!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spaceM),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingS),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.notes,
                        size: 16,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          debt.notes!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // زر الدفع
              if (onPay != null && debt.remainingAmount > 0) ...[
                const SizedBox(height: AppDimensions.spaceM),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onPay,
                    icon: const Icon(Icons.payment, size: 20),
                    label: const Text('تسديد دفعة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                        vertical: AppDimensions.paddingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (debt.status) {
      case 'مسدد':
        return AppColors.success;
      case 'مسدد جزئي':
        return AppColors.warning;
      case 'غير مسدد':
        return AppColors.debt;
      default:
        return AppColors.textSecondary;
    }
  }

  double _calculateProgressPercentage() {
    if (debt.originalAmount == 0) return 0;
    return (debt.paidAmount / debt.originalAmount) * 100;
  }

  bool _isOverdue() {
    if (debt.dueDate == null) return false;
    try {
      final dueDate = DateTime.parse(debt.dueDate!);
      return dueDate.isBefore(DateTime.now()) && debt.remainingAmount > 0;
    } catch (e) {
      return false;
    }
  }
}
