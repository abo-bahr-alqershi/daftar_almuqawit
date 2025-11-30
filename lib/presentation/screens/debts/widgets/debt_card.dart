import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/debt.dart';

/// بطاقة عرض الدين - تصميم راقي هادئ
class DebtCard extends StatelessWidget {
  final Debt debt;
  final VoidCallback? onTap;
  final VoidCallback? onPayTap;
  final VoidCallback? onReminderTap;

  const DebtCard({
    super.key,
    required this.debt,
    this.onTap,
    this.onPayTap,
    this.onReminderTap,
  });

  Color _getStatusColor() {
    switch (debt.status) {
      case 'مسدد':
        return AppColors.success;
      case 'مسدد جزئي':
        return AppColors.warning;
      case 'غير مسدد':
      default:
        return AppColors.danger;
    }
  }

  bool _isOverdue() {
    if (debt.dueDate == null) return false;
    final dueDate = DateTime.parse(debt.dueDate!);
    return dueDate.isBefore(DateTime.now()) && debt.remainingAmount > 0;
  }

  int _getDaysOverdue() {
    if (!_isOverdue()) return 0;
    final dueDate = DateTime.parse(debt.dueDate!);
    return DateTime.now().difference(dueDate).inDays;
  }

  double _getProgressPercentage() {
    if (debt.originalAmount == 0) return 0;
    return (debt.paidAmount / debt.originalAmount).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = _isOverdue();
    final daysOverdue = _getDaysOverdue();
    final progress = _getProgressPercentage();
    final statusColor = _getStatusColor();

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isOverdue 
                ? AppColors.danger.withOpacity(0.3) 
                : AppColors.border.withOpacity(0.1),
            width: isOverdue ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isOverdue 
                  ? AppColors.danger.withOpacity(0.08)
                  : Colors.black.withOpacity(0.03),
              blurRadius: isOverdue ? 12 : 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(statusColor, isOverdue, daysOverdue),
                  const SizedBox(height: 12),
                  _buildAmountSection(),
                  const SizedBox(height: 12),
                  _buildProgressBar(progress, statusColor),
                  const SizedBox(height: 12),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color statusColor, bool isOverdue, int daysOverdue) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withOpacity(0.2),
                statusColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.person_rounded,
            color: statusColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      debt.personName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.danger.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            size: 12,
                            color: AppColors.danger,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'متأخر $daysOverdue يوم',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildPersonTypeChip(),
                  const SizedBox(width: 8),
                  if (debt.customerPhone != null) ...[
                    Icon(
                      Icons.phone_rounded,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      debt.customerPhone!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Icon(
                    Icons.category_rounded,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    debt.transactionType ?? 'دين عام',
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
      ],
    );
  }

  Widget _buildPersonTypeChip() {
    final isSupplier = debt.personType == 'مورد';
    final Color typeColor = isSupplier ? AppColors.info : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: typeColor.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSupplier ? Icons.storefront_rounded : Icons.person_rounded,
            size: 12,
            color: typeColor,
          ),
          const SizedBox(width: 4),
          Text(
            isSupplier ? 'دين لمورد' : 'دين على عميل',
            style: AppTextStyles.bodySmall.copyWith(
              color: typeColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.danger.withOpacity(0.05),
            AppColors.warning.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _AmountInfo(
              label: 'المبلغ الكلي',
              amount: debt.originalAmount,
              icon: Icons.account_balance_wallet_rounded,
              color: AppColors.textSecondary,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border.withOpacity(0.3),
          ),
          Expanded(
            child: _AmountInfo(
              label: 'المتبقي',
              amount: debt.remainingAmount,
              icon: Icons.trending_up_rounded,
              color: AppColors.danger,
              isBold: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'نسبة السداد',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.border.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _formatDate(debt.date),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
            if (debt.dueDate != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.event_available_rounded,
                size: 14,
                color:
                    _isOverdue() ? AppColors.danger : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'استحقاق: ${_formatDate(debt.dueDate!)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _isOverdue()
                        ? AppColors.danger
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: _isOverdue()
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (onPayTap != null && debt.remainingAmount > 0)
              InkWell(
                onTap: onPayTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.success, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.payment_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'دفع',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (onReminderTap != null && debt.customerPhone != null) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: onReminderTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    size: 16,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}

class _AmountInfo extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isBold;

  const _AmountInfo({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          Formatters.formatCurrency(amount),
          style: AppTextStyles.bodyLarge.copyWith(
            color: color,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            fontSize: isBold ? 18 : 16,
          ),
        ),
      ],
    );
  }
}
