import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/debt.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/app_date_picker.dart';
import '../../../widgets/common/app_dropdown.dart';

/// نموذج إضافة أو تعديل دين
/// 
/// يوفر واجهة موحدة لإدخال بيانات الدين
class DebtForm extends StatefulWidget {
  final Debt? debt;
  final String? selectedCustomerId;
  final Function(String?) onCustomerChanged;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;

  const DebtForm({
    super.key,
    this.debt,
    this.selectedCustomerId,
    required this.onCustomerChanged,
    this.onSubmit,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  State<DebtForm> createState() => DebtFormState();
}

class DebtFormState extends State<DebtForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  DateTime? _dueDate;
  String _debtType = 'بيع آجل';

  @override
  void initState() {
    super.initState();
    if (widget.debt != null) {
      _amountController.text = widget.debt!.originalAmount.toString();
      _notesController.text = widget.debt!.notes ?? '';
      _descriptionController.text = widget.debt!.description ?? '';
      _debtType = widget.debt!.transactionType;
      _selectedDate = DateTime.tryParse(widget.debt!.date);
      _dueDate = widget.debt!.dueDate != null 
          ? DateTime.tryParse(widget.debt!.dueDate!)
          : null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  Map<String, dynamic> getFormData() {
    return {
      'amount': double.parse(_amountController.text),
      'description': _descriptionController.text,
      'notes': _notesController.text,
      'debtType': _debtType,
      'date': _selectedDate ?? DateTime.now(),
      'dueDate': _dueDate,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('معلومات الدين'),
          const SizedBox(height: 16),

          // نوع الدين
          AppDropdownField<String>(
            label: 'نوع الدين',
            hint: 'اختر نوع الدين',
            value: _debtType,
            items: const [
              DropdownMenuItem(value: 'بيع آجل', child: Text('بيع آجل')),
              DropdownMenuItem(value: 'قرض', child: Text('قرض')),
              DropdownMenuItem(value: 'أخرى', child: Text('أخرى')),
            ],
            onChanged: (value) {
              setState(() {
                _debtType = value!;
              });
            },
            prefixIcon: Icons.category,
          ),
          const SizedBox(height: 16),

          // المبلغ
          AppTextField.currency(
            controller: _amountController,
            label: 'مبلغ الدين',
            hint: 'أدخل المبلغ',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'يرجى إدخال المبلغ';
              }
              final amount = double.tryParse(value!);
              if (amount == null || amount <= 0) {
                return 'يرجى إدخال مبلغ صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // وصف الدين
          AppTextField(
            controller: _descriptionController,
            label: 'وصف الدين',
            hint: 'مثال: دين بيع قات - 20 كيس',
            prefixIcon: Icons.description,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'يرجى إدخال وصف الدين';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // قسم التواريخ
          _buildSectionTitle('التواريخ'),
          const SizedBox(height: 16),

          AppDatePicker(
            label: 'تاريخ الدين',
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            required: true,
          ),
          const SizedBox(height: 16),

          AppDatePicker(
            label: 'تاريخ الاستحقاق',
            hint: 'اختر تاريخ الاستحقاق (اختياري)',
            selectedDate: _dueDate,
            onDateSelected: (date) {
              setState(() {
                _dueDate = date;
              });
            },
            prefixIcon: Icons.event_available,
            firstDate: _selectedDate ?? DateTime.now(),
          ),
          const SizedBox(height: 24),

          // قسم الملاحظات
          _buildSectionTitle('ملاحظات إضافية'),
          const SizedBox(height: 16),

          AppTextField.multiline(
            controller: _notesController,
            label: 'ملاحظات',
            hint: 'أضف أي ملاحظات أو تفاصيل إضافية',
            maxLines: 4,
          ),
          const SizedBox(height: 32),

          // معاينة المبلغ
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.danger, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي الدين',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_amountController.text.isEmpty ? "0" : _amountController.text} ريال',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // أزرار الإجراءات
          if (widget.onSubmit != null && widget.onCancel != null)
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    text: 'إلغاء',
                    onPressed: widget.isLoading ? null : widget.onCancel,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: AppButton.primary(
                    text: widget.debt == null ? 'حفظ الدين' : 'تحديث الدين',
                    icon: Icons.save,
                    isLoading: widget.isLoading,
                    onPressed: widget.isLoading ? null : widget.onSubmit,
                  ),
                ),
              ],
            ),
        ],
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
            color: AppColors.danger,
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
}
