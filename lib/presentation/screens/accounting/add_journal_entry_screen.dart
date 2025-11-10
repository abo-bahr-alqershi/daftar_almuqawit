import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/journal_entry.dart';
import '../../blocs/accounting/accounting_bloc.dart';
import '../../blocs/accounting/accounting_event.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_date_picker.dart';
import 'widgets/account_selector.dart';

/// شاشة إضافة قيد يومية
class AddJournalEntryScreen extends StatefulWidget {
  final JournalEntry? entry;

  const AddJournalEntryScreen({
    super.key,
    this.entry,
  });

  @override
  State<AddJournalEntryScreen> createState() => _AddJournalEntryScreenState();
}

class _AddJournalEntryScreenState extends State<AddJournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _referenceController;
  
  DateTime _selectedDate = DateTime.now();
  final List<_EntryLine> _entryLines = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.entry?.description ?? '',
    );
    _referenceController = TextEditingController();
    
    // إضافة سطرين افتراضيين (مدين ودائن)
    _addEntryLine(isDebit: true);
    _addEntryLine(isDebit: false);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _referenceController.dispose();
    for (var line in _entryLines) {
      line.amountController.dispose();
    }
    super.dispose();
  }

  void _addEntryLine({required bool isDebit}) {
    setState(() {
      _entryLines.add(_EntryLine(
        amountController: TextEditingController(),
        isDebit: isDebit,
      ));
    });
  }

  void _removeEntryLine(int index) {
    if (_entryLines.length > 2) {
      setState(() {
        _entryLines[index].amountController.dispose();
        _entryLines.removeAt(index);
      });
    }
  }

  double _calculateTotal(bool isDebit) {
    return _entryLines
        .where((line) => line.isDebit == isDebit)
        .fold(0, (sum, line) {
      final amount = double.tryParse(line.amountController.text) ?? 0;
      return sum + amount;
    });
  }

  bool _isBalanced() {
    final debitTotal = _calculateTotal(true);
    final creditTotal = _calculateTotal(false);
    return (debitTotal - creditTotal).abs() < 0.01;
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_isBalanced()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('القيد غير متوازن! يجب أن يكون إجمالي المدين = إجمالي الدائن'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      // TODO: Create JournalEntry object and submit
      final totalAmount = _calculateTotal(true); // أو _calculateTotal(false) حيث أنها متساوية
      context.read<AccountingBloc>().add(
        AddTransaction(
          'journal_entry',
          totalAmount,
          _descriptionController.text,
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final debitTotal = _calculateTotal(true);
    final creditTotal = _calculateTotal(false);
    final isBalanced = _isBalanced();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.entry == null ? 'إضافة قيد يومية' : 'تعديل قيد يومية',
            style: AppTextStyles.headlineMedium,
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                              Text(
                                'معلومات القيد',
                                style: AppTextStyles.headlineSmall,
                              ),
                              const SizedBox(height: AppDimensions.spaceM),
                              
                              AppDatePicker(
                                label: 'التاريخ',
                                selectedDate: _selectedDate,
                                onDateSelected: (date) {
                                  setState(() => _selectedDate = date ?? DateTime.now());
                                },
                              ),
                              const SizedBox(height: AppDimensions.spaceM),

                              AppTextField.multiline(
                                controller: _descriptionController,
                                label: 'البيان *',
                                hint: 'أدخل وصف القيد',
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'البيان مطلوب';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.spaceM),

                              AppTextField(
                                controller: _referenceController,
                                label: 'رقم المرجع (اختياري)',
                                hint: 'رقم الفاتورة أو المستند',
                                prefixIcon: Icons.tag,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spaceL),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'تفاصيل القيد',
                            style: AppTextStyles.headlineSmall,
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: AppColors.success),
                                onPressed: () => _addEntryLine(isDebit: true),
                                tooltip: 'إضافة مدين',
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: AppColors.danger),
                                onPressed: () => _addEntryLine(isDebit: false),
                                tooltip: 'إضافة دائن',
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.spaceM),

                      ..._entryLines.asMap().entries.map((entry) {
                        final index = entry.key;
                        final line = entry.value;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.spaceM),
                          child: _buildEntryLineCard(line, index),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTotalCard(
                            'إجمالي المدين',
                            debitTotal,
                            AppColors.success,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceM),
                        Expanded(
                          child: _buildTotalCard(
                            'إجمالي الدائن',
                            creditTotal,
                            AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                    
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      decoration: BoxDecoration(
                        color: isBalanced 
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        border: Border.all(
                          color: isBalanced ? AppColors.success : AppColors.warning,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isBalanced ? Icons.check_circle : Icons.warning,
                            color: isBalanced ? AppColors.success : AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isBalanced ? 'القيد متوازن' : 'القيد غير متوازن',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isBalanced ? AppColors.success : AppColors.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceM),

                    Row(
                      children: [
                        Expanded(
                          child: AppButton.secondary(
                            text: 'إلغاء',
                            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                            fullWidth: true,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceM),
                        Expanded(
                          flex: 2,
                          child: AppButton.primary(
                            text: widget.entry == null ? 'إضافة' : 'حفظ',
                            onPressed: _isSubmitting ? null : _handleSubmit,
                            isLoading: _isSubmitting,
                            icon: Icons.save,
                            fullWidth: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryLineCard(_EntryLine line, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        side: BorderSide(
          color: line.isDebit ? AppColors.success : AppColors.danger,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (line.isDebit ? AppColors.success : AppColors.danger)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    line.isDebit ? 'مدين' : 'دائن',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: line.isDebit ? AppColors.success : AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (_entryLines.length > 2)
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.danger),
                    onPressed: () => _removeEntryLine(index),
                    tooltip: 'حذف',
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceM),
            
            AccountSelector(
              selectedAccountId: line.accountId,
              onChanged: (id) {
                setState(() => line.accountId = int.tryParse(id ?? ''));
              },
            ),
            const SizedBox(height: AppDimensions.spaceM),

            AppTextField.currency(
              controller: line.amountController,
              label: 'المبلغ *',
              hint: '0.00',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'المبلغ مطلوب';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'مبلغ غير صحيح';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${amount.toStringAsFixed(2)} ريال',
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryLine {
  final TextEditingController amountController;
  final bool isDebit;
  int? accountId;

  _EntryLine({
    required this.amountController,
    required this.isDebit,
    this.accountId,
  });
}
