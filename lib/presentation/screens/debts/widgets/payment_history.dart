import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/debt_payment.dart';

class PaymentHistory extends StatefulWidget {
  final String debtId;
  final List<DebtPayment> payments;

  const PaymentHistory({
    super.key,
    required this.debtId,
    required this.payments,
  });

  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.payments.isEmpty) {
      return _buildEmptyState();
    }

    final sortedPayments = List.from(widget.payments)
      ..sort((a, b) {
        try {
          final aDate = DateTime.parse(a.paymentDate ?? '');
          final bDate = DateTime.parse(b.paymentDate ?? '');
          return bDate.compareTo(aDate);
        } catch (e) {
          return 0;
        }
      });

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: sortedPayments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final payment = sortedPayments[index];
          final delay = index * 100;
          return _buildPaymentCard(payment, delay);
        },
      ),
    );
  }

  Widget _buildPaymentCard(DebtPayment payment, int delay) {
    final paymentMethod = payment.paymentMethod ?? 'نقدي';
    final methodColor = _getPaymentMethodColor(paymentMethod);
    final methodIcon = _getPaymentMethodIcon(paymentMethod);

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            (delay / 1200).clamp(0.0, 1.0),
            ((delay + 400) / 1200).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              (delay / 1200).clamp(0.0, 1.0),
              ((delay + 400) / 1200).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showPaymentDetails(payment);
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.success,
                        AppColors.success.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'دفعة #${_getPaymentId(payment)}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(payment.paymentDate ?? ''),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.formatCurrency(payment.amount ?? 0.0),
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            'ريال',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: methodColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              methodIcon,
                              color: methodColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'طريقة الدفع',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: methodColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: methodColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              paymentMethod,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: methodColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (payment.notes?.isNotEmpty == true) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.notes_rounded,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  payment.notes!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.textHint.withOpacity(0.1),
                  AppColors.textHint.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 64,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد دفعات بعد',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم عرض تاريخ الدفعات هنا',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'نقدي':
        return Icons.money_rounded;
      case 'حوالة':
        return Icons.receipt_rounded;
      case 'محفظة':
        return Icons.account_balance_wallet_rounded;
      case 'شيك':
        return Icons.description_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Color _getPaymentMethodColor(String method) {
    switch (method) {
      case 'نقدي':
        return AppColors.success;
      case 'حوالة':
        return AppColors.primary;
      case 'محفظة':
        return AppColors.accent;
      case 'شيك':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getPaymentId(DebtPayment payment) {
    if (payment.id == null) return 'N/A';
    final idString = payment.id.toString();
    return idString.length > 8
        ? idString.substring(idString.length - 8)
        : idString;
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _showPaymentDetails(DebtPayment payment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.success, AppColors.success],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تفاصيل الدفعة',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('المبلغ',
                '${Formatters.formatCurrency(payment.amount ?? 0.0)} ريال'),
            _buildDetailRow('التاريخ', _formatDate(payment.paymentDate ?? '')),
            _buildDetailRow('طريقة الدفع', payment.paymentMethod ?? 'نقدي'),
            if (payment.notes?.isNotEmpty == true)
              _buildDetailRow('ملاحظات', payment.notes!),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
