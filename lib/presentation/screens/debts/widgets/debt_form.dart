import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../domain/entities/customer.dart';

/// نموذج إضافة أو تعديل دين
class DebtForm extends StatefulWidget {
  final List<Customer> customers;
  final Map<String, dynamic>? initialData;
  final bool isLoading;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;

  const DebtForm({
    super.key,
    required this.customers,
    this.initialData,
    this.isLoading = false,
    this.onSubmit,
    this.onCancel,
  });

  @override
  DebtFormState createState() => DebtFormState();
}

class DebtFormState extends State<DebtForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedCustomerId;
  String? _selectedCustomerName;
  String? _selectedCustomerPhone;
  String _debtType = 'بيع اجل';
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;

  final GlobalKey _customerSelectorKey = GlobalKey();
  final GlobalKey _debtTypeKey = GlobalKey();
  final GlobalKey _amountFieldKey = GlobalKey();
  final GlobalKey _descriptionFieldKey = GlobalKey();
  final GlobalKey _dateFieldKey = GlobalKey();
  final GlobalKey _dueDateFieldKey = GlobalKey();
  final GlobalKey _notesFieldKey = GlobalKey();
  final GlobalKey _saveButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _initializeFromData();
    }
  }

  void _initializeFromData() {
    final data = widget.initialData!;
    _selectedCustomerId = data['customerId'];
    _selectedCustomerName = data['customerName'];
    _selectedCustomerPhone = data['customerPhone'];
    _debtType = data['debtType'] ?? 'بيع اجل';
    _amountController.text = data['amount']?.toString() ?? '';
    _descriptionController.text = data['description'] ?? '';
    _notesController.text = data['notes'] ?? '';
    if (data['date'] != null) {
      _selectedDate = data['date'] is DateTime
          ? data['date']
          : DateTime.parse(data['date']);
    }
    if (data['dueDate'] != null) {
      _dueDate = data['dueDate'] is DateTime
          ? data['dueDate']
          : DateTime.parse(data['dueDate']);
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
    if (!(_formKey.currentState?.validate() ?? false)) {
      return false;
    }

    if (_selectedCustomerId == null) {
      _showErrorSnackbar('يرجى اختيار العميل');
      return false;
    }

    if (_dueDate != null && _dueDate!.isBefore(_selectedDate)) {
      _showErrorSnackbar('تاريخ الاستحقاق يجب أن يكون بعد تاريخ الدين');
      return false;
    }

    return true;
  }

  Map<String, dynamic> getFormData() {
    return {
      'customerId': _selectedCustomerId!,
      'customerName': _selectedCustomerName!,
      'customerPhone': _selectedCustomerPhone,
      'debtType': _debtType,
      'amount': double.parse(_amountController.text),
      'description': _descriptionController.text,
      'notes': _notesController.text.isEmpty ? null : _notesController.text,
      'date': _selectedDate,
      'dueDate': _dueDate,
    };
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('معلومات العميل'),
            const SizedBox(height: 16),
            _buildCustomerSelector(),

            const SizedBox(height: 24),
            _buildSectionTitle('تفاصيل الدين'),
            const SizedBox(height: 16),

            _buildDebtTypeSelector(),
            const SizedBox(height: 16),

            _buildAmountField(),
            const SizedBox(height: 16),

            _buildDescriptionField(),

            const SizedBox(height: 24),
            _buildSectionTitle('التواريخ'),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildDatePicker()),
                const SizedBox(width: 12),
                Expanded(child: _buildDueDatePicker()),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('ملاحظات'),
            const SizedBox(height: 16),

            _buildNotesField(),

            const SizedBox(height: 24),
            _buildAmountPreview(),

            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
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
            gradient: const LinearGradient(
              colors: [AppColors.danger, AppColors.warning],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerSelector() {
    return InkWell(
      onTap: widget.isLoading ? null : () => _showCustomerSelector(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        key: _customerSelectorKey,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedCustomerId == null
                ? AppColors.border
                : AppColors.danger.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
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
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.danger,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'العميل',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedCustomerName ?? 'اختر العميل',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _selectedCustomerId == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontWeight: _selectedCustomerId == null
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'اختر العميل',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: widget.customers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off_rounded,
                            size: 60,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا يوجد عملاء',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: widget.customers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final customer = widget.customers[index];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCustomerId = customer.id;
                              _selectedCustomerName = customer.name;
                              _selectedCustomerPhone = customer.phone;
                            });
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _selectedCustomerId == customer.id
                                  ? AppColors.danger.withOpacity(0.1)
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedCustomerId == customer.id
                                    ? AppColors.danger
                                    : AppColors.border.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.danger.withOpacity(0.2),
                                        AppColors.warning.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: AppColors.danger,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customer.name,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      if (customer.phone != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          customer.phone!,
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (_selectedCustomerId == customer.id)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.danger,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtTypeSelector() {
    final types = ['بيع اجل', 'اخرى'];

    return Column(
      key: _debtTypeKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع الدين',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: types.map((type) {
            final isSelected = _debtType == type;
            return InkWell(
              onTap: widget.isLoading
                  ? null
                  : () {
                      setState(() => _debtType = type);
                    },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [AppColors.danger, AppColors.warning],
                        )
                      : null,
                  color: isSelected ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.border,
                  ),
                ),
                child: Text(
                  type,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      key: _amountFieldKey,
      controller: _amountController,
      keyboardType: TextInputType.number,
      enabled: !widget.isLoading,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: 'مبلغ الدين *',
        hintText: 'أدخل المبلغ',
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.danger.withOpacity(0.1),
                AppColors.warning.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.attach_money_rounded, size: 20),
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
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
      ),
      validator: Validators.validateAmount,
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      key: _descriptionFieldKey,
      controller: _descriptionController,
      enabled: !widget.isLoading,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: 'وصف الدين *',
        hintText: 'مثال: دين بيع قات - 20 علاقية',
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
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
          child: const Icon(Icons.description_rounded, size: 20),
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
          borderSide: const BorderSide(color: AppColors.info, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال وصف الدين';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: widget.isLoading
          ? null
          : () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                locale: const Locale('ar'),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        key: _dateFieldKey,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'تاريخ الدين *',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDueDatePicker() {
    return InkWell(
      onTap: widget.isLoading
          ? null
          : () async {
              final date = await showDatePicker(
                context: context,
                initialDate:
                    _dueDate ?? _selectedDate.add(const Duration(days: 30)),
                firstDate: _selectedDate,
                lastDate: DateTime(2100),
                locale: const Locale('ar'),
              );
              if (date != null) {
                setState(() => _dueDate = date);
              }
            },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        key: _dueDateFieldKey,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.event_available,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'تاريخ الاستحقاق',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _dueDate != null
                  ? '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'
                  : 'غير محدد',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: _dueDate != null
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: _dueDate != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      key: _notesFieldKey,
      controller: _notesController,
      enabled: !widget.isLoading,
      maxLines: 3,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: 'ملاحظات (اختياري)',
        hintText: 'أضف أي ملاحظات أو تفاصيل إضافية',
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
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.5),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountPreview() {
    final amount = double.tryParse(_amountController.text) ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.danger.withOpacity(0.1),
            AppColors.warning.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.danger.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.danger, AppColors.warning],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إجمالي الدين',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${amount.toStringAsFixed(0)} ريال',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (widget.onCancel != null)
          Expanded(
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onCancel,
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
        if (widget.onCancel != null) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.danger, AppColors.warning],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.danger.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              key: _saveButtonKey,
              onPressed: widget.isLoading ? null : widget.onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
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
                          widget.initialData == null
                              ? 'حفظ الدين'
                              : 'حفظ التعديلات',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, GlobalKey> get tutorialKeys => {
        'customer': _customerSelectorKey,
        'debtType': _debtTypeKey,
        'amount': _amountFieldKey,
        'description': _descriptionFieldKey,
        'date': _dateFieldKey,
        'dueDate': _dueDateFieldKey,
        'notes': _notesFieldKey,
        'saveButton': _saveButtonKey,
      };
}
