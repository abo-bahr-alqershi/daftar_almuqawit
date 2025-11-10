import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/debts/debts_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_date_picker.dart';
import '../../widgets/common/app_dropdown.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/snackbar_widget.dart';
import '../../sales/widgets/customer_selector.dart';

/// شاشة إضافة دين
/// 
/// تسمح بإضافة دين جديد على عميل
class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({super.key});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _selectedDate;
  DateTime? _dueDate;
  String? _selectedCustomerId;
  String _debtType = 'بيع آجل';

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitDebt() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCustomerId == null) {
      SnackbarWidget.showError(
        context: context,
        message: 'يرجى اختيار العميل',
      );
      return;
    }

    final amount = double.parse(_amountController.text);

    context.read<DebtsBloc>().add(
      AddDebtEvent(
        Debt(
          personType: 'عميل',
          personId: _selectedCustomerId!,
          personName: 'عميل مجهول', // يجب جلب الاسم من قاعدة البيانات
          originalAmount: amount,
          remainingAmount: amount,
          date: _selectedDate ?? DateTime.now(),
          dueDate: _dueDate,
          notes: _notesController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة دين'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: BlocConsumer<DebtsBloc, DebtsState>(
        listener: (context, state) {
          if (state is DebtOperationSuccess) {
            SnackbarWidget.showSuccess(
              context: context,
              message: 'تمت إضافة الدين بنجاح',
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

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // قسم معلومات الدين
                _buildSectionTitle('معلومات الدين'),
                const SizedBox(height: 16),

                // اختيار العميل
                CustomerSelector(
                  selectedCustomerId: _selectedCustomerId,
                  onChanged: (customerId) {
                    setState(() {
                      _selectedCustomerId = customerId;
                    });
                  },
                  customers: const [], // يجب جلبها من BLoC
                  allowAnonymous: false,
                ),
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

                // معاينة الدين
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

                // أزرار الحفظ والإلغاء
                Row(
                  children: [
                    Expanded(
                      child: AppButton.secondary(
                        text: 'إلغاء',
                        onPressed: isLoading
                            ? null
                            : () async {
                                final confirm = await ConfirmDialog.show(
                                  context: context,
                                  title: 'إلغاء العملية',
                                  message: 'هل تريد إلغاء إضافة الدين؟',
                                  confirmText: 'نعم، إلغاء',
                                  cancelText: 'لا، متابعة',
                                );
                                if (confirm == true && context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: AppButton.primary(
                        text: 'حفظ الدين',
                        icon: Icons.save,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _submitDebt,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
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
