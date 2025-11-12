import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/expense.dart';

/// نموذج إضافة أو تعديل مصروف - تصميم راقي هادئ
class ExpenseForm extends StatefulWidget {
  final Expense? initialExpense;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;

  const ExpenseForm({
    super.key,
    this.initialExpense,
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
  String _selectedPaymentMethod = 'نقد';
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'رواتب', 'icon': Icons.payments_rounded, 'color': AppColors.primary},
    {'name': 'إيجار', 'icon': Icons.home_rounded, 'color': AppColors.warning},
    {'name': 'كهرباء', 'icon': Icons.bolt_rounded, 'color': AppColors.info},
    {'name': 'ماء', 'icon': Icons.water_drop_rounded, 'color': Color(0xFF0288D1)},
    {'name': 'مواصلات', 'icon': Icons.directions_car_rounded, 'color': AppColors.success},
    {'name': 'صيانة', 'icon': Icons.build_rounded, 'color': AppColors.danger},
    {'name': 'مشتريات', 'icon': Icons.shopping_cart_rounded, 'color': AppColors.purchases},
    {'name': 'اتصالات', 'icon': Icons.phone_rounded, 'color': Color(0xFF7C3AED)},
    {'name': 'تسويق', 'icon': Icons.campaign_rounded, 'color': Color(0xFFFF6F00)},
    {'name': 'أخرى', 'icon': Icons.more_horiz_rounded, 'color': AppColors.textSecondary},
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'نقد', 'icon': Icons.payments_rounded},
    {'name': 'بطاقة', 'icon': Icons.credit_card_rounded},
    {'name': 'تحويل', 'icon': Icons.account_balance_rounded},
    {'name': 'شيك', 'icon': Icons.receipt_rounded},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialExpense != null) {
      _amountController.text = widget.initialExpense!.amount.toString();
      _descriptionController.text = widget.initialExpense!.description ?? '';
      _notesController.text = widget.initialExpense!.notes ?? '';
      _selectedCategory = widget.initialExpense!.category;
      _selectedPaymentMethod = widget.initialExpense!.paymentMethod;
      _isRecurring = widget.initialExpense!.recurring;
      _selectedDate = DateTime.tryParse(widget.initialExpense!.date) ?? DateTime.now();
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
      'date': _selectedDate,
      'paymentMethod': _selectedPaymentMethod,
      'recurring': _isRecurring,
    };
  }

  Color _getCategoryColor(String category) {
    final cat = _categories.firstWhere(
      (c) => c['name'] == category,
      orElse: () => _categories.last,
    );
    return cat['color'] as Color;
  }

  IconData _getCategoryIcon(String category) {
    final cat = _categories.firstWhere(
      (c) => c['name'] == category,
      orElse: () => _categories.last,
    );
    return cat['icon'] as IconData;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('الفئة', Icons.category_rounded),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            
            const SizedBox(height: 24),
            _buildSectionTitle('المبلغ', Icons.attach_money_rounded),
            const SizedBox(height: 16),
            _buildAmountField(),
            
            const SizedBox(height: 24),
            _buildSectionTitle('الوصف', Icons.description_rounded),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            
            const SizedBox(height: 24),
            _buildSectionTitle('طريقة الدفع', Icons.payment_rounded),
            const SizedBox(height: 16),
            _buildPaymentMethodSelector(),
            
            const SizedBox(height: 24),
            _buildSectionTitle('التاريخ', Icons.calendar_today_rounded),
            const SizedBox(height: 16),
            _buildDatePicker(),
            
            const SizedBox(height: 24),
            _buildRecurringSwitch(),
            
            const SizedBox(height: 24),
            _buildSectionTitle('ملاحظات (اختياري)', Icons.note_rounded),
            const SizedBox(height: 16),
            _buildNotesField(),
            
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.expense.withOpacity(0.1),
                AppColors.expense.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.expense),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ...List.generate(
            (_categories.length / 2).ceil(),
            (rowIndex) {
              final startIndex = rowIndex * 2;
              final endIndex = (startIndex + 2).clamp(0, _categories.length);
              final rowCategories = _categories.sublist(startIndex, endIndex);

              return Column(
                children: [
                  if (rowIndex > 0)
                    Divider(height: 1, color: AppColors.border.withOpacity(0.1)),
                  Row(
                    children: [
                      ...rowCategories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        final isSelected = _selectedCategory == category['name'];

                        return Expanded(
                          child: Row(
                            children: [
                              if (index > 0)
                                Container(
                                  width: 1,
                                  height: 60,
                                  color: AppColors.border.withOpacity(0.1),
                                ),
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _selectedCategory = category['name']);
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              gradient: isSelected
                                                  ? LinearGradient(
                                                      colors: [
                                                        (category['color'] as Color),
                                                        (category['color'] as Color).withOpacity(0.7),
                                                      ],
                                                    )
                                                  : null,
                                              color: isSelected
                                                  ? null
                                                  : (category['color'] as Color).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              category['icon'],
                                              size: 18,
                                              color: isSelected
                                                  ? Colors.white
                                                  : category['color'],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              category['name'],
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? AppColors.textPrimary
                                                    : AppColors.textSecondary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle_rounded,
                                              size: 18,
                                              color: category['color'],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        decoration: InputDecoration(
          hintText: '0.00',
          hintStyle: TextStyle(
            color: AppColors.textHint,
            fontSize: 18,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.expense.withOpacity(0.15),
                  AppColors.expense.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.attach_money_rounded,
              color: AppColors.expense,
              size: 20,
            ),
          ),
          suffixText: 'ريال',
          suffixStyle: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
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
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _descriptionController,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'مثال: فاتورة الكهرباء لشهر ديسمبر',
          hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.info.withOpacity(0.15),
                  AppColors.info.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: AppColors.info,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'يرجى إدخال وصف المصروف';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _paymentMethods.asMap().entries.map((entry) {
          final index = entry.key;
          final method = entry.value;
          final isSelected = _selectedPaymentMethod == method['name'];

          return Column(
            children: [
              if (index > 0)
                Divider(height: 1, color: AppColors.border.withOpacity(0.1)),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedPaymentMethod = method['name']);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [AppColors.primary, AppColors.accent],
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            method['icon'],
                            size: 20,
                            color: isSelected ? Colors.white : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            method['name'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          HapticFeedback.lightImpact();
          final picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.expense,
                    onPrimary: Colors.white,
                    surface: AppColors.surface,
                    onSurface: AppColors.textPrimary,
                  ),
                ),
                child: child!,
              );
            },
          );

          if (picked != null) {
            setState(() => _selectedDate = picked);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.info.withOpacity(0.15),
                      AppColors.info.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _formatDate(_selectedDate),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecurringSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isRecurring
              ? AppColors.info.withOpacity(0.3)
              : AppColors.border.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: _isRecurring
                  ? const LinearGradient(
                      colors: [AppColors.info, AppColors.primary],
                    )
                  : null,
              color: _isRecurring ? null : AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.repeat_rounded,
              color: _isRecurring ? Colors.white : AppColors.info,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مصروف متكرر',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'يتكرر كل شهر تلقائياً',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: _isRecurring,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() => _isRecurring = value);
              },
              activeColor: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _notesController,
        maxLines: 4,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'أضف ملاحظات إضافية...',
          hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.border.withOpacity(0.3)),
              ),
              elevation: 0,
            ),
            child: Text(
              'إلغاء',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        widget.initialExpense != null ? 'حفظ التعديلات' : 'إضافة المصروف',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
