import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/debts/debts_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_date_picker.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/snackbar_widget.dart';
import '../../widgets/common/number_pad.dart';

/// شاشة دفع دين
/// 
/// تسمح بتسجيل دفعة كاملة أو جزئية لدين
class DebtPaymentScreen extends StatefulWidget {
  final String debtId;
  final double remainingAmount;

  const DebtPaymentScreen({
    super.key,
    required this.debtId,
    required this.remainingAmount,
  });

  @override
  State<DebtPaymentScreen> createState() => _DebtPaymentScreenState();
}

class _DebtPaymentScreenState extends State<DebtPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _paymentDate;
  String _paymentMethod = 'نقدي';
  bool _isFullPayment = true;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.remainingAmount.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _setFullPayment() {
    setState(() {
      _isFullPayment = true;
      _amountController.text = widget.remainingAmount.toString();
    });
  }

  void _setPartialPayment() {
    setState(() {
      _isFullPayment = false;
      _amountController.clear();
    });
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text);

    if (amount > widget.remainingAmount) {
      SnackbarWidget.showError(
        context: context,
        message: 'المبلغ المدفوع أكبر من المبلغ المتبقي',
      );
      return;
    }

    final confirm = await ConfirmDialog.show(
      context: context,
      title: 'تأكيد الدفع',
      message: 'هل أنت متأكد من تسجيل دفعة بمبلغ ${amount.toStringAsFixed(2)} ريال؟',
      confirmText: 'نعم، تسجيل الدفع',
      cancelText: 'إلغاء',
    );

    if (confirm != true || !mounted) return;

    context.read<DebtsBloc>().add(
      PayDebt(
        debtId: widget.debtId,
        amount: amount,
        paymentMethod: _paymentMethod,
        paymentDate: _paymentDate ?? DateTime.now(),
        notes: _notesController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل دفعة'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: BlocConsumer<DebtsBloc, DebtsState>(
        listener: (context, state) {
          if (state is DebtPaymentAdded) {
            SnackbarWidget.showSuccess(
              context: context,
              message: 'تم تسجيل الدفعة بنجاح',
            );
            Navigator.of(context).pop(true);
          } else if (state is DebtsError) {
            SnackbarWidget.showError(
              context: context,
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is DebtsLoading;
          final amount = double.tryParse(_amountController.text) ?? 0;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // عرض المبلغ المتبقي
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.danger, AppColors.danger.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'المبلغ المتبقي',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textOnDark.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.remainingAmount.toStringAsFixed(2)} ريال',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.textOnDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // اختيار نوع الدفع
                Row(
                  children: [
                    Expanded(
                      child: _buildPaymentTypeCard(
                        title: 'دفع كامل',
                        subtitle: '${widget.remainingAmount.toStringAsFixed(0)} ريال',
                        icon: Icons.payment,
                        isSelected: _isFullPayment,
                        onTap: _setFullPayment,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPaymentTypeCard(
                        title: 'دفع جزئي',
                        subtitle: 'أدخل المبلغ',
                        icon: Icons.payments,
                        isSelected: !_isFullPayment,
                        onTap: _setPartialPayment,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // المبلغ المدفوع
                _buildSectionTitle('المبلغ المدفوع'),
                const SizedBox(height: 16),

                AppTextField.currency(
                  controller: _amountController,
                  label: 'المبلغ',
                  hint: 'أدخل المبلغ المدفوع',
                  enabled: !_isFullPayment,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'يرجى إدخال المبلغ';
                    }
                    final amount = double.tryParse(value!);
                    if (amount == null || amount <= 0) {
                      return 'يرجى إدخال مبلغ صحيح';
                    }
                    if (amount > widget.remainingAmount) {
                      return 'المبلغ أكبر من المتبقي';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // طريقة الدفع
                _buildSectionTitle('طريقة الدفع'),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildPaymentMethodChip('نقدي', Icons.money, AppColors.success),
                    _buildPaymentMethodChip('شيك', Icons.receipt, AppColors.info),
                    _buildPaymentMethodChip('تحويل بنكي', Icons.account_balance, AppColors.primary),
                  ],
                ),
                const SizedBox(height: 24),

                // تاريخ الدفع
                _buildSectionTitle('تاريخ الدفع'),
                const SizedBox(height: 16),

                AppDatePicker(
                  label: 'التاريخ',
                  selectedDate: _paymentDate,
                  onDateSelected: (date) {
                    setState(() {
                      _paymentDate = date;
                    });
                  },
                  lastDate: DateTime.now(),
                ),
                const SizedBox(height: 24),

                // ملاحظات
                _buildSectionTitle('ملاحظات'),
                const SizedBox(height: 16),

                AppTextField.multiline(
                  controller: _notesController,
                  label: 'ملاحظات',
                  hint: 'أضف أي ملاحظات على الدفعة',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // ملخص الدفع
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('المبلغ المدفوع', '${amount.toStringAsFixed(2)} ريال'),
                      const Divider(height: 16),
                      _buildSummaryRow(
                        'المتبقي بعد الدفع',
                        '${(widget.remainingAmount - amount).toStringAsFixed(2)} ريال',
                        valueColor: AppColors.danger,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // أزرار الإجراءات
                AppButton.primary(
                  text: 'تسجيل الدفعة',
                  icon: Icons.check_circle,
                  fullWidth: true,
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _submitPayment,
                ),
                const SizedBox(height: 12),
                AppButton.secondary(
                  text: 'إلغاء',
                  fullWidth: true,
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodChip(String label, IconData icon, Color color) {
    final isSelected = _paymentMethod == label;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: isSelected ? AppColors.textOnDark : color),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _paymentMethod = label;
          });
        }
      },
      selectedColor: color,
      backgroundColor: AppColors.surface,
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: isSelected ? AppColors.textOnDark : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
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
          style: AppTextStyles.bodyLarge.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
