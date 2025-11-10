import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/debt.dart';

/// بطاقة عرض الدين
class DebtCard extends StatelessWidget {
  final Debt debt;
  final bool isOverdue;
  final int? daysOverdue;
  final VoidCallback? onTap;
  final VoidCallback? onPayment;
  final VoidCallback? onReminder;

  const DebtCard({
    super.key,
    required this.debt,
    this.isOverdue = false,
    this.daysOverdue,
    this.onTap,
    this.onPayment,
    this.onReminder,
  });

  @override
  Widget build(BuildContext context) {
    final progress = debt.totalAmount > 0 
        ? ((debt.totalAmount - debt.remainingAmount) / debt.totalAmount)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue ? AppColors.danger : AppColors.border,
          width: isOverdue ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isOverdue 
                        ? AppColors.danger.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: isOverdue ? AppColors.danger : AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          debt.customerName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (debt.customerPhone != null)
                          Text(
                            debt.customerPhone!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isOverdue && daysOverdue != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'متأخر $daysOverdue يوم',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textOnDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                debt.description ?? debt.debtType,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الإجمالي',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${debt.totalAmount.toStringAsFixed(0)} ريال',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'المتبقي',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${debt.remainingAmount.toStringAsFixed(0)} ريال',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.disabled,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverdue ? AppColors.danger : AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onPayment != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onPayment,
                        icon: const Icon(Icons.payment, size: 18),
                        label: const Text('دفع'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  if (onPayment != null && onReminder != null)
                    const SizedBox(width: 8),
                  if (onReminder != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReminder,
                        icon: const Icon(Icons.notifications, size: 18),
                        label: const Text('تذكير'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
