import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../domain/entities/purchase.dart';
import '../../../../domain/entities/supplier.dart';
import '../../../../domain/entities/qat_type.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_date_picker.dart';
import 'supplier_selector.dart';
import 'cost_calculator.dart';

/// نموذج إضافة أو تعديل عملية شراء
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
  State<PurchaseForm> createState() => _PurchaseFormState();
}

class _PurchaseFormState extends State<PurchaseForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _paidAmountController;
  late final TextEditingController _invoiceNumberController;
  late final TextEditingController _notesController;

  int? _selectedSupplierId;
  int? _selectedQatTypeId;
  String _selectedUnit = 'ربطة';
  String _paymentMethod = 'نقد';
  List<String> _availableUnits = ['ربطة', 'كيس', 'كرتون', 'قطعة'];
  Map<String, double?> _unitBuyPrices = {};
  String _paymentStatus = 'مدفوع';
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;
  bool _isSubmitting = false;
  double _totalAmount = 0;
  double _remainingAmount = 0;

  final List<String> _units = ['ربطة', 'كيس', 'كرتون', 'قطعة'];
  final List<String> _paymentMethods = ['نقد', 'آجل', 'حوالة', 'تحويل'];
  final List<String> _paymentStatuses = ['مدفوع', 'مدفوع جزئياً', 'غير مدفوع'];

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
      _onQatTypeChanged(_selectedQatTypeId?.toString());
      _calculateTotal();
    }

    _quantityController.addListener(_calculateTotal);
    _unitPriceController.addListener(_calculateTotal);
    _paidAmountController.addListener(_calculateTotal);
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
      _availableUnits = ['ربطة', 'كيس', 'كرتون', 'قطعة'];
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار المورد'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      if (_selectedQatTypeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار نوع القات'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      final selectedSupplier = widget.suppliers
          .firstWhere((s) => s.id == _selectedSupplierId);
      final selectedQatType = widget.qatTypes
          .firstWhere((qt) => qt.id == _selectedQatTypeId);

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
        invoiceNumber: _invoiceNumberController.text.trim().isEmpty
            ? null
            : _invoiceNumberController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        status: 'نشط',
        createdAt: widget.purchase?.createdAt ?? DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      widget.onSubmit(purchase);

      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.purchase == null ? 'إضافة عملية شراء جديدة' : 'تعديل عملية الشراء',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceL),

            SupplierSelector(
              selectedSupplierId: _selectedSupplierId?.toString(),
              suppliers: widget.suppliers,
              onChanged: (id) {
                setState(() => _selectedSupplierId = int.tryParse(id ?? ''));
              },
            ),
            const SizedBox(height: AppDimensions.spaceM),

            AppDatePicker(
              label: 'تاريخ الشراء',
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() => _selectedDate = date ?? DateTime.now());
              },
            ),
            const SizedBox(height: AppDimensions.spaceM),

            // قسم اختيار نوع القات
            _buildQatTypeSection(),
            const SizedBox(height: AppDimensions.spaceM),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppTextField.number(
                    controller: _quantityController,
                    label: 'الكمية *',
                    hint: '0',
                    prefixIcon: Icons.inventory_2,
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
                const SizedBox(width: AppDimensions.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الوحدة',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(color: AppColors.border, width: 1.5),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedUnit,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                              vertical: AppDimensions.paddingS,
                            ),
                          ),
                          items: _availableUnits.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit, style: AppTextStyles.bodyMedium),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _onUnitChanged(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceM),

            AppTextField.currency(
              controller: _unitPriceController,
              label: 'سعر الوحدة *',
              hint: '0.00',
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
            const SizedBox(height: AppDimensions.spaceM),

            CostCalculator(
              totalAmount: _totalAmount,
              paidAmount: double.tryParse(_paidAmountController.text) ?? 0,
              remainingAmount: _remainingAmount,
            ),
            const SizedBox(height: AppDimensions.spaceM),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طريقة الدفع',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _paymentMethods.map((method) {
                    final isSelected = _paymentMethod == method;
                    return ChoiceChip(
                      label: Text(method),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _paymentMethod = method);
                      },
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceM),

            AppTextField.currency(
              controller: _paidAmountController,
              label: 'المبلغ المدفوع',
              hint: '0.00',
              validator: (value) {
                final paid = double.tryParse(value ?? '0') ?? 0;
                if (paid < 0) {
                  return 'مبلغ غير صحيح';
                }
                if (paid > _totalAmount) {
                  return 'المبلغ المدفوع أكبر من الإجمالي';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spaceM),

            if (_paymentMethod == 'آجل' || _remainingAmount > 0) ...[
              AppDatePicker(
                label: 'تاريخ الاستحقاق',
                selectedDate: _dueDate,
                firstDate: DateTime.now(),
                onDateSelected: (date) {
                  setState(() => _dueDate = date);
                },
              ),
              const SizedBox(height: AppDimensions.spaceM),
            ],

            AppTextField(
              controller: _invoiceNumberController,
              label: 'رقم الفاتورة (اختياري)',
              hint: 'أدخل رقم الفاتورة',
              prefixIcon: Icons.receipt_long,
            ),
            const SizedBox(height: AppDimensions.spaceM),

            AppTextField.multiline(
              controller: _notesController,
              label: 'ملاحظات (اختياري)',
              hint: 'أدخل ملاحظات إضافية',
              maxLines: 3,
            ),
            const SizedBox(height: AppDimensions.spaceXL),

            Row(
              children: [
                if (widget.onCancel != null) ...[
                  Expanded(
                    child: AppButton.secondary(
                      text: 'إلغاء',
                      onPressed: _isSubmitting ? null : widget.onCancel,
                      fullWidth: true,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceM),
                ],
                Expanded(
                  flex: 2,
                  child: AppButton.primary(
                    text: widget.purchase == null ? 'إضافة' : 'حفظ التعديلات',
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    isLoading: _isSubmitting,
                    icon: widget.purchase == null ? Icons.add : Icons.save,
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQatTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع القات',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedQatTypeId?.toString(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              hintText: 'اختر نوع القات',
            ),
            items: widget.qatTypes.map((qatType) {
              return DropdownMenuItem(
                value: qatType.id.toString(),
                child: Text(qatType.name, style: AppTextStyles.bodyMedium),
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
    );
  }
}
