import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/customer.dart';
import '../../../../domain/entities/qat_type.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/app_date_picker.dart';
import 'customer_selector.dart';
import 'qat_type_selector.dart' show QatTypeSelector, QatTypeOption;
import 'payment_method_selector.dart';
import 'quantity_input.dart';

/// نموذج إضافة/تعديل عملية بيع
/// 
/// يوفر واجهة شاملة لإدخال بيانات البيع
class SaleForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final List<Customer> customers;
  final List<QatType> qatTypes;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback? onCancel;

  const SaleForm({
    super.key,
    this.initialData,
    required this.customers,
    required this.qatTypes,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<SaleForm> createState() => _SaleFormState();
}

class _SaleFormState extends State<SaleForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String? _selectedCustomerId;
  String? _selectedQatTypeId;
  String _paymentMethod = 'نقدي';
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _quantityController.addListener(_calculateTotal);
    _priceController.addListener(_calculateTotal);
    _discountController.addListener(_calculateTotal);
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _quantityController.text = data['quantity']?.toString() ?? '';
      _priceController.text = data['price']?.toString() ?? '';
      _discountController.text = data['discount']?.toString() ?? '0';
      _notesController.text = data['notes'] ?? '';
      _selectedCustomerId = data['customerId']?.toString();
      _selectedQatTypeId = data['qatTypeId']?.toString();
      _paymentMethod = data['paymentMethod'] ?? 'نقدي';
    } else {
      _discountController.text = '0';
    }
  }

  void _calculateTotal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    
    setState(() {
      _totalAmount = (quantity * price) - discount;
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildDateSection(),
          const SizedBox(height: 16),
          _buildCustomerSection(),
          const SizedBox(height: 16),
          _buildQatTypeSection(),
          const SizedBox(height: 16),
          _buildQuantityPriceSection(),
          const SizedBox(height: 16),
          _buildPaymentMethodSection(),
          const SizedBox(height: 16),
          _buildDiscountSection(),
          const SizedBox(height: 16),
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildNotesSection(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.initialData != null ? 'تعديل عملية بيع' : 'إضافة عملية بيع',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أدخل تفاصيل عملية البيع',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return AppDatePicker(
      label: 'تاريخ البيع',
      selectedDate: _selectedDate,
      onDateSelected: (date) => setState(() => _selectedDate = date ?? DateTime.now()),
    );
  }

  Widget _buildCustomerSection() {
    return CustomerSelector(
      selectedCustomerId: _selectedCustomerId,
      onChanged: (customerId) => setState(() => _selectedCustomerId = customerId),
      customers: widget.customers,
      allowAnonymous: true,
    );
  }

  Widget _buildQatTypeSection() {
    final qatTypeOptions = widget.qatTypes.map((qt) => QatTypeOption(
      id: qt.id.toString(),
      name: qt.name,
      price: qt.defaultSellPrice,
    )).toList();

    return QatTypeSelector(
      selectedQatTypeId: _selectedQatTypeId,
      onChanged: (qatTypeId) {
        setState(() {
          _selectedQatTypeId = qatTypeId;
          // تعيين السعر الافتراضي
          final qatType = widget.qatTypes.firstWhere(
            (qt) => qt.id.toString() == qatTypeId,
            orElse: () => widget.qatTypes.first,
          );
          if (qatType.defaultSellPrice != null && _priceController.text.isEmpty) {
            _priceController.text = qatType.defaultSellPrice.toString();
          }
        });
      },
      qatTypes: qatTypeOptions,
    );
  }

  Widget _buildQuantityPriceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الكمية والسعر',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: QuantityInput(
                  value: double.tryParse(_quantityController.text) ?? 0.0,
                  onChanged: (value) {
                    _quantityController.text = value.toString();
                  },
                  label: 'الكمية (كيس)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField.currency(
                  controller: _priceController,
                  label: 'السعر (ريال)',
                  validator: (val) => val?.isEmpty == true ? 'مطلوب' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return PaymentMethodSelector(
      selectedMethod: _paymentMethod,
      onChanged: (method) => setState(() => _paymentMethod = method),
    );
  }

  Widget _buildDiscountSection() {
    return AppTextField.currency(
      controller: _discountController,
      label: 'الخصم (ريال)',
      hint: '0',
    );
  }

  Widget _buildSummaryCard() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final subtotal = quantity * price;
    final total = subtotal - discount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success.withOpacity(0.1), AppColors.success.withOpacity(0.05)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('المجموع الفرعي', '${subtotal.toStringAsFixed(2)} ريال'),
          const Divider(height: 16),
          _buildSummaryRow('الخصم', '${discount.toStringAsFixed(2)} ريال', color: AppColors.danger),
          const Divider(height: 16),
          _buildSummaryRow(
            'الإجمالي',
            '${total.toStringAsFixed(2)} ريال',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isTotal ? AppTextStyles.titleMedium : AppTextStyles.bodyMedium).copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: (isTotal ? AppTextStyles.titleLarge : AppTextStyles.titleMedium).copyWith(
            color: color ?? (isTotal ? AppColors.success : AppColors.textPrimary),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return AppTextField.multiline(
      controller: _notesController,
      label: 'ملاحظات',
      hint: 'أضف أي ملاحظات إضافية (اختياري)',
      maxLines: 3,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (widget.onCancel != null) ...[
          Expanded(
            child: AppButton.secondary(
              text: 'إلغاء',
              onPressed: widget.onCancel,
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          flex: 2,
          child: AppButton.primary(
            text: widget.initialData != null ? 'حفظ التعديلات' : 'حفظ البيع',
            onPressed: _handleSave,
            fullWidth: true,
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_selectedQatTypeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار نوع القات')),
        );
        return;
      }

      final quantity = double.parse(_quantityController.text);
      final price = double.parse(_priceController.text);
      final discount = double.tryParse(_discountController.text) ?? 0.0;

      widget.onSubmit({
        'date': _selectedDate.toString().split(' ')[0],
        'time': TimeOfDay.now().format(context),
        'customerId': _selectedCustomerId != null ? int.tryParse(_selectedCustomerId!) : null,
        'qatTypeId': int.parse(_selectedQatTypeId!),
        'quantity': quantity,
        'unitPrice': price,
        'totalAmount': (quantity * price) - discount,
        'discount': discount,
        'paymentMethod': _paymentMethod,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
      });
    }
  }
}

