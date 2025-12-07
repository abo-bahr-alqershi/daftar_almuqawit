import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../data/datasources/local/purchase_local_datasource.dart';
import '../../../../domain/entities/purchase.dart';
import '../../../../domain/entities/supplier.dart';
import '../../../../domain/entities/qat_type.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_date_picker.dart';
import 'supplier_selector.dart';
import 'cost_calculator.dart';

/// نموذج إضافة أو تعديل عملية شراء - تصميم راقي
class PurchaseForm extends StatefulWidget {
  final Purchase? purchase;
  final List<Supplier> suppliers;
  final List<QatType> qatTypes;
  final void Function(Purchase) onSubmit;
  final VoidCallback? onCancel;

  const PurchaseForm({
    super.key,
    this.purchase,
    required this.suppliers,
    required this.qatTypes,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  PurchaseFormState createState() => PurchaseFormState();
}

class PurchaseFormState extends State<PurchaseForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _paidAmountController;
  late final TextEditingController _invoiceNumberController;
  late final TextEditingController _notesController;

  // مفاتيح التعليمات
  final _invoiceNumberFieldKey = GlobalKey();
  final _supplierFieldKey = GlobalKey();
  final _dateFieldKey = GlobalKey();
  final _qatTypeFieldKey = GlobalKey();
  final _quantityFieldKey = GlobalKey();
  final _unitFieldKey = GlobalKey();
  final _priceFieldKey = GlobalKey();
  final _paymentMethodKey = GlobalKey();
  final _paidAmountKey = GlobalKey();
  final _saveButtonKey = GlobalKey();

  int? _selectedSupplierId;
  int? _selectedQatTypeId;
  String _selectedUnit = 'ربطة';
  String _paymentMethod = 'نقد';
  List<String> _availableUnits = ['ربطة', 'علاقية', 'كيلو'];
  Map<String, double?> _unitBuyPrices = {};
  String _paymentStatus = 'مدفوع';
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;
  bool _isSubmitting = false;
  double _totalAmount = 0;
  double _remainingAmount = 0;
  String _generatedInvoiceNumber = '';
  bool _isLoadingInvoiceNumber = false;

  final List<String> _units = ['ربطة', 'علاقية', 'كيلو'];
  final List<String> _paymentMethods = ['نقد', 'اجل', 'حوالة', 'محفظة'];
  final List<String> _paymentStatuses = ['مدفوع', 'مدفوع جزئياً', 'غير مدفوع'];

  Map<String, GlobalKey> get tutorialKeys => {
    'invoiceNumber': _invoiceNumberFieldKey,
    'supplier': _supplierFieldKey,
    'date': _dateFieldKey,
    'qatType': _qatTypeFieldKey,
    'quantity': _quantityFieldKey,
    'unit': _unitFieldKey,
    'price': _priceFieldKey,
    'paymentMethod': _paymentMethodKey,
    'paidAmount': _paidAmountKey,
    'saveButton': _saveButtonKey,
  };

  void showTutorial(
    BuildContext context,
    ScrollController? scrollController, {
    bool isEdit = false,
  }) {}

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.purchase?.quantity.toString() ?? '',
    );
    _unitPriceController = TextEditingController(
      text: widget.purchase?.unitPrice.toString() ?? '',
    );
    _paidAmountController = TextEditingController(
      text: widget.purchase?.paidAmount.toString() ?? '0',
    );
    _invoiceNumberController = TextEditingController(
      text: widget.purchase?.invoiceNumber ?? '',
    );
    _notesController = TextEditingController(
      text: widget.purchase?.notes ?? '',
    );

