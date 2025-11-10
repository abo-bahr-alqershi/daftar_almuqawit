import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/app_date_picker.dart';
import '../../../widgets/common/app_dropdown.dart';

/// نموذج إضافة أو تعديل مصروف
/// 
/// يوفر واجهة موحدة لإدخال بيانات المصروف
class ExpenseForm extends StatefulWidget {
  final dynamic expense;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;

  const ExpenseForm({
    super.key,
    this.expense,
    this.onSubmit,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  State<ExpenseForm> createState() => ExpenseFormState();
}

class ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'رواتب';
  DateTime? _selectedDate;

  final List<String> _categories = [
    'رواتب',
    'إيجار',
    'كهرباء',
    'ماء',
    'مواصلات',
    'صيانة',
    'مشتريات',
    'اتصالات',
    'تسويق',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _amountController.text = widget.expense.amount.toString();
      _descriptionController.text = widget.expense.description ?? '';
      _notesController.text = widget.expense.notes ?? '';
      _selectedCategory = widget.expense.category;
      _selectedDate = DateTime.tryParse(widget.expense.date);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  Map<String, dynamic> getFormData() {
    return {
      'amount': double.parse(_amountController.text),
      'category': _selectedCategory,
      'description': _descriptionController.text,
      'notes': _notesController.text,
      'date': _selectedDate ?? DateTime.now(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('معلومات المصروف'),
          const SizedBox(height: 16),

          AppDropdownField<String>(
            label: 'فئة المصروف',
            hint: 'اختر الفئة',
            value: _selectedCategory,
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Icon(_getCategoryIcon(category), size: 20),
                    const SizedBox(width: 8),
                    Text(category),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
            prefixIcon: Icons.category,
          ),
          const SizedBox(height: 16),

          AppTextField.currency(
            controller: _amountController,
            label: 'المبلغ',
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

          AppTextField(
            controller: _descriptionController,
            label: 'وصف المصروف',
            hint: 'مثال: فاتورة الكهرباء لشهر يناير',
            prefixIcon: Icons.description,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'يرجى إدخال وصف المصروف';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('التاريخ'),
          const SizedBox(height: 16),

          AppDatePicker(
            label: 'تاريخ المصروف',
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            required: true,
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('ملاحظات إضافية'),
          const SizedBox(height: 16),

          AppTextField.multiline(
            controller: _notesController,
            label: 'ملاحظات',
            hint: 'أضف أي ملاحظات أو تفاصيل إضافية',
            maxLines: 4,
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.danger, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.danger, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي المصروف',
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
                    text: widget.expense == null ? 'حفظ المصروف' : 'تحديث المصروف',
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'رواتب':
        return Icons.payment;
      case 'إيجار':
        return Icons.home;
      case 'كهرباء':
        return Icons.bolt;
      case 'ماء':
        return Icons.water_drop;
      case 'مواصلات':
        return Icons.directions_car;
      case 'صيانة':
        return Icons.build;
      case 'مشتريات':
        return Icons.shopping_cart;
      case 'اتصالات':
        return Icons.phone;
      case 'تسويق':
        return Icons.campaign;
      default:
        return Icons.attach_money;
    }
  }
}
