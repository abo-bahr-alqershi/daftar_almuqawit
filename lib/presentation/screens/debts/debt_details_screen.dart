import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/debt.dart';
import '../../blocs/debts/debts_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import './widgets/payment_history.dart';
import './widgets/debt_timeline.dart';

/// شاشة تفاصيل الدين
/// 
/// تعرض تفاصيل كاملة عن دين معين مع سجل الدفعات
class DebtDetailsScreen extends StatefulWidget {
  final String debtId;

  const DebtDetailsScreen({
    super.key,
    required this.debtId,
  });

  @override
  State<DebtDetailsScreen> createState() => _DebtDetailsScreenState();
}

class _DebtDetailsScreenState extends State<DebtDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDebtDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDebtDetails() {
    context.read<DebtsBloc>().add(LoadDebtDetails(widget.debtId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الدين'),
        backgroundColor: AppColors.danger,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Show delete confirmation
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share debt details
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.textOnDark,
          tabs: const [
            Tab(text: 'التفاصيل'),
            Tab(text: 'الدفعات'),
            Tab(text: 'الخط الزمني'),
          ],
        ),
      ),
      body: BlocBuilder<DebtsBloc, DebtsState>(
        builder: (context, state) {
          if (state is DebtsLoading) {
            return const LoadingWidget(message: 'جاري تحميل التفاصيل...');
          }

          if (state is DebtsError) {
            return custom_error.ErrorWidget(
              message: state.message,
              onRetry: _loadDebtDetails,
            );
          }

          if (state is DebtDetailsLoaded) {
            final debt = state.debt;

            return Column(
              children: [
                // ملخص الدين
                _buildDebtSummaryCard(debt),
                
                // محتوى التبويبات
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDetailsTab(debt),
                      PaymentHistory(debtId: widget.debtId, payments: debt.payments),
                      DebtTimeline(debt: debt),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('لا توجد بيانات'));
        },
      ),
      bottomNavigationBar: BlocBuilder<DebtsBloc, DebtsState>(
        builder: (context, state) {
          if (state is DebtDetailsLoaded) {
            final debt = state.debt;
            if (debt.remainingAmount > 0) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/debt-payment',
                        arguments: {
                          'debtId': widget.debtId,
                          'remainingAmount': debt.remainingAmount,
                        },
                      );
                    },
                    icon: const Icon(Icons.payment),
                    label: Text('تسجيل دفعة (${debt.remainingAmount.toStringAsFixed(0)} ريال)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              );
            }
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDebtSummaryCard(Debt debt) {
    final progress = debt.totalAmount > 0 
        ? ((debt.totalAmount - debt.remainingAmount) / debt.totalAmount) 
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            debt.remainingAmount > 0 ? AppColors.danger : AppColors.success,
            debt.remainingAmount > 0 ? AppColors.danger.withOpacity(0.7) : AppColors.success.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (debt.remainingAmount > 0 ? AppColors.danger : AppColors.success).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إجمالي الدين',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnDark.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${debt.totalAmount.toStringAsFixed(0)} ريال',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.textOnDark,
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
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnDark.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${debt.remainingAmount.toStringAsFixed(0)} ريال',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.textOnDark.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.textOnDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% مدفوع',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textOnDark.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Debt debt) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          'معلومات العميل',
          [
            _buildInfoRow('اسم العميل', debt.customerName, Icons.person),
            _buildInfoRow('رقم الهاتف', debt.customerPhone ?? 'غير متوفر', Icons.phone),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'معلومات الدين',
          [
            _buildInfoRow('نوع الدين', debt.debtType, Icons.category),
            _buildInfoRow('وصف الدين', debt.description ?? 'غير متوفر', Icons.description),
            _buildInfoRow('تاريخ الدين', _formatDate(debt.createdAt), Icons.calendar_today),
            if (debt.dueDate != null)
              _buildInfoRow(
                'تاريخ الاستحقاق',
                _formatDate(debt.dueDate!),
                Icons.event_available,
                valueColor: _isOverdue(debt.dueDate!) ? AppColors.danger : null,
              ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'المبالغ',
          [
            _buildInfoRow('إجمالي الدين', '${debt.totalAmount.toStringAsFixed(2)} ريال', Icons.account_balance_wallet),
            _buildInfoRow('المبلغ المدفوع', '${debt.paidAmount.toStringAsFixed(2)} ريال', Icons.paid, valueColor: AppColors.success),
            _buildInfoRow('المبلغ المتبقي', '${debt.remainingAmount.toStringAsFixed(2)} ريال', Icons.money_off, valueColor: AppColors.danger),
          ],
        ),
        if (debt.notes?.isNotEmpty == true) ...[
          const SizedBox(height: 16),
          _buildInfoCard(
            'ملاحظات',
            [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  debt.notes!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }
}
