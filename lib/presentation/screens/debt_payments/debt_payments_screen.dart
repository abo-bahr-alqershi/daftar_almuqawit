import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/debt_payment.dart';
import '../../blocs/debts/payment_bloc.dart';
import '../../blocs/debts/payment_event.dart';
import '../../blocs/debts/payment_state.dart';
import '../../widgets/common/confirm_dialog.dart';
import 'widgets/payment_list_item.dart';
import 'widgets/payment_form.dart';

/// شاشة دفعات الديون - تصميم راقي هادئ
class DebtPaymentsScreen extends StatefulWidget {
  final int? debtId;

  const DebtPaymentsScreen({super.key, this.debtId});

  @override
  State<DebtPaymentsScreen> createState() => _DebtPaymentsScreenState();
}

class _DebtPaymentsScreenState extends State<DebtPaymentsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  String _selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    if (widget.debtId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PaymentBloc>().add(
          LoadPaymentsByDebtEvent(widget.debtId!),
        );
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            _buildGradientBackground(),

            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildModernAppBar(topPadding),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      BlocConsumer<PaymentBloc, PaymentState>(
                        listener: (context, state) {
                          if (state is PaymentAdded ||
                              state is PaymentUpdated ||
                              state is PaymentDeleted) {
                            _showSuccessMessage(
                              state is PaymentAdded
                                  ? 'تم إضافة الدفعة بنجاح'
                                  : state is PaymentUpdated
                                  ? 'تم تعديل الدفعة بنجاح'
                                  : 'تم حذف الدفعة بنجاح',
                            );
                            if (widget.debtId != null) {
                              context.read<PaymentBloc>().add(
                                LoadPaymentsByDebtEvent(widget.debtId!),
                              );
                            }
                          } else if (state is PaymentError) {
                            _showErrorMessage(state.message);
                          }
                        },
                        builder: (context, state) {
                          if (state is PaymentLoading) {
                            return _buildShimmerStats();
                          }
                          if (state is PaymentsLoaded) {
                            final filteredPayments = _filterPayments(
                              state.payments,
                            );
                            return Column(
                              children: [
                                _buildStatsCard(filteredPayments),
                                const SizedBox(height: 32),
                                _buildSectionTitle(
                                  'قائمة الدفعات',
                                  Icons.receipt_long_rounded,
                                ),
                                const SizedBox(height: 16),
                                _buildFilterChips(),
                                const SizedBox(height: 16),
                                if (filteredPayments.isEmpty)
                                  _buildEmptyState()
                                else
                                  _buildPaymentsList(filteredPayments),
                                const SizedBox(height: 100),
                              ],
                            );
                          }
                          return _buildEmptyState();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            _buildFloatingActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() => Container(
    height: 400,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.success.withOpacity(0.08),
          AppColors.primary.withOpacity(0.05),
          Colors.transparent,
        ],
      ),
    ),
  );

  Widget _buildModernAppBar(double topPadding) {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.surface.withOpacity(opacity),
      elevation: opacity * 2,
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
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.success, AppColors.primary],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.payments_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'دفعات الدين',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'سجل المدفوعات',
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
      actions: [
        _buildIconButton(
          Icons.refresh_rounded,
          onPressed: () {
            HapticFeedback.lightImpact();
            if (widget.debtId != null) {
              context.read<PaymentBloc>().add(
                LoadPaymentsByDebtEvent(widget.debtId!),
              );
            }
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, {required VoidCallback onPressed}) =>
      IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
        onPressed: onPressed,
      );

  Widget _buildSectionTitle(String title, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.success.withOpacity(0.1),
                AppColors.primary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.success),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ],
    ),
  );

  Widget _buildStatsCard(List<DebtPayment> payments) {
    final totalAmount = payments.fold(
      0.0,
      (sum, payment) => sum + payment.amount,
    );
    final cashPayments = payments.where((p) => p.paymentMethod == 'نقد').length;
    final transferPayments = payments
        .where((p) => p.paymentMethod == 'تحويل')
        .length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.success, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _StatsBackgroundPainter()),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'إجمالي المدفوع',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${payments.length} دفعة',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.success,
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'مدفوع',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1200),
                        tween: Tween(begin: 0, end: totalAmount),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                value.toStringAsFixed(0),
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'ريال',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.payment_rounded,
                              size: 16,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'نقد: $cashPayments | تحويل: $transferPayments',
                              style: const TextStyle(
                                color: AppColors.info,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.payments_rounded,
                  label: 'نقد',
                  value: cashPayments.toDouble(),
                  color: AppColors.primary,
                  isCount: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.account_balance_rounded,
                  label: 'تحويل',
                  value: transferPayments.toDouble(),
                  color: AppColors.info,
                  isCount: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
    bool isCount = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0, end: value),
            curve: Curves.easeOutCubic,
            builder: (context, animValue, child) {
              return Text(
                isCount
                    ? animValue.toStringAsFixed(0)
                    : '${animValue.toStringAsFixed(0)} ر.ي',
                style: TextStyle(
                  fontSize: 17,
                  color: color,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.3,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['الكل', 'نقد', 'تحويل', 'حوالة'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilter = filter);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppColors.success, AppColors.primary],
                      )
                    : null,
                color: isSelected ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.success
                      : AppColors.border.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentsList(List<DebtPayment> payments) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: payments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return PaymentListItem(
          payment: payments[index],
          onTap: () {},
          onDelete: () => _deletePayment(payments[index]),
        );
      },
    );
  }

  Widget _buildShimmerStats() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    height: 200,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
    ),
    child: const Center(child: CircularProgressIndicator()),
  );

  Widget _buildEmptyState() => Container(
    padding: const EdgeInsets.all(40),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payments_rounded,
              size: 60,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'لا توجد دفعات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ بإضافة أول دفعة',
            style: TextStyle(fontSize: 14, color: AppColors.textHint),
          ),
        ],
      ),
    ),
  );

  Widget _buildFloatingActionButton(BuildContext context) => Positioned(
    bottom: 20,
    left: 20,
    child: FloatingActionButton.extended(
      onPressed: () => _showAddPaymentForm(),
      backgroundColor: AppColors.success,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'إضافة دفعة',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      elevation: 8,
    ),
  );

  List<DebtPayment> _filterPayments(List<DebtPayment> payments) {
    if (_selectedFilter == 'الكل') return payments;
    return payments.where((p) => p.paymentMethod == _selectedFilter).toList();
  }

  void _showAddPaymentForm() {
    if (widget.debtId == null) return;

    final formKey = GlobalKey<PaymentFormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: PaymentForm(
            key: formKey,
            onSubmit: () {
              if (formKey.currentState?.validate() ?? false) {
                final formData = formKey.currentState!.getFormData();
                final payment = DebtPayment(
                  debtId: widget.debtId!,
                  amount: formData['amount'],
                  paymentDate: formData['date'].toString().split(' ')[0],
                  paymentTime:
                      formData['time'] ??
                      '${TimeOfDay.now().hour}:${TimeOfDay.now().minute}',
                  paymentMethod: formData['paymentMethod'] ?? 'نقد',
                  notes: formData['notes'],
                );
                context.read<PaymentBloc>().add(AddPaymentEvent(payment));
                Navigator.pop(context);
              }
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Future<void> _deletePayment(DebtPayment payment) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'حذف الدفعة',
      message: 'هل أنت متأكد من حذف هذه الدفعة؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      isDangerous: true,
    );

    if (confirmed == true && payment.id != null) {
      context.read<PaymentBloc>().add(DeletePaymentEvent(payment.id!));
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _StatsBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = Colors.white.withOpacity(0.05);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 60, paint);

    paint.color = Colors.white.withOpacity(0.03);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 80, paint);

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 5; i++) {
      final y = size.height * (i + 1) / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width * 0.3, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
