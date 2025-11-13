import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/debt.dart';
import '../../blocs/debts/debts_bloc.dart';
import '../../blocs/debts/debts_event.dart';
import '../../blocs/debts/debts_state.dart';
import '../../blocs/debts/payment_bloc.dart';
import '../../blocs/debts/payment_event.dart';
import '../../blocs/debts/payment_state.dart';
import '../../widgets/common/confirm_dialog.dart';
import './widgets/payment_history.dart';
import './widgets/debt_timeline.dart';
import './debt_payment_screen.dart';

/// شاشة تفاصيل الدين - تصميم راقي هادئ
class DebtDetailsScreen extends StatefulWidget {
  final Debt debt;

  const DebtDetailsScreen({super.key, required this.debt});

  @override
  State<DebtDetailsScreen> createState() => _DebtDetailsScreenState();
}

class _DebtDetailsScreenState extends State<DebtDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    if (widget.debt.id != null) {
      context.read<PaymentBloc>().add(LoadPaymentsByDebtEvent(widget.debt.id!));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.debt.status) {
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
    if (widget.debt.dueDate == null) return false;
    final dueDate = DateTime.parse(widget.debt.dueDate!);
    return dueDate.isBefore(DateTime.now()) && widget.debt.remainingAmount > 0;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            _buildGradientBackground(statusColor),
            NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  _buildAppBar(context, statusColor),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildSummaryCard(statusColor),
                        _buildTabBar(),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildDetailsTab(),
                  _buildPaymentsTab(),
                  _buildTimelineTab(),
                ],
              ),
            ),
            _buildPayButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground(Color statusColor) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withOpacity(0.08),
            AppColors.danger.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Color statusColor) {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.surface.withOpacity(opacity),
      elevation: opacity * 4,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.share_rounded, size: 20),
          ),
          onPressed: () => _shareDebt(),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete_rounded,
              size: 20,
              color: AppColors.danger,
            ),
          ),
          onPressed: () => _deleteDebt(context),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.surface, AppColors.surface.withOpacity(0.95)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'debt-icon-${widget.debt.id}',
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                statusColor,
                                statusColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.debt.personName,
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.debt.transactionType ?? 'دين عام',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Color statusColor) {
    final progress = widget.debt.originalAmount > 0
        ? (widget.debt.paidAmount / widget.debt.originalAmount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [statusColor, statusColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'المبلغ المتبقي',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  widget.debt.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.debt.remainingAmount.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
              const SizedBox(width: 12),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'ريال',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المدفوع: ${Formatters.formatCurrency(widget.debt.paidAmount)}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.1)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.danger, AppColors.warning],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodyMedium,
        tabs: const [
          Tab(text: 'التفاصيل'),
          Tab(text: 'الدفعات'),
          Tab(text: 'الخط الزمني'),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(),
          const SizedBox(height: 16),
          _buildAmountsSection(),
          const SizedBox(height: 16),
          _buildDatesSection(),
          if (widget.debt.notes != null && widget.debt.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildNotesSection(),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPaymentsTab() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        if (state is PaymentLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PaymentError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppColors.danger,
                ),
                const SizedBox(height: 16),
                Text(state.message),
              ],
            ),
          );
        }

        if (state is PaymentsLoaded) {
          return PaymentHistory(
            payments: state.payments,
            debtId: widget.debt.id!.toString(), // تحويل int إلى String
          );
        }

        return const Center(child: Text('لا توجد دفعات'));
      },
    );
  }

  Widget _buildTimelineTab() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        if (state is PaymentsLoaded) {
          return DebtTimeline(
            debt: widget.debt,
            // payments: state.payments, // DebtTimeline لا يحتاج payments
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildInfoSection() {
    return _buildSection(
      title: 'معلومات العميل',
      icon: Icons.person_rounded,
      children: [
        _buildInfoRow('الاسم', widget.debt.personName, Icons.person_outline),
        if (widget.debt.customerPhone != null)
          _buildInfoRow(
            'الهاتف',
            widget.debt.customerPhone!,
            Icons.phone_rounded,
          ),
        _buildInfoRow('النوع', widget.debt.personType, Icons.category_rounded),
      ],
    );
  }

  Widget _buildAmountsSection() {
    return _buildSection(
      title: 'المبالغ',
      icon: Icons.account_balance_wallet_rounded,
      children: [
        _buildInfoRow(
          'المبلغ الأصلي',
          Formatters.formatCurrency(widget.debt.originalAmount),
          Icons.attach_money_rounded,
        ),
        _buildInfoRow(
          'المبلغ المدفوع',
          Formatters.formatCurrency(widget.debt.paidAmount),
          Icons.payment_rounded,
          valueColor: AppColors.success,
        ),
        _buildInfoRow(
          'المبلغ المتبقي',
          Formatters.formatCurrency(widget.debt.remainingAmount),
          Icons.trending_up_rounded,
          valueColor: AppColors.danger,
        ),
      ],
    );
  }

  Widget _buildDatesSection() {
    return _buildSection(
      title: 'التواريخ',
      icon: Icons.calendar_today_rounded,
      children: [
        _buildInfoRow(
          'تاريخ الدين',
          _formatDate(widget.debt.date),
          Icons.event_rounded,
        ),
        if (widget.debt.dueDate != null)
          _buildInfoRow(
            'تاريخ الاستحقاق',
            _formatDate(widget.debt.dueDate!),
            Icons.event_available_rounded,
            valueColor: _isOverdue() ? AppColors.danger : null,
          ),
        if (widget.debt.lastPaymentDate != null)
          _buildInfoRow(
            'آخر دفعة',
            _formatDate(widget.debt.lastPaymentDate!),
            Icons.history_rounded,
          ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_rounded, size: 20, color: AppColors.info),
              const SizedBox(width: 8),
              Text(
                'ملاحظات',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.debt.notes!,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.danger.withOpacity(0.1),
                      AppColors.warning.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.danger),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
    if (widget.debt.remainingAmount <= 0) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.success, AppColors.primary],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToPayment(context),
            borderRadius: BorderRadius.circular(16),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'تسجيل دفعة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPayment(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DebtPaymentScreen(debt: widget.debt),
      ),
    );

    if (result == true && mounted) {
      context.read<PaymentBloc>().add(LoadPaymentsByDebtEvent(widget.debt.id!));
    }
  }

  void _shareDebt() {
    // Implement share functionality
  }

  void _deleteDebt(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'حذف الدين',
      message: 'هل أنت متأكد من حذف هذا الدين؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      isDangerous: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<DebtsBloc>().add(DeleteDebtEvent(widget.debt.id!));
      Navigator.pop(context, true);
    }
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
        'ديسمبر',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
