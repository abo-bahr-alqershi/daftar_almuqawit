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
  String? _selectedUnit;
  String _paymentMethod = 'نقدي';
  double _totalAmount = 0.0;
  
  List<String> _availableUnits = [];
  Map<String, double?> _unitSellPrices = {};

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
      _selectedUnit = data['unit'] ?? null;
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
  
  void _onQatTypeChanged(String? qatTypeId) {
    setState(() {
      _selectedQatTypeId = qatTypeId;
      _selectedUnit = null;
      _availableUnits = [];
      _unitSellPrices = {};
      _priceController.clear();
      
      if (qatTypeId != null) {
        final selectedQatType = widget.qatTypes.firstWhere(
          (qt) => qt.id.toString() == qatTypeId,
          orElse: () => widget.qatTypes.first,
        );
        
        if (selectedQatType.availableUnits != null && selectedQatType.availableUnits!.isNotEmpty) {
          _availableUnits = List<String>.from(selectedQatType.availableUnits!);
          
          if (selectedQatType.unitPrices != null) {
            for (var unit in _availableUnits) {
              final unitPrice = selectedQatType.unitPrices![unit];
              _unitSellPrices[unit] = unitPrice?.sellPrice;
            }
          }
          
          if (_availableUnits.isNotEmpty) {
            _selectedUnit = _availableUnits.first;
            _onUnitChanged(_selectedUnit);
          }
        }
      }
    });
  }
  
  void _onUnitChanged(String? unit) {
    setState(() {
      _selectedUnit = unit;
      if (unit != null && _unitSellPrices.containsKey(unit)) {
        final defaultPrice = _unitSellPrices[unit];
        if (defaultPrice != null && defaultPrice > 0) {
          _priceController.text = defaultPrice.toString();
        }
      }
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

    return Column(
      children: [
        QatTypeSelector(
          selectedQatTypeId: _selectedQatTypeId,
          onChanged: _onQatTypeChanged,
          qatTypes: qatTypeOptions,
        ),
        
        if (_availableUnits.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.straighten, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'اختر الوحدة',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableUnits.map((unit) {
                    final isSelected = _selectedUnit == unit;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getUnitIcon(unit),
                            size: 18,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(unit),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          _onUnitChanged(unit);
                        }
                      },
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuantityPriceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.5),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shopping_basket,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'الكمية والسعر',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          QuantityInput(
            value: double.tryParse(_quantityController.text) ?? 0.0,
            onChanged: (value) {
              _quantityController.text = value.toString();
            },
            label: _selectedUnit != null ? 'الكمية ($_selectedUnit)' : 'الكمية',
          ),
          
          const SizedBox(height: 16),
          
          AppTextField.currency(
            controller: _priceController,
            label: _selectedUnit != null ? 'السعر لكل $_selectedUnit (ريال)' : 'السعر (ريال)',
            hint: 'أدخل السعر',
            validator: (val) => val?.isEmpty == true ? 'مطلوب' : null,
          ),
          
          if (_quantityController.text.isNotEmpty && _priceController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calculate,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'المجموع الفرعي',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${((double.tryParse(_quantityController.text) ?? 0) * (double.tryParse(_priceController.text) ?? 0)).toStringAsFixed(2)} ريال',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
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
      
      if (_selectedUnit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار الوحدة')),
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
        'unit': _selectedUnit,
        'unitPrice': price,
        'totalAmount': (quantity * price) - discount,
        'discount': discount,
        'paymentMethod': _paymentMethod,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
      });
    }
  }
  
  IconData _getUnitIcon(String unit) {
    switch (unit) {
      case 'ربطة':
        return Icons.shopping_bag;
      case 'كيس':
        return Icons.inventory_2;
      case 'كيلو':
        return Icons.scale;
      default:
        return Icons.category;
    }
  }
}

