import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/customer.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/confirm_dialog.dart';
import 'widgets/customer_debt_card.dart';
import 'widgets/customer_history_tab.dart';
import 'widgets/customer_rating_widget.dart';
import 'edit_customer_screen.dart';

/// شاشة تفاصيل العميل الكاملة
class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailsScreen({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.customer.name,
            style: AppTextStyles.headlineMedium,
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditCustomerScreen(customer: widget.customer),
                  ),
                );
              },
              tooltip: 'تعديل',
            ),
            IconButton(
              icon: Icon(widget.customer.isBlocked ? Icons.lock_open : Icons.lock),
              onPressed: () => _toggleBlockStatus(context),
              tooltip: widget.customer.isBlocked ? 'إلغاء الحظر' : 'حظر العميل',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'التفاصيل', icon: Icon(Icons.info_outline, size: 20)),
              Tab(text: 'الديون', icon: Icon(Icons.account_balance_wallet, size: 20)),
              Tab(text: 'السجل', icon: Icon(Icons.history, size: 20)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDetailsTab(),
            _buildDebtsTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  /// تبويب التفاصيل الأساسية
  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          widget.customer.name.isNotEmpty
                              ? widget.customer.name[0].toUpperCase()
                              : '؟',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.customer.name,
                              style: AppTextStyles.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            _buildStatusChip(widget.customer),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.phone,
                    'رقم الهاتف',
                    widget.customer.phone ?? 'غير محدد',
                  ),
                  const SizedBox(height: 12),
                  if (widget.customer.nickname != null && widget.customer.nickname!.isNotEmpty)
                    _buildInfoRow(
                      Icons.badge,
                      'الكنية',
                      widget.customer.nickname!,
                    ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.category,
                    'نوع العميل',
                    widget.customer.customerType,
                  ),
                  if (widget.customer.notes != null &&
                      widget.customer.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.notes,
                      'ملاحظات',
                      widget.customer.notes!,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spaceM),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الإحصائيات المالية',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: AppDimensions.spaceM),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'إجمالي المشتريات',
                          '${widget.customer.totalPurchases.toStringAsFixed(2)} ريال',
                          Icons.shopping_cart,
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'الدين الحالي',
                          '${widget.customer.currentDebt.toStringAsFixed(2)} ريال',
                          Icons.account_balance_wallet,
                          widget.customer.currentDebt > 0
                              ? AppColors.danger
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    'حد الائتمان',
                    '${widget.customer.creditLimit.toStringAsFixed(2)} ريال',
                    Icons.credit_card,
                    AppColors.info,
                  ),
                  if (widget.customer.creditLimit > 0) ...[
                    const SizedBox(height: 12),
                    _buildCreditUtilization(widget.customer),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spaceM),

          CustomerRatingWidget(
            initialRating: 0,
            onRatingChanged: (rating) {
            },
            readOnly: false,
            showLabel: true,
          ),

          const SizedBox(height: AppDimensions.spaceM),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إجراءات سريعة',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: AppDimensions.spaceM),
                  AppButton.secondary(
                    text: 'إضافة عملية بيع',
                    icon: Icons.add_shopping_cart,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/add-sale',
                        arguments: {'customerId': widget.customer.id},
                      );
                    },
                    fullWidth: true,
                  ),
                  const SizedBox(height: 12),
                  AppButton.secondary(
                    text: 'سداد دين',
                    icon: Icons.payment,
                    onPressed: widget.customer.currentDebt > 0
                        ? () {
                            Navigator.pushNamed(
                              context,
                              '/debt-payment',
                              arguments: {
                                'customerId': widget.customer.id,
                                'customerName': widget.customer.name,
                                'remainingAmount': widget.customer.currentDebt,
                              },
                            );
                          }
                        : null,
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// تبويب الديون
  Widget _buildDebtsTab() {
    // TODO: Implement debts list for customer
    return Center(
      child: Text(
        'قريباً: عرض قائمة الديون الخاصة بالعميل',
        style: AppTextStyles.bodyMedium,
      ),
    );
  }

  /// تبويب السجل
  Widget _buildHistoryTab() {
    return const CustomerHistoryTab(
      sales: [],
      payments: [],
      isLoading: false,
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

  void _toggleBlockStatus(BuildContext context) async {
    final action = widget.customer.isBlocked ? 'إلغاء حظر' : 'حظر';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: '$action العميل',
        message: 'هل أنت متأكد من $action العميل "${widget.customer.name}"؟',
        confirmText: action,
        cancelText: 'إلغاء',
        isDestructive: !widget.customer.isBlocked,
      ),
    );

    if (confirmed == true && widget.customer.id != null) {
      if (context.mounted) {
        context.read<CustomersBloc>().add(
          BlockCustomerEvent(
            widget.customer.id!,
            !widget.customer.isBlocked,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }
}
