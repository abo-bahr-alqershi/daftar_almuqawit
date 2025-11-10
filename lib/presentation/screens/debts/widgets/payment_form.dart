import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/app_date_picker.dart';

/// نموذج الدفع
/// 
/// يوفر واجهة لتسجيل دفعة جديدة على دين
class PaymentForm extends StatefulWidget {
  final double remainingAmount;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;

  const PaymentForm({
    super.key,
    required this.remainingAmount,
    this.onSubmit,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  State<PaymentForm> createState() => PaymentFormState();
}

class PaymentFormState extends State<PaymentForm> {
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

  void setFullPayment() {
    setState(() {
      _isFullPayment = true;
      _amountController.text = widget.remainingAmount.toString();
    });
  }

  void setPartialPayment() {
    setState(() {
      _isFullPayment = false;
      _amountController.clear();
    });
  }

  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  Map<String, dynamic> getFormData() {
    return {
      'amount': double.parse(_amountController.text),
      'paymentMethod': _paymentMethod,
      'paymentDate': _paymentDate ?? DateTime.now(),
      'notes': _notesController.text,
      'isFullPayment': _isFullPayment,
    };
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountController.text) ?? 0;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          Row(
            children: [
              Expanded(
                child: _buildPaymentTypeCard(
                  title: 'دفع كامل',
                  subtitle: '${widget.remainingAmount.toStringAsFixed(0)} ريال',
                  icon: Icons.payment,
                  isSelected: _isFullPayment,
                  onTap: setFullPayment,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentTypeCard(
                  title: 'دفع جزئي',
                  subtitle: 'أدخل المبلغ',
                  icon: Icons.payments,
                  isSelected: !_isFullPayment,
                  onTap: setPartialPayment,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('المبلغ المدفوع'),
          const SizedBox(height: 16),

          AppTextField.currency(
            controller: _amountController,
            label: 'المبلغ',
            hint: 'أدخل المبلغ المدفوع',
            readOnly: _isFullPayment,
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

          _buildSectionTitle('ملاحظات'),
          const SizedBox(height: 16),

          AppTextField.multiline(
            controller: _notesController,
            label: 'ملاحظات',
            hint: 'أضف أي ملاحظات على الدفعة',
            maxLines: 3,
          ),
          const SizedBox(height: 24),

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

          if (widget.onSubmit != null && widget.onCancel != null)
            Column(
              children: [
                AppButton.primary(
                  text: 'تسجيل الدفعة',
                  icon: Icons.check_circle,
                  fullWidth: true,
                  isLoading: widget.isLoading,
                  onPressed: widget.isLoading ? null : widget.onSubmit,
                ),
                const SizedBox(height: 12),
                AppButton.secondary(
                  text: 'إلغاء',
                  fullWidth: true,
                  onPressed: widget.isLoading ? null : widget.onCancel,
                ),
              ],
            ),
        ],
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
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
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