    if (widget.purchase != null) {
      _selectedSupplierId = widget.purchase!.supplierId;
      _selectedQatTypeId = widget.purchase!.qatTypeId;
      _selectedUnit = widget.purchase!.unit;
      _paymentMethod = widget.purchase!.paymentMethod;
      _paymentStatus = widget.purchase!.paymentStatus;
      _selectedDate = DateTime.parse(widget.purchase!.date);
      if (widget.purchase!.dueDate != null) {
        _dueDate = DateTime.parse(widget.purchase!.dueDate!);
      }
      _generatedInvoiceNumber = widget.purchase!.invoiceNumber ?? '';
      _onQatTypeChanged(_selectedQatTypeId?.toString());
      _calculateTotal();
    } else {
      _generateInvoiceNumber();
    }

    _quantityController.addListener(_calculateTotal);
    _unitPriceController.addListener(_calculateTotal);
    _paidAmountController.addListener(_calculateTotal);
  }

  Future<void> _generateInvoiceNumber() async {
    setState(() => _isLoadingInvoiceNumber = true);

    try {
      final dataSource = getIt<PurchaseLocalDataSource>();
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

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    _paidAmountController.dispose();
    _invoiceNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onQatTypeChanged(String? qatTypeId) {
    setState(() {
      _selectedQatTypeId = qatTypeId != null ? int.tryParse(qatTypeId) : null;
      _selectedUnit = 'ربطة';
      _availableUnits = ['ربطة', 'علاقية', 'كيلو'];
      _unitBuyPrices = {};
      _unitPriceController.clear();

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
              _unitBuyPrices[unit] = unitPrice?.buyPrice;
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
      _selectedUnit = unit ?? 'ربطة';
      if (unit != null && _unitBuyPrices.containsKey(unit)) {
        final defaultPrice = _unitBuyPrices[unit];
        if (defaultPrice != null && defaultPrice > 0) {
          _unitPriceController.text = defaultPrice.toString();
        }
      }
    });
  }

  void _calculateTotal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    final paidAmount = double.tryParse(_paidAmountController.text) ?? 0;

    setState(() {
      _totalAmount = quantity * unitPrice;
      _remainingAmount = _totalAmount - paidAmount;

      if (_remainingAmount > 0) {
        _paymentStatus = paidAmount > 0 ? 'مدفوع جزئياً' : 'غير مدفوع';
      } else {
        _paymentStatus = 'مدفوع';
      }
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedSupplierId == null) {
        HapticFeedback.lightImpact();
        _showWarningSnackBar('يرجى اختيار المورد');
        return;
      }

      if (_selectedQatTypeId == null) {
        HapticFeedback.lightImpact();
        _showWarningSnackBar('يرجى اختيار نوع القات');
        return;
      }

      HapticFeedback.mediumImpact();
      setState(() => _isSubmitting = true);

      final selectedSupplier = widget.suppliers.firstWhere(
        (s) => s.id == _selectedSupplierId,
      );
      final selectedQatType = widget.qatTypes.firstWhere(
        (qt) => qt.id == _selectedQatTypeId,
      );

      final purchase = Purchase(
        id: widget.purchase?.id,
        date: _selectedDate.toIso8601String().split('T')[0],
        time: TimeOfDay.now().format(context),
        supplierId: _selectedSupplierId,
        supplierName: selectedSupplier.name,
        qatTypeId: _selectedQatTypeId,
        qatTypeName: selectedQatType.name,
        quantity: double.parse(_quantityController.text),
        unit: _selectedUnit,
        unitPrice: double.parse(_unitPriceController.text),
        totalAmount: _totalAmount,
        paymentMethod: _paymentMethod,
        paymentStatus: _paymentStatus,
        paidAmount: double.tryParse(_paidAmountController.text) ?? 0,
        remainingAmount: _remainingAmount,
        dueDate: _dueDate?.toIso8601String().split('T')[0],
        invoiceNumber: _generatedInvoiceNumber.isEmpty
            ? null
            : _generatedInvoiceNumber,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        status: 'نشط',
        createdAt:
            widget.purchase?.createdAt ?? DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      widget.onSubmit(purchase);
      setState(() => _isSubmitting = false);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildInvoiceSection(),
            const SizedBox(height: 20),
            _buildSupplierSection(),
            const SizedBox(height: 20),
            _buildDateSection(),
            const SizedBox(height: 20),
            _buildQatTypeSection(),
            const SizedBox(height: 20),
            _buildQuantityPriceSection(),
            const SizedBox(height: 20),
            _buildCostSummary(),
            const SizedBox(height: 20),
            _buildPaymentSection(),
            const SizedBox(height: 20),
            _buildNotesSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
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
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.purchase == null
                      ? 'إضافة عملية شراء'
                      : 'تعديل عملية الشراء',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.purchase == null
                      ? 'املأ البيانات التالية بدقة'
                      : 'قم بتعديل البيانات المطلوبة',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
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
    Color iconColor = const Color(0xFF8B5CF6),
    required Widget child,
    GlobalKey? sectionKey,
  }) {
    return Container(
      key: sectionKey,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildInvoiceSection() {
    return _buildSection(
      title: 'رقم الفاتورة',
      icon: Icons.receipt_long_outlined,
      iconColor: const Color(0xFF0EA5E9),
      sectionKey: _invoiceNumberFieldKey,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'رقم تسلسلي تلقائي',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
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
                            color: const Color(0xFF0EA5E9),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'جاري التوليد...',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      _generatedInvoiceNumber.isEmpty
                          ? 'لم يتم التوليد'
                          : _generatedInvoiceNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0EA5E9),
                        letterSpacing: 1,
                      ),
                    ),
                ],
              ),
            ),
            if (_generatedInvoiceNumber.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'تلقائي',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierSection() {
    return Container(
      key: _supplierFieldKey,
      child: _buildSection(
        title: 'المورد',
        icon: Icons.person_outline,
        iconColor: const Color(0xFF8B5CF6),
        child: SupplierSelector(
          selectedSupplierId: _selectedSupplierId?.toString(),
          suppliers: widget.suppliers,
          onChanged: (id) {
            HapticFeedback.selectionClick();
            setState(() => _selectedSupplierId = int.tryParse(id ?? ''));
          },
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Container(
      key: _dateFieldKey,
      child: _buildSection(
        title: 'تاريخ الشراء',
        icon: Icons.calendar_today_outlined,
        iconColor: const Color(0xFFF59E0B),
        child: GestureDetector(
          onTap: () async {
            HapticFeedback.selectionClick();
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(Icons.event, size: 20, color: const Color(0xFFF59E0B)),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Color(0xFF9CA3AF)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQatTypeSection() {
    return Container(
      key: _qatTypeFieldKey,
      child: _buildSection(
        title: 'نوع القات',
        icon: Icons.grass_outlined,
        iconColor: const Color(0xFF16A34A),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedQatTypeId?.toString(),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintText: 'اختر نوع القات',
                  prefixIcon: Icon(Icons.grass, color: Color(0xFF16A34A)),
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
                items: widget.qatTypes.map((qatType) {
                  return DropdownMenuItem(
                    value: qatType.id.toString(),
                    child: Text(qatType.name),
                  );
                }).toList(),
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  _onQatTypeChanged(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى اختيار نوع القات';
                  }
                  return null;
                },
              ),
            ),
            if (_selectedQatTypeId != null) ...[
              const SizedBox(height: 12),
              _buildUnitSelector(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUnitSelector() {
    return Container(
      key: _unitFieldKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الوحدة',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableUnits.map((unit) {
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
                    color: isSelected
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF16A34A).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF16A34A).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF16A34A),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityPriceSection() {
    return _buildSection(
      title: 'الكمية والسعر',
      icon: Icons.calculate_outlined,
      iconColor: const Color(0xFF8B5CF6),
      child: Column(
        children: [
          Container(
            key: _quantityFieldKey,
            child: _buildTextField(
              controller: _quantityController,
              label: 'الكمية',
              hint: 'أدخل الكمية',
              icon: Icons.inventory_2_outlined,
              keyboardType: TextInputType.number,
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الكمية مطلوبة';
                }
                final quantity = double.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'كمية غير صحيحة';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 14),
          Container(
            key: _priceFieldKey,
            child: _buildTextField(
              controller: _unitPriceController,
              label: 'سعر الوحدة',
              hint: 'أدخل سعر الوحدة',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              isRequired: true,
              suffixText: 'ر.ي',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'السعر مطلوب';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'سعر غير صحيح';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostSummary() {
    return CostCalculator(
      totalAmount: _totalAmount,
      paidAmount: double.tryParse(_paidAmountController.text) ?? 0,
      remainingAmount: _remainingAmount,
    );
  }

  Widget _buildPaymentSection() {
    return _buildSection(
      title: 'معلومات الدفع',
      icon: Icons.payment_outlined,
      iconColor: const Color(0xFF3B82F6),
      sectionKey: _paymentMethodKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'طريقة الدفع',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _paymentMethods.map((method) {
              final isSelected = _paymentMethod == method;
              final color = _getPaymentMethodColor(method);

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _paymentMethod = method);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? color : color.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPaymentMethodIcon(method),
                        size: 16,
                        color: isSelected ? Colors.white : color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        method,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Container(
            key: _paidAmountKey,
            child: _buildTextField(
              controller: _paidAmountController,
              label: 'المبلغ المدفوع',
              hint: '0',
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
              suffixText: 'ر.ي',
              validator: (value) {
                final paid = double.tryParse(value ?? '0') ?? 0;
                if (paid < 0) return 'مبلغ غير صحيح';
                if (paid > _totalAmount)
                  return 'المبلغ المدفوع أكبر من الإجمالي';
                return null;
              },
            ),
          ),
          if (_paymentMethod == 'آجل' || _remainingAmount > 0) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () async {
                HapticFeedback.selectionClick();
                final date = await showDatePicker(
                  context: context,
                  initialDate:
                      _dueDate ?? DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _dueDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_available,
                      size: 20,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تاريخ الاستحقاق',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _dueDate != null
                                ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                : 'اختر التاريخ',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildSection(
      title: 'ملاحظات',
      icon: Icons.notes_outlined,
      iconColor: const Color(0xFF6B7280),
      child: _buildTextField(
        controller: _notesController,
        label: 'ملاحظات إضافية',
        hint: 'أدخل ملاحظات (اختياري)',
        icon: Icons.edit_note_outlined,
        maxLines: 3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = false,
    String? suffixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
            ),
            suffixText: suffixText,
            suffixStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
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
                color: Color(0xFF8B5CF6),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (widget.onCancel != null) ...[
          Expanded(
            child: _buildSecondaryButton(
              label: 'إلغاء',
              onTap: _isSubmitting ? null : widget.onCancel,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: widget.onCancel != null ? 2 : 1,
          child: Container(
            key: _saveButtonKey,
            child: _buildPrimaryButton(
              label: widget.purchase == null ? 'إضافة الشراء' : 'حفظ التعديلات',
              icon: widget.purchase == null
                  ? Icons.add_shopping_cart
                  : Icons.save_outlined,
              isLoading: _isSubmitting,
              onTap: _isSubmitting ? null : _handleSubmit,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required bool isLoading,
    VoidCallback? onTap,
  }) {
    return Material(
      color: onTap == null ? const Color(0xFFD1D5DB) : const Color(0xFF8B5CF6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
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

  Widget _buildSecondaryButton({required String label, VoidCallback? onTap}) {
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

  Color _getPaymentMethodColor(String method) {
    switch (method) {
      case 'نقد':
        return const Color(0xFF16A34A);
      case 'محفظة':
        return const Color(0xFF0EA5E9);
      case 'حوالة':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'نقد':
        return Icons.money;
      case 'محفظة':
        return Icons.account_balance_wallet;
      case 'حوالة':
        return Icons.send;
      default:
        return Icons.payment;
    }
  }
}
