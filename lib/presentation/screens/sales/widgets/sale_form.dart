import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../data/datasources/local/sales_local_datasource.dart';
import '../../../../domain/entities/customer.dart';
import '../../../../domain/entities/qat_type.dart';
import '../../../../domain/usecases/sales/check_stock_availability.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/app_date_picker.dart';
import 'customer_selector.dart';
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
  State<SaleForm> createState() => SaleFormState();
}

class SaleFormState extends State<SaleForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _notesController = TextEditingController();
  final _invoiceNumberController = TextEditingController();

  // مفاتيح التعليمات
  final _invoiceNumberFieldKey = GlobalKey();
  final _dateFieldKey = GlobalKey();
  final _customerFieldKey = GlobalKey();
  final _qatTypeFieldKey = GlobalKey();
  final _unitFieldKey = GlobalKey();
  final _quantityFieldKey = GlobalKey();
  final _priceFieldKey = GlobalKey();
  final _paymentMethodKey = GlobalKey();
  final _discountFieldKey = GlobalKey();
  final _notesFieldKey = GlobalKey();
  final _saveButtonKey = GlobalKey();

  DateTime _selectedDate = DateTime.now();
  String? _selectedCustomerId;
  String? _selectedQatTypeId;
  String? _selectedUnit;
  String _paymentMethod = 'نقدي';
  double _totalAmount = 0;

  List<String> _availableUnits = [];
  Map<String, double?> _unitSellPrices = {};
  
  String _generatedInvoiceNumber = '';
  bool _isLoadingInvoiceNumber = false;

  // Getters لمفاتيح التعليمات
  Map<String, GlobalKey> get tutorialKeys => {
    'invoiceNumber': _invoiceNumberFieldKey,
    'date': _dateFieldKey,
    'customer': _customerFieldKey,
    'qatType': _qatTypeFieldKey,
    'unit': _unitFieldKey,
    'quantity': _quantityFieldKey,
    'price': _priceFieldKey,
    'paymentMethod': _paymentMethodKey,
    'discount': _discountFieldKey,
    'notes': _notesFieldKey,
    'saveButton': _saveButtonKey,
  };

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _quantityController.addListener(_calculateTotal);
    _priceController.addListener(_calculateTotal);
    _discountController.addListener(_calculateTotal);
    
    // اختيار الوحدة الافتراضية الأولى
    _selectedUnit = 'ربطة';
    
    // توليد رقم فاتورة تلقائي للعمليات الجديدة فقط
    if (widget.initialData == null) {
      _generateInvoiceNumber();
    } else {
      _generatedInvoiceNumber = widget.initialData!['invoiceNumber'] ?? '';
      _invoiceNumberController.text = _generatedInvoiceNumber;
    }
  }
  
  /// توليد رقم فاتورة تلقائي
  Future<void> _generateInvoiceNumber() async {
    setState(() => _isLoadingInvoiceNumber = true);
    
    try {
      final dataSource = getIt<SalesLocalDataSource>();
      final invoiceNumber = await dataSource.generateInvoiceNumber();
      
      if (mounted) {
        setState(() {
          _generatedInvoiceNumber = invoiceNumber;
          _invoiceNumberController.text = invoiceNumber;
          _isLoadingInvoiceNumber = false;
        });
      }
    } catch (e) {
      debugPrint('Error generating invoice number: $e');
      if (mounted) {
        setState(() => _isLoadingInvoiceNumber = false);
      }
    }
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

        debugPrint('🔍 Selected QatType: ${selectedQatType.name}');
        debugPrint('🔍 Available Units: ${selectedQatType.availableUnits}');
        debugPrint('🔍 Unit Prices: ${selectedQatType.unitPrices}');

        // إذا لم تكن هناك وحدات محددة، استخدم الوحدات الافتراضية
        if (selectedQatType.availableUnits != null &&
            selectedQatType.availableUnits!.isNotEmpty) {
          _availableUnits = List<String>.from(selectedQatType.availableUnits!);
          debugPrint('✅ Units loaded from QatType: $_availableUnits');
        } else {
          // وحدات افتراضية
          _availableUnits = ['ربطة', 'كيس', 'كرتون', 'قطعة'];
          debugPrint('⚠️ No units in QatType, using default units: $_availableUnits');
        }

        // تحميل الأسعار إذا كانت متوفرة
        if (selectedQatType.unitPrices != null) {
          for (final unit in _availableUnits) {
            final unitPrice = selectedQatType.unitPrices![unit];
            _unitSellPrices[unit] = unitPrice?.sellPrice;
          }
          debugPrint('✅ Prices loaded: $_unitSellPrices');
        } else {
          // استخدام السعر الافتراضي للبيع إذا كان متوفراً
          if (selectedQatType.defaultSellPrice != null) {
            for (final unit in _availableUnits) {
              _unitSellPrices[unit] = selectedQatType.defaultSellPrice;
            }
            debugPrint('⚠️ Using default sell price for all units: ${selectedQatType.defaultSellPrice}');
          }
        }

        // اختيار الوحدة الأولى تلقائياً
        if (_availableUnits.isNotEmpty) {
          _selectedUnit = _availableUnits.first;
          debugPrint('✅ Default unit selected: $_selectedUnit');
          _onUnitChanged(_selectedUnit);
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
    _invoiceNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildInvoiceNumberField(),
          const SizedBox(height: 14),
          _buildDateSection(),
          const SizedBox(height: 14),
          _buildCustomerSection(),
          const SizedBox(height: 14),
          _buildQatTypeSection(),
          const SizedBox(height: 14),
          _buildUnitSection(),
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
          const SizedBox(height: 40),
        ],
      ),
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

  /// بناء حقل رقم الفاتورة التلقائي
  Widget _buildInvoiceNumberField() {
    return Container(
      key: _invoiceNumberFieldKey,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.sales.withValues(alpha: 0.05),
            AppColors.success.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: AppColors.sales.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.sales.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppColors.sales,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رقم الفاتورة',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_isLoadingInvoiceNumber)
                      Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.sales.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'جاري التوليد...',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _generatedInvoiceNumber.isEmpty 
                                  ? 'لم يتم التوليد' 
                                  : _generatedInvoiceNumber,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_generatedInvoiceNumber.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'تلقائي',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'رقم تلقائي تسلسلي يومي • غير قابل للتعديل',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() => Container(
    key: _dateFieldKey,
    child: AppDatePicker(
      label: 'تاريخ البيع',
      selectedDate: _selectedDate,
      onDateSelected: (date) =>
          setState(() => _selectedDate = date ?? DateTime.now()),
    ),
  );

  Widget _buildCustomerSection() => Container(
    key: _customerFieldKey,
    child: CustomerSelector(
      selectedCustomerId: _selectedCustomerId,
      onChanged: (customerId) => setState(() => _selectedCustomerId = customerId),
      customers: widget.customers,
    ),
  );

  Widget _buildQatTypeSection() {
    return Container(
      key: _qatTypeFieldKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نوع القات *',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedQatTypeId,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: 'اختر نوع القات',
                prefixIcon: Icon(Icons.grass_rounded),
              ),
              dropdownColor: AppColors.surface,
              iconEnabledColor: AppColors.sales,
              style: AppTextStyles.bodyMedium,
              items: widget.qatTypes.map((qatType) {
                return DropdownMenuItem(
                  value: qatType.id.toString(),
                  child: Row(
                    children: [
                      Icon(
                        Icons.grass,
                        size: 18,
                        color: AppColors.sales,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        qatType.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _onQatTypeChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى اختيار نوع القات';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUnitSection() {
    // إذا لم يتم اختيار نوع قات، استخدم الوحدات الافتراضية
    final displayUnits = _availableUnits.isEmpty 
        ? ['ربطة', 'كيس', 'كرتون', 'قطعة']
        : _availableUnits;
    
    return Container(
      key: _unitFieldKey,
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
                color: AppColors.sales,
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
            children: displayUnits.map((unit) {
              final isSelected = _selectedUnit == unit;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedUnit = unit;
                  });
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
                              AppColors.sales.withOpacity(0.15),
                              AppColors.sales.withOpacity(0.08),
                            ],
                          )
                        : null,
                    color: isSelected ? null : AppColors.background.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.sales.withOpacity(0.3)
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
                        color: isSelected ? AppColors.sales : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? AppColors.sales : AppColors.textPrimary,
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
    );
  }

  Widget _buildQuantityPriceSection() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface.withOpacity(0.6),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border.withOpacity(0.15)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.sales.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shopping_basket_outlined,
                color: AppColors.sales,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'الكمية والسعر',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          key: _quantityFieldKey,
          child: QuantityInput(
            value: double.tryParse(_quantityController.text) ?? 0.0,
            onChanged: (value) => _quantityController.text = value.toString(),
            label: _selectedUnit != null ? 'الكمية ($_selectedUnit)' : 'الكمية',
          ),
        ),

        const SizedBox(height: 10),

        Container(
          key: _priceFieldKey,
          child: AppTextField.currency(
            controller: _priceController,
            label: _selectedUnit != null
                ? 'السعر لكل $_selectedUnit (ريال)'
                : 'السعر (ريال)',
            hint: 'أدخل السعر',
            validator: (val) => val?.isEmpty == true ? 'مطلوب' : null,
          ),
        ),

        if (_quantityController.text.isNotEmpty &&
            _priceController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calculate_outlined,
                        color: AppColors.success,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'المجموع الفرعي',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${((double.tryParse(_quantityController.text) ?? 0) * (double.tryParse(_priceController.text) ?? 0)).toStringAsFixed(2)} ريال',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );

  Widget _buildPaymentMethodSection() => Container(
    key: _paymentMethodKey,
    child: PaymentMethodSelector(
      selectedMethod: _paymentMethod,
      onChanged: (method) => setState(() => _paymentMethod = method),
    ),
  );

  Widget _buildDiscountSection() => Container(
    key: _discountFieldKey,
    child: AppTextField.currency(
      controller: _discountController,
      label: 'الخصم (ريال)',
      hint: '0',
    ),
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

  Widget _buildNotesSection() => Container(
    key: _notesFieldKey,
    child: AppTextField.multiline(
      controller: _notesController,
      label: 'ملاحظات',
      hint: 'أضف أي ملاحظات إضافية (اختياري)',
      maxLines: 3,
    ),
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
        child: Container(
          key: _saveButtonKey,
          child: AppButton.primary(
            text: widget.initialData != null ? 'حفظ التعديلات' : 'حفظ البيع',
            onPressed: _handleSave,
            fullWidth: true,
          ),
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
        'invoiceNumber': _generatedInvoiceNumber.isEmpty 
            ? null 
            : _generatedInvoiceNumber,
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
