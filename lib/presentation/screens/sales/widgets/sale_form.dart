import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/customer.dart';
import '../../../../domain/entities/qat_type.dart';
import '../../../../domain/usecases/sales/check_stock_availability.dart';
import '../../../../core/di/injection_container.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/app_date_picker.dart';
import 'customer_selector.dart';
import 'qat_type_selector.dart' show QatTypeSelector, QatTypeOption;
import 'payment_method_selector.dart';
import 'quantity_input.dart';

/// نموذج إضافة/تعديل عملية بيع - تصميم راقي هادئ
class SaleForm extends StatefulWidget {
  const SaleForm({
    required this.customers,
    required this.qatTypes,
    required this.onSubmit,
    super.key,
    this.initialData,
    this.onCancel,
  });
  final Map<String, dynamic>? initialData;
  final List<Customer> customers;
  final List<QatType> qatTypes;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback? onCancel;

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
  double _totalAmount = 0;

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
      _selectedUnit = data['unit'];
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

      if (qatTypeId != null && widget.qatTypes.isNotEmpty) {
        final selectedQatType = widget.qatTypes.firstWhere(
          (qt) => qt.id.toString() == qatTypeId,
          orElse: () => widget.qatTypes.first,
        );

        if (selectedQatType.availableUnits != null &&
            selectedQatType.availableUnits!.isNotEmpty) {
          _availableUnits = List<String>.from(selectedQatType.availableUnits!);

          if (selectedQatType.unitPrices != null) {
            for (final unit in _availableUnits) {
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
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildDateSection(),
        const SizedBox(height: 14),
        _buildCustomerSection(),
        const SizedBox(height: 14),
        _buildQatTypeSection(),
        const SizedBox(height: 14),
        _buildQuantityPriceSection(),
        const SizedBox(height: 14),
        _buildPaymentMethodSection(),
        const SizedBox(height: 14),
        _buildDiscountSection(),
        const SizedBox(height: 14),
        _buildSummaryCard(),
        const SizedBox(height: 14),
        _buildNotesSection(),
        const SizedBox(height: 20),
        _buildActionButtons(),
      ],
    ),
  );

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.12),
          AppColors.primary.withOpacity(0.06),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary.withOpacity(0.15)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.primary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.shopping_cart_rounded, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initialData != null ? 'تعديل عملية بيع' : 'إضافة عملية بيع',
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                'أدخل تفاصيل عملية البيع',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildDateSection() => AppDatePicker(
    label: 'تاريخ البيع',
    selectedDate: _selectedDate,
    onDateSelected: (date) =>
        setState(() => _selectedDate = date ?? DateTime.now()),
  );

  Widget _buildCustomerSection() => CustomerSelector(
    selectedCustomerId: _selectedCustomerId,
    onChanged: (customerId) => setState(() => _selectedCustomerId = customerId),
    customers: widget.customers,
  );

