import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../domain/entities/sale.dart';
import '../../../../domain/entities/debt_payment.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart' as app_date;

/// تاب عرض سجل نشاط العميل (مبيعات ودفعات)
class CustomerHistoryTab extends StatelessWidget {
  final List<Sale>? sales;
  final List<DebtPayment>? payments;
  final bool isLoading;
  final String? errorMessage;

  const CustomerHistoryTab({
    super.key,
    this.sales,
    this.payments,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.danger,
            ),
            const SizedBox(height: AppDimensions.spaceM),
            Text(
              errorMessage!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.danger,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final hasData = (sales?.isNotEmpty ?? false) || (payments?.isNotEmpty ?? false);

    if (!hasData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppDimensions.spaceM),
            Text(
              'لا يوجد سجل نشاط',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              'لم يتم تسجيل أي عمليات بعد',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    // دمج المبيعات والدفعات في قائمة واحدة مرتبة حسب التاريخ
    final allItems = <_HistoryItem>[];

    if (sales != null) {
      for (var sale in sales!) {
        allItems.add(_HistoryItem(
          type: _HistoryItemType.sale,
          date: sale.date,
          sale: sale,
        ));
      }
    }

    if (payments != null) {
      for (var payment in payments!) {
        allItems.add(_HistoryItem(
          type: _HistoryItemType.payment,
          date: payment.paymentDate,
          payment: payment,
        ));
      }
    }

    // ترتيب حسب التاريخ (الأحدث أولاً)
    allItems.sort((a, b) => b.date.compareTo(a.date));

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: allItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.spaceM),
      itemBuilder: (context, index) {
        final item = allItems[index];
        
        if (item.type == _HistoryItemType.sale) {
          return _SaleHistoryCard(sale: item.sale!);
        } else {
          return _PaymentHistoryCard(payment: item.payment!);
        }
      },
    );
  }
}

/// بطاقة عرض عملية بيع
class _SaleHistoryCard extends StatelessWidget {
  final Sale sale;

  const _SaleHistoryCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.sales.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصف الأول: الأيقونة والعنوان
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.sales.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(
                  Icons.shopping_bag,
                  color: AppColors.sales,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عملية بيع',
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app_date.DateUtils.formatDate(sale.date),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyUtils.format(sale.totalAmount),
                style: AppTextStyles.currencyMedium.copyWith(
                  color: AppColors.sales,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),
          // التفاصيل
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingS),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  label: 'الكمية',
                  value: sale.quantity.toString(),
                  icon: Icons.inventory_2,
                ),
                const Divider(height: 12),
                _buildDetailRow(
                  label: 'السعر',
                  value: CurrencyUtils.format(sale.unitPrice),
                  icon: Icons.attach_money,
                ),
                if (sale.discount > 0) ...[
                  const Divider(height: 12),
                  _buildDetailRow(
                    label: 'الخصم',
                    value: CurrencyUtils.format(sale.discount),
                    icon: Icons.discount,
                  ),
                ],
              ],
            ),
          ),
          // الملاحظات
          if (sale.notes != null && sale.notes!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spaceS),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes, size: 14, color: AppColors.info),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      sale.notes!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
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
}

/// بطاقة عرض عملية دفع
class _PaymentHistoryCard extends StatelessWidget {
  final DebtPayment payment;

  const _PaymentHistoryCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.success.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصف الأول: الأيقونة والعنوان
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(
                  Icons.payment,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تسديد دفعة',
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app_date.DateUtils.formatDate(payment.paymentDate),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyUtils.format(payment.amount),
                style: AppTextStyles.currencyMedium.copyWith(
                  color: AppColors.success,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),
          // التفاصيل
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingS),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  label: 'طريقة الدفع',
                  value: payment.paymentMethod,
                  icon: Icons.credit_card,
                ),
              ],
            ),
          ),
          // الملاحظات
          if (payment.notes != null && payment.notes!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spaceS),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes, size: 14, color: AppColors.success),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      payment.notes!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
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
}

/// نوع عنصر السجل
enum _HistoryItemType { sale, payment }

/// عنصر في سجل النشاط
class _HistoryItem {
  final _HistoryItemType type;
  final String date;
  final Sale? sale;
  final DebtPayment? payment;

  _HistoryItem({
    required this.type,
    required this.date,
    this.sale,
    this.payment,
  });
}
