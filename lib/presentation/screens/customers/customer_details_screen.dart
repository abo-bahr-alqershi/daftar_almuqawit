import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/customer.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../widgets/common/app_button.dart';
import 'edit_customer_screen.dart';

/// شاشة تفاصيل العميل
class CustomerDetailsScreen extends StatelessWidget {
  final Customer customer;

  const CustomerDetailsScreen({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          customer.name,
          style: AppTextStyles.h2.copyWith(color: AppColors.textOnDark),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textOnDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditCustomerScreen(customer: customer),
                ),
              );
            },
            tooltip: 'تعديل',
          ),
          IconButton(
            icon: Icon(customer.isBlocked ? Icons.lock_open : Icons.lock),
            onPressed: () => _toggleBlockStatus(context),
            tooltip: customer.isBlocked ? 'إلغاء الحظر' : 'حظر العميل',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // معلومات العميل الأساسية
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            customer.name.isNotEmpty
                                ? customer.name[0].toUpperCase()
                                : '؟',
                            style: AppTextStyles.h1.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: AppTextStyles.h2,
                              ),
                              const SizedBox(height: 4),
                              _buildStatusChip(customer),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.phone,
                      'رقم الهاتف',
                      customer.phone ?? 'غير محدد',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.category,
                      'نوع العميل',
                      customer.customerType,
                    ),
                    if (customer.notes != null &&
                        customer.notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.notes,
                        'ملاحظات',
                        customer.notes!,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // الإحصائيات المالية
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الإحصائيات المالية',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'إجمالي المشتريات',
                            '${customer.totalPurchases.toStringAsFixed(2)} ريال',
                            Icons.shopping_cart,
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'الدين الحالي',
                            '${customer.currentDebt.toStringAsFixed(2)} ريال',
                            Icons.account_balance_wallet,
                            customer.currentDebt > 0
                                ? AppColors.danger
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      'حد الائتمان',
                      '${customer.creditLimit.toStringAsFixed(2)} ريال',
                      Icons.credit_card,
                      AppColors.info,
                    ),
                    if (customer.creditLimit > 0) ...[
                      const SizedBox(height: 12),
                      _buildCreditUtilization(customer),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // الإجراءات السريعة
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إجراءات سريعة',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 16),
                    AppButton.secondary(
                      text: 'إضافة عملية بيع',
                      icon: Icons.add_shopping_cart,
                      onPressed: () {
                        // TODO: Navigate to add sale screen
                      },
                      fullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    AppButton.secondary(
                      text: 'سداد دين',
                      icon: Icons.payment,
                      onPressed: () {
                        // TODO: Navigate to payment screen
                      },
                      fullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    AppButton.secondary(
                      text: 'عرض سجل المعاملات',
                      icon: Icons.history,
                      onPressed: () {
                        // TODO: Navigate to transactions history
                      },
                      fullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(Customer customer) {
    Color backgroundColor;
    Color textColor;
    String status = customer.getCustomerStatus();

    switch (status) {
      case 'محظور':
        backgroundColor = AppColors.danger;
        textColor = AppColors.textOnDark;
        break;
      case 'تجاوز الحد':
        backgroundColor = AppColors.warning;
        textColor = AppColors.textPrimary;
        break;
      case 'عليه دين':
        backgroundColor = AppColors.info;
        textColor = AppColors.textOnDark;
        break;
      default:
        backgroundColor = AppColors.success;
        textColor = AppColors.textOnDark;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditUtilization(Customer customer) {
    final utilization = customer.creditUtilizationPercentage;
    Color progressColor;

    if (utilization >= 100) {
      progressColor = AppColors.danger;
    } else if (utilization >= 80) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.success;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'استخدام الائتمان',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${utilization.toStringAsFixed(1)}%',
              style: AppTextStyles.bodyMedium.copyWith(
                color: progressColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: utilization / 100,
            backgroundColor: AppColors.disabled.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  void _toggleBlockStatus(BuildContext context) {
    final action = customer.isBlocked ? 'إلغاء حظر' : 'حظر';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد $action العميل'),
        content: Text('هل أنت متأكد من $action هذا العميل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CustomersBloc>().add(
                    BlockCustomerEvent(
                      customer.id!,
                      !customer.isBlocked,
                    ),
                  );
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor:
                  customer.isBlocked ? AppColors.success : AppColors.danger,
            ),
            child: Text(action),
          ),
        ],
      ),
    );
  }
}
