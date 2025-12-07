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

/// نموذج إضافة/تعديل عملية بيع - تصميم راقي واحترافي
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
  final _paidAmountController = TextEditingController();
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
  DateTime? _dueDate;
  String? _selectedCustomerId;
  String? _selectedQatTypeId;
  String? _selectedUnit;
  String _paymentMethod = 'نقد';
  double _totalAmount = 0;
  double _remainingAmount = 0;

  List<String> _availableUnits = [];
  Map<String, double?> _unitSellPrices = {};
  String _generatedInvoiceNumber = '';
  bool _isLoadingInvoiceNumber = false;

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
    _paidAmountController.addListener(_calculateTotal);
    _selectedUnit = 'ربطة';

    if (widget.initialData == null) {
      _generateInvoiceNumber();
    } else {
      _generatedInvoiceNumber = widget.initialData!['invoiceNumber'] ?? '';
      _invoiceNumberController.text = _generatedInvoiceNumber;
    }
  }

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
      if (mounted) setState(() => _isLoadingInvoiceNumber = false);
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
      _paymentMethod = data['paymentMethod'] ?? 'نقد';
      _paidAmountController.text = data['paidAmount']?.toString() ?? '0';
      if (data['dueDate'] != null) {
        _dueDate = DateTime.tryParse(data['dueDate'] as String);
      }
    } else {
      _discountController.text = '0';
      _paidAmountController.text = '0';
    }
  }

  void _calculateTotal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final paid = double.tryParse(_paidAmountController.text) ?? 0.0;

    setState(() {
      _totalAmount = (quantity * price) - discount;
      _remainingAmount = (_totalAmount - paid).clamp(0, double.infinity);
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    _invoiceNumberController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildInvoiceNumberSection(),
          const SizedBox(height: 16),
          _buildDateSection(),
          const SizedBox(height: 16),
          _buildCustomerSection(),
          const SizedBox(height: 16),
          _buildQatTypeSection(),
          const SizedBox(height: 16),
          _buildUnitSection(),
          const SizedBox(height: 16),
          _buildQuantityPriceSection(),
          const SizedBox(height: 16),
          _buildPaymentSection(),
          const SizedBox(height: 16),
          _buildDiscountSection(),
          const SizedBox(height: 16),
          _buildPaidAmountSection(),
          const SizedBox(height: 16),
          _buildDueDateSection(),
          const SizedBox(height: 20),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.shopping_cart_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.initialData != null
                      ? 'تعديل عملية بيع'
                      : 'إضافة عملية بيع',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أدخل تفاصيل عملية البيع',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    Color iconColor = const Color(0xFF10B981),
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInvoiceNumberSection() {
    return Container(
      key: _invoiceNumberFieldKey,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF10B981),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'رقم الفاتورة',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 4),
                _isLoadingInvoiceNumber
                    ? Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: const Color(0xFF10B981).withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'جاري التوليد...',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _generatedInvoiceNumber.isEmpty
                            ? 'لم يتم التوليد'
                            : _generatedInvoiceNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Color(0xFF10B981), size: 14),
                SizedBox(width: 4),
                Text(
                  'تلقائي',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
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
    return Container(
      key: _dateFieldKey,
      child: _buildSection(
        title: 'تاريخ البيع',
        icon: Icons.calendar_today_rounded,
        iconColor: const Color(0xFF3B82F6),
        child: AppDatePicker(
          label: '',
          selectedDate: _selectedDate,
          onDateSelected: (date) =>
              setState(() => _selectedDate = date ?? DateTime.now()),
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Container(
      key: _customerFieldKey,
      child: _buildSection(
        title: 'العميل',
        icon: Icons.person_rounded,
        iconColor: const Color(0xFF6366F1),
        child: CustomerSelector(
          selectedCustomerId: _selectedCustomerId,
          onChanged: (id) => setState(() => _selectedCustomerId = id),
          customers: widget.customers,
        ),
      ),
    );
  }

  Widget _buildQatTypeSection() {
    return Container(
      key: _qatTypeFieldKey,
      child: _buildSection(
        title: 'نوع القات',
        icon: Icons.grass_rounded,
        child: DropdownButtonFormField<String>(
          value: _selectedQatTypeId,
          decoration: InputDecoration(
            hintText: 'اختر نوع القات',
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF10B981),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items: widget.qatTypes.map((qatType) {
            return DropdownMenuItem(
              value: qatType.id.toString(),
              child: Text(qatType.name),
            );
          }).toList(),
          onChanged: (value) => _onQatTypeChanged(value),
          validator: (value) =>
              value == null || value.isEmpty ? 'يرجى اختيار نوع القات' : null,
        ),
      ),
    );
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
        } else {
          _availableUnits = ['ربطة', 'علاقية', 'كيلو'];
        }

        if (selectedQatType.unitPrices != null) {
          for (final unit in _availableUnits) {
            final unitPrice = selectedQatType.unitPrices![unit];
            _unitSellPrices[unit] = unitPrice?.sellPrice;
          }
        } else if (selectedQatType.defaultSellPrice != null) {
          for (final unit in _availableUnits) {
            _unitSellPrices[unit] = selectedQatType.defaultSellPrice;
          }
        }

        if (_availableUnits.isNotEmpty) {
          _selectedUnit = _availableUnits.first;
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

  Widget _buildUnitSection() {
    final displayUnits = _availableUnits.isEmpty
        ? ['ربطة', 'علاقية', 'كيلو']
        : _availableUnits;

    return Container(
      key: _unitFieldKey,
      child: _buildSection(
        title: 'الوحدة',
        icon: Icons.straighten_rounded,
        iconColor: const Color(0xFFF59E0B),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: displayUnits.map((unit) {
            final isSelected = _selectedUnit == unit;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _onUnitChanged(unit);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF10B981) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getUnitIcon(unit),
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getUnitIcon(String unit) {
    switch (unit) {
      case 'ربطة':
        return Icons.shopping_bag_rounded;
      case 'علاقية':
        return Icons.inventory_2_rounded;
      case 'كيلو':
        return Icons.scale_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildQuantityPriceSection() {
    return _buildSection(
      title: 'الكمية والسعر',
      icon: Icons.calculate_rounded,
      iconColor: const Color(0xFF6366F1),
      child: Column(
        children: [
          Container(
            key: _quantityFieldKey,
            child: QuantityInput(
              value: double.tryParse(_quantityController.text) ?? 0.0,
              onChanged: (value) => _quantityController.text = value.toString(),
              label: _selectedUnit != null
                  ? 'الكمية ($_selectedUnit)'
                  : 'الكمية',
            ),
          ),
          const SizedBox(height: 14),
          Container(
            key: _priceFieldKey,
            child: AppTextField.currency(
              controller: _priceController,
              label: _selectedUnit != null
                  ? 'السعر لكل $_selectedUnit (ر.ي)'
                  : 'السعر (ر.ي)',
              hint: 'أدخل السعر',
              validator: (val) => val?.isEmpty == true ? 'مطلوب' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      key: _paymentMethodKey,
      child: _buildSection(
        title: 'طريقة الدفع',
        icon: Icons.payment_rounded,
        iconColor: const Color(0xFF3B82F6),
        child: PaymentMethodSelector(
          selectedMethod: _paymentMethod,
          onChanged: (method) => setState(() => _paymentMethod = method),
        ),
      ),
    );
  }

  Widget _buildDiscountSection() {
    return Container(
      key: _discountFieldKey,
      child: _buildSection(
        title: 'الخصم',
        icon: Icons.discount_rounded,
        iconColor: const Color(0xFFDC2626),
        child: AppTextField.currency(
          controller: _discountController,
          label: 'الخصم (ر.ي)',
          hint: '0',
        ),
      ),
    );
  }

  Widget _buildPaidAmountSection() {
    return _buildSection(
      title: 'المبلغ المدفوع',
      icon: Icons.payments_rounded,
      iconColor: const Color(0xFF10B981),
      child: AppTextField.currency(
        controller: _paidAmountController,
        label: 'المبلغ المدفوع',
        hint: '0.00',
        validator: (value) {
          final paid = double.tryParse(value ?? '0') ?? 0;
          if (paid < 0) return 'مبلغ غير صحيح';
          if (paid > _totalAmount) return 'المبلغ المدفوع أكبر من الإجمالي';
          return null;
        },
      ),
    );
  }

  Widget _buildDueDateSection() {
    return _buildSection(
      title: 'تاريخ الاستحقاق',
      icon: Icons.event_rounded,
      iconColor: const Color(0xFFF59E0B),
      child: AppDatePicker(
        label: '',
        selectedDate: _dueDate,
        firstDate: DateTime.now(),
        onDateSelected: (date) => setState(() => _dueDate = date),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final subtotal = quantity * price;
    final total = subtotal - discount;
    final paid = double.tryParse(_paidAmountController.text) ?? 0.0;
    final remaining = (total - paid).clamp(0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.08),
            const Color(0xFF10B981).withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('المجموع الفرعي', subtotal),
          const SizedBox(height: 10),
          _buildSummaryRow('الخصم', discount, isNegative: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildSummaryRow('الإجمالي', total, isTotal: true),
          const SizedBox(height: 10),
          _buildSummaryRow('المدفوع', paid, color: const Color(0xFF10B981)),
          const SizedBox(height: 6),
          _buildSummaryRow(
            'المتبقي',
            remaining.toDouble(),
            color: remaining > 0
                ? const Color(0xFFDC2626)
                : const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value, {
    bool isTotal = false,
    bool isNegative = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        Text(
          '${isNegative ? '-' : ''}${value.toStringAsFixed(0)} ر.ي',
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.w700,
            color:
                color ??
                (isTotal ? const Color(0xFF10B981) : const Color(0xFF1A1A2E)),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      key: _notesFieldKey,
      child: _buildSection(
        title: 'ملاحظات',
        icon: Icons.note_rounded,
        iconColor: const Color(0xFF9CA3AF),
        child: AppTextField.multiline(
          controller: _notesController,
          label: '',
          hint: 'أضف أي ملاحظات إضافية (اختياري)',
          maxLines: 3,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (widget.onCancel != null) ...[
          Expanded(child: _buildSecondaryButton('إلغاء', widget.onCancel)),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 2,
          child: Container(
            key: _saveButtonKey,
            child: _buildPrimaryButton(
              widget.initialData != null ? 'حفظ التعديلات' : 'حفظ البيع',
              widget.initialData != null
                  ? Icons.save_rounded
                  : Icons.check_rounded,
              _handleSave,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: const Color(0xFF10B981),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String label, VoidCallback? onTap) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    if (_selectedQatTypeId == null) {
      _showError('الرجاء اختيار نوع القات');
      return;
    }

    if (_selectedUnit == null) {
      _showError('الرجاء اختيار الوحدة');
      return;
    }

    HapticFeedback.mediumImpact();

    final quantity = double.parse(_quantityController.text);
    final price = double.parse(_priceController.text);
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final rawPaid = double.tryParse(_paidAmountController.text) ?? 0.0;
    final total = (quantity * price) - discount;
    final paidAmount = rawPaid.clamp(0, total);
    final remaining = total - paidAmount;

    // Check stock availability
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
        _showStockWarning(stockCheck);
        return;
      }
    } catch (e) {
      if (!mounted) return;
      _showError('خطأ في التحقق من المخزون: $e');
      return;
    }

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
      'totalAmount': total,
      'discount': discount,
      'paymentMethod': _paymentMethod,
      'paidAmount': paidAmount,
      'remainingAmount': remaining,
      'dueDate': _dueDate?.toIso8601String().split('T')[0],
      'invoiceNumber': _generatedInvoiceNumber.isEmpty
          ? null
          : _generatedInvoiceNumber,
      'notes': _notesController.text.isEmpty ? null : _notesController.text,
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showStockWarning(dynamic stockCheck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Color(0xFFF59E0B),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'تحذير: نقص في المخزون',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stockCheck.message,
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا يمكن إتمام عملية البيع. يرجى شراء كمية إضافية أو تقليل الكمية المطلوبة.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
