import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/debt.dart';
import '../../../domain/entities/debt_payment.dart';
import '../../blocs/debts/debts_bloc.dart';
import '../../blocs/debts/debts_event.dart';
import '../../blocs/debts/debts_state.dart';
import '../../widgets/common/confirm_dialog.dart';

/// شاشة تسجيل دفعة على دين - تصميم راقي هادئ
class DebtPaymentScreen extends StatefulWidget {
  final Debt debt;

  const DebtPaymentScreen({
    super.key,
    required this.debt,
  });

  @override
  State<DebtPaymentScreen> createState() => _DebtPaymentScreenState();
}

class _DebtPaymentScreenState extends State<DebtPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _paymentMethod = 'نقد';
  DateTime _paymentDate = DateTime.now();
  bool _isFullPayment = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.debt.remainingAmount.toString();
    _isFullPayment = true;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _paymentAmount => double.tryParse(_amountController.text) ?? 0;
  double get _remainingAfterPayment => (widget.debt.remainingAmount - _paymentAmount).clamp(0, double.infinity);

  void _onPaymentTypeChanged(bool? isFullPayment) {
    setState(() {
      _isFullPayment = isFullPayment ?? false;
      if (_isFullPayment) {
        _amountController.text = widget.debt.remainingAmount.toString();
      } else {
        _amountController.clear();
      }
    });
  }

  Future<void> _submitPayment() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_paymentAmount <= 0) {
      _showErrorMessage('يرجى إدخال مبلغ صحيح');
      return;
    }

    if (_paymentAmount > widget.debt.remainingAmount) {
      _showErrorMessage('المبلغ المدفوع أكبر من المبلغ المتبقي');
      return;
    }

    final confirmed = await ConfirmDialog.show(
      context,
      title: 'تأكيد الدفعة',
      message: 'هل أنت متأكد من تسجيل دفعة بمبلغ ${Formatters.formatCurrency(_paymentAmount)}؟',
      confirmText: 'تأكيد',
      cancelText: 'إلغاء',
    );

    if (confirmed != true || !mounted) return;

    final now = DateTime.now();
    final payment = DebtPayment(
      debtId: widget.debt.id!,
      amount: _paymentAmount,
      paymentDate: _paymentDate.toString().split(' ')[0],
      paymentTime: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      paymentMethod: _paymentMethod,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    context.read<DebtsBloc>().add(PayDebtEvent(widget.debt.id!, _paymentAmount));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            _buildGradientBackground(),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(
                  child: BlocConsumer<DebtsBloc, DebtsState>(
                    listener: (context, state) {
                      if (state is DebtOperationSuccess) {
                        _showSuccessMessage('تم تسجيل الدفعة بنجاح');
                        Navigator.of(context).pop(true);
                      } else if (state is DebtsError) {
                        _showErrorMessage(state.message);
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is DebtsLoading;

                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDebtSummaryCard(),
                              const SizedBox(height: 20),
                              _buildPaymentTypeSelector(),
                              const SizedBox(height: 20),
                              _buildAmountField(),
                              const SizedBox(height: 20),
                              _buildPaymentMethodSelector(),
                              const SizedBox(height: 20),
                              _buildDatePicker(),
                              const SizedBox(height: 20),
                              _buildNotesField(),
                              const SizedBox(height: 24),
                              _buildPaymentSummary(),
                              const SizedBox(height: 24),
                              _buildActionButtons(isLoading),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
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
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
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
                          Icons.payment_rounded,
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
                              'تسجيل دفعة',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'دفع دين ${widget.debt.personName}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

  Widget _buildDebtSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info.withOpacity(0.1),
            AppColors.info.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                'المبلغ الكلي',
                Formatters.formatCurrency(widget.debt.originalAmount),
                Icons.account_balance_wallet_rounded,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.border.withOpacity(0.3),
              ),
              _buildSummaryItem(
                'المتبقي',
                Formatters.formatCurrency(widget.debt.remainingAmount),
                Icons.trending_up_rounded,
                color: AppColors.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 24, color: color ?? AppColors.info),
          const SizedBox(height: 8),
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
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w900,
              color: color ?? AppColors.info,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع الدفعة',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PaymentTypeCard(
                label: 'دفع كامل',
                subtitle: Formatters.formatCurrency(widget.debt.remainingAmount),
                icon: Icons.check_circle_rounded,
                isSelected: _isFullPayment,
                onTap: () => _onPaymentTypeChanged(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PaymentTypeCard(
                label: 'دفع جزئي',
                subtitle: 'مبلغ مخصص',
                icon: Icons.pie_chart_rounded,
                isSelected: !_isFullPayment,
                onTap: () => _onPaymentTypeChanged(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      enabled: !_isFullPayment,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: 'المبلغ المدفوع *',
        hintText: 'أدخل المبلغ',
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.success.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.attach_money_rounded, size: 20),
        ),
        filled: true,
        fillColor: _isFullPayment ? AppColors.background.withOpacity(0.5) : AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.success, width: 2),
        ),
      ),
      validator: Validators.validateAmount,
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildPaymentMethodSelector() {
    final methods = [
      {'label': 'نقد', 'icon': Icons.money_rounded, 'color': AppColors.success},
      {'label': 'تحويل', 'icon': Icons.account_balance_rounded, 'color': AppColors.info},
      {'label': 'حوالة', 'icon': Icons.receipt_long_rounded, 'color': AppColors.warning},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة الدفع',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: methods.map((method) {
            final isSelected = _paymentMethod == method['label'];
            return InkWell(
              onTap: () => setState(() => _paymentMethod = method['label'] as String),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [method['color'] as Color, (method['color'] as Color).withOpacity(0.8)],
                        )
                      : null,
                  color: isSelected ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.border.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      method['icon'] as IconData,
                      size: 20,
                      color: isSelected ? Colors.white : (method['color'] as Color),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      method['label'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _paymentDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          locale: const Locale('ar'),
        );
        if (picked != null) {
          setState(() => _paymentDate = picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.info.withOpacity(0.1),
                    AppColors.info.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.info),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تاريخ الدفعة',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_paymentDate.year}/${_paymentDate.month.toString().padLeft(2, '0')}/${_paymentDate.day.toString().padLeft(2, '0')}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: 'ملاحظات (اختياري)',
        hintText: 'أضف ملاحظات على الدفعة',
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.textSecondary.withOpacity(0.1),
                  AppColors.textSecondary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.note_rounded, size: 20),
          ),
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.5), width: 2),
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.success.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.success, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.summarize_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'ملخص الدفعة',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('المبلغ المدفوع', Formatters.formatCurrency(_paymentAmount), AppColors.success),
          const Divider(height: 24),
          _buildSummaryRow('المتبقي بعد الدفع', Formatters.formatCurrency(_remainingAfterPayment), AppColors.danger),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w900,
            color: color,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.border.withOpacity(0.5)),
              ),
              elevation: 0,
            ),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.success, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'تأكيد الدفع',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
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

class _PaymentTypeCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentTypeCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.success, AppColors.primary],
                )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border.withOpacity(0.5),
            width: isSelected ? 0 : 1,
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
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : AppColors.success,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? Colors.white.withOpacity(0.9) : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