  Widget _buildQatTypeSection() {
    final qatTypeOptions = widget.qatTypes
        .map(
          (qt) => QatTypeOption(
            id: qt.id.toString(),
            name: qt.name,
            price: qt.defaultSellPrice,
          ),
        )
        .toList();

    return Column(
      children: [
        QatTypeSelector(
          selectedQatTypeId: _selectedQatTypeId,
          onChanged: _onQatTypeChanged,
          qatTypes: qatTypeOptions,
        ),

        if (_availableUnits.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.straighten_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'اختر الوحدة',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableUnits.map((unit) {
                    final isSelected = _selectedUnit == unit;
                    return GestureDetector(
                      onTap: () {
                        _onUnitChanged(unit);
                        HapticFeedback.lightImpact();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    AppColors.primary.withOpacity(0.15),
                                    AppColors.primary.withOpacity(0.08),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : AppColors.background.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.3)
                                : AppColors.border.withOpacity(0.15),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getUnitIcon(unit),
                              size: 16,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              unit,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildQuantityPriceSection() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border.withOpacity(0.1)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shopping_basket_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'الكمية والسعر',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        QuantityInput(
          value: double.tryParse(_quantityController.text) ?? 0.0,
          onChanged: (value) => _quantityController.text = value.toString(),
          label: _selectedUnit != null ? 'الكمية ($_selectedUnit)' : 'الكمية',
        ),

        const SizedBox(height: 12),

        AppTextField.currency(
          controller: _priceController,
          label: _selectedUnit != null
              ? 'السعر لكل $_selectedUnit (ريال)'
              : 'السعر (ريال)',
          hint: 'أدخل السعر',
          validator: (val) => val?.isEmpty == true ? 'مطلوب' : null,
        ),

        if (_quantityController.text.isNotEmpty &&
            _priceController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.success.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calculate_rounded,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'المجموع الفرعي',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${((double.tryParse(_quantityController.text) ?? 0) * (double.tryParse(_priceController.text) ?? 0)).toStringAsFixed(2)} ريال',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );

  Widget _buildPaymentMethodSection() => PaymentMethodSelector(
    selectedMethod: _paymentMethod,
    onChanged: (method) => setState(() => _paymentMethod = method),
  );

  Widget _buildDiscountSection() => AppTextField.currency(
    controller: _discountController,
    label: 'الخصم (ريال)',
    hint: '0',
  );

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
          colors: [
            AppColors.success.withOpacity(0.08),
            AppColors.success.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'المجموع الفرعي',
            '${subtotal.toStringAsFixed(2)} ريال',
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: AppColors.border.withOpacity(0.1),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'الخصم',
            '${discount.toStringAsFixed(2)} ريال',
            color: AppColors.danger,
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: AppColors.border.withOpacity(0.1),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'الإجمالي',
            '${total.toStringAsFixed(2)} ريال',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? color,
    bool isTotal = false,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: (isTotal ? AppTextStyles.bodyLarge : AppTextStyles.bodyMedium)
            .copyWith(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            ),
      ),
      Text(
        value,
        style: (isTotal ? AppTextStyles.bodyLarge : AppTextStyles.bodyMedium)
            .copyWith(
              color: color ?? (isTotal ? AppColors.success : AppColors.textPrimary),
              fontWeight: FontWeight.w600,
            ),
      ),
    ],
  );

  Widget _buildNotesSection() => AppTextField.multiline(
    controller: _notesController,
    label: 'ملاحظات',
    hint: 'أضف أي ملاحظات إضافية (اختياري)',
    maxLines: 3,
  );

  Widget _buildActionButtons() => Row(
    children: [
      if (widget.onCancel != null) ...[
        Expanded(
          child: AppButton.secondary(text: 'إلغاء', onPressed: widget.onCancel),
        ),
        const SizedBox(width: 12),
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

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedQatTypeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار نوع القات')),
        );
        return;
      }

      if (_selectedUnit == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('الرجاء اختيار الوحدة')));
        return;
      }

      final quantity = double.parse(_quantityController.text);
      final price = double.parse(_priceController.text);
      final discount = double.tryParse(_discountController.text) ?? 0.0;

      // التحقق من المخزون قبل البيع
      try {
        final checkStock = sl<CheckStockAvailability>();
        final stockCheck = await checkStock(
          CheckStockParams(
            qatTypeId: int.parse(_selectedQatTypeId!),
            unit: _selectedUnit!,
            requestedQuantity: quantity,
            excludeSaleId: widget.initialData?['id'] as int?,
          ),
        );

        if (!stockCheck.isAvailable) {
          if (!mounted) return;
          
          // عرض رسالة تحذيرية مع تفاصيل المخزون
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.warning_rounded, color: AppColors.warning, size: 24),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('تحذير: نقص في المخزون')),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stockCheck.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفاصيل المخزون:',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildStockInfoRow(
                          'إجمالي المشتريات',
                          '${stockCheck.purchasedQuantity} ${_selectedUnit}',
                          AppColors.success,
                        ),
                        _buildStockInfoRow(
                          'إجمالي المبيعات',
                          '${stockCheck.soldQuantity} ${_selectedUnit}',
                          AppColors.info,
                        ),
                        _buildStockInfoRow(
                          'الكمية المتاحة',
                          '${stockCheck.availableQuantity} ${_selectedUnit}',
                          AppColors.primary,
                        ),
                        _buildStockInfoRow(
                          'الكمية المطلوبة',
                          '${stockCheck.requestedQuantity} ${_selectedUnit}',
                          AppColors.warning,
                        ),
                        _buildStockInfoRow(
                          'النقص',
                          '${stockCheck.shortage.toStringAsFixed(2)} ${_selectedUnit}',
                          AppColors.danger,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'لا يمكن إتمام عملية البيع. يرجى شراء كمية إضافية أو تقليل الكمية المطلوبة.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('حسناً'),
                ),
              ],
            ),
          );
          
          // منع البيع
          return;
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التحقق من المخزون: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      // إذا كان المخزون متوفراً، متابعة عملية البيع
      widget.onSubmit({
        'date': _selectedDate.toString().split(' ')[0],
        'time': TimeOfDay.now().format(context),
        'customerId': _selectedCustomerId != null
            ? int.tryParse(_selectedCustomerId!)
            : null,
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

  Widget _buildStockInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getUnitIcon(String unit) {
    switch (unit) {
      case 'ربطة':
        return Icons.shopping_bag_rounded;
      case 'كيس':
        return Icons.inventory_2_rounded;
      case 'كيلو':
        return Icons.scale_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
