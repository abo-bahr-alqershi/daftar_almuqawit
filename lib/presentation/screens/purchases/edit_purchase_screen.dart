import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/purchase.dart';
import '../../blocs/purchases/purchases_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_date_picker.dart';
import '../../widgets/common/app_dropdown.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/snackbar_widget.dart';
import '../../widgets/common/loading_widget.dart';

/// شاشة تعديل عملية شراء
/// 
/// تسمح بتعديل بيانات عملية شراء موجودة
class EditPurchaseScreen extends StatefulWidget {
  final String purchaseId;

  const EditPurchaseScreen({
    super.key,
    required this.purchaseId,
  });

  @override
  State<EditPurchaseScreen> createState() => _EditPurchaseScreenState();
}

class _EditPurchaseScreenState extends State<EditPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedSupplier;
  String? _selectedQatType;
  String _paymentMethod = 'نقدي';
  bool _isPaid = false;
  Purchase? _originalPurchase;

  @override
  void initState() {
    super.initState();
    _loadPurchase();
  }

  void _loadPurchase() {
    context.read<PurchasesBloc>().add(LoadPurchaseById(widget.purchaseId));
  }

  void _populateFields(Purchase purchase) {
    _originalPurchase = purchase;
    _quantityController.text = purchase.quantity.toString();
    _priceController.text = purchase.pricePerUnit.toString();
    _notesController.text = purchase.notes ?? '';
    _invoiceNumberController.text = purchase.invoiceNumber ?? '';
    _selectedDate = purchase.date;
    _selectedSupplier = purchase.supplierId;
    _selectedQatType = purchase.qatTypeId;
    _paymentMethod = purchase.paymentMethod;
    _isPaid = purchase.isPaid;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _invoiceNumberController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    setState(() {});
  }

  Future<void> _submitPurchase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSupplier == null || _selectedQatType == null) {
      SnackbarWidget.showError(
        context: context,
        message: 'يرجى التأكد من إكمال جميع الحقول المطلوبة',
      );
      return;
    }

    final quantity = double.parse(_quantityController.text);
    final price = double.parse(_priceController.text);

    context.read<PurchasesBloc>().add(
      UpdatePurchase(
        purchaseId: widget.purchaseId,
        supplierId: _selectedSupplier!,
        qatTypeId: _selectedQatType!,
        quantity: quantity,
        pricePerUnit: price,
        paymentMethod: _paymentMethod,
        isPaid: _isPaid,
        date: _selectedDate ?? DateTime.now(),
        invoiceNumber: _invoiceNumberController.text,
        notes: _notesController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل عملية الشراء'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await ConfirmDialog.show(
                context: context,
                title: 'حذف عملية الشراء',
                message: 'هل أنت متأكد من حذف هذه العملية؟ لا يمكن التراجع عن هذا الإجراء.',
                confirmText: 'نعم، حذف',
                cancelText: 'إلغاء',
                isDestructive: true,
              );
              
              if (confirm == true && context.mounted) {
                context.read<PurchasesBloc>().add(DeletePurchase(widget.purchaseId));
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<PurchasesBloc, PurchasesState>(
        listener: (context, state) {
          if (state is PurchaseUpdated) {
            SnackbarWidget.showSuccess(
              context: context,
              message: 'تم تحديث عملية الشراء بنجاح',
            );
            Navigator.of(context).pop(true);
          } else if (state is PurchaseDeleted) {
            SnackbarWidget.showSuccess(
              context: context,
              message: 'تم حذف عملية الشراء بنجاح',
            );
            Navigator.of(context).pop(true);
          } else if (state is PurchasesError) {
            SnackbarWidget.showError(
              context: context,
              message: state.message,
            );
          } else if (state is PurchaseLoaded) {
            _populateFields(state.purchase);
          }
        },
        builder: (context, state) {
          if (state is PurchasesLoading && _originalPurchase == null) {
            return const LoadingWidget(message: 'جاري تحميل البيانات...');
          }

          final isLoading = state is PurchasesLoading;
          final quantity = double.tryParse(_quantityController.text) ?? 0;
          final price = double.tryParse(_priceController.text) ?? 0;
          final total = quantity * price;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // معلومات العملية الأصلية
                if (_originalPurchase != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.info, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.info),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'رقم العملية: ${_originalPurchase!.id}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                'تاريخ الإنشاء: ${_originalPurchase!.createdAt.toString().split(' ')[0]}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // قسم المعلومات الأساسية
                _buildSectionTitle('المعلومات الأساسية'),
                const SizedBox(height: 16),
                
                AppDatePicker(
                  label: 'تاريخ الشراء',
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  required: true,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _invoiceNumberController,
                  label: 'رقم الفاتورة',
                  hint: 'رقم فاتورة المورد',
                  prefixIcon: Icons.receipt_long,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'يرجى إدخال رقم الفاتورة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // اختيار المورد
                AppDropdownField<String>(
                  label: 'المورد',
                  hint: 'اختر المورد',
                  value: _selectedSupplier,
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('مورد 1')),
                    DropdownMenuItem(value: '2', child: Text('مورد 2')),
                    DropdownMenuItem(value: '3', child: Text('مورد 3')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSupplier = value;
                    });
                  },
                  prefixIcon: Icons.person,
                ),
                const SizedBox(height: 24),

                // قسم تفاصيل القات
                _buildSectionTitle('تفاصيل القات'),
                const SizedBox(height: 16),

                AppDropdownField<String>(
                  label: 'نوع القات',
                  hint: 'اختر نوع القات',
                  value: _selectedQatType,
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('عيسائي')),
                    DropdownMenuItem(value: '2', child: Text('يافعي')),
                    DropdownMenuItem(value: '3', child: Text('حريري')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedQatType = value;
                    });
                  },
                  prefixIcon: Icons.grass,
                ),
                const SizedBox(height: 16),

                AppTextField.number(
                  controller: _quantityController,
                  label: 'الكمية (كيس)',
                  hint: 'أدخل عدد الأكياس',
                  prefixIcon: Icons.inventory,
                  onChanged: (_) => _calculateTotal(),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'يرجى إدخال الكمية';
                    }
                    final quantity = double.tryParse(value!);
                    if (quantity == null || quantity <= 0) {
                      return 'يرجى إدخال كمية صحيحة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                AppTextField.currency(
                  controller: _priceController,
                  label: 'سعر الكيس الواحد',
                  hint: 'أدخل السعر',
                  onChanged: (_) => _calculateTotal(),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'يرجى إدخال السعر';
                    }
                    final price = double.tryParse(value!);
                    if (price == null || price <= 0) {
                      return 'يرجى إدخال سعر صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // عرض المجموع
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المجموع الكلي:',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${total.toStringAsFixed(2)} ريال',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // قسم الدفع
                _buildSectionTitle('معلومات الدفع'),
                const SizedBox(height: 16),

                AppDropdownField<String>(
                  label: 'طريقة الدفع',
                  hint: 'اختر طريقة الدفع',
                  value: _paymentMethod,
                  items: const [
                    DropdownMenuItem(value: 'نقدي', child: Text('نقدي')),
                    DropdownMenuItem(value: 'آجل', child: Text('آجل')),
                    DropdownMenuItem(value: 'شيك', child: Text('شيك')),
                    DropdownMenuItem(value: 'تحويل بنكي', child: Text('تحويل بنكي')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                      if (_paymentMethod == 'نقدي') {
                        _isPaid = true;
                      }
                    });
                  },
                  prefixIcon: Icons.payment,
                ),
                const SizedBox(height: 16),

                CheckboxListTile(
                  title: Text(
                    'تم الدفع',
                    style: AppTextStyles.bodyMedium,
                  ),
                  value: _isPaid,
                  onChanged: (value) {
                    setState(() {
                      _isPaid = value ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tileColor: AppColors.surface,
                ),
                const SizedBox(height: 24),

                // قسم الملاحظات
                _buildSectionTitle('ملاحظات إضافية'),
                const SizedBox(height: 16),

                AppTextField.multiline(
                  controller: _notesController,
                  label: 'ملاحظات',
                  hint: 'أضف أي ملاحظات أو تفاصيل إضافية',
                  maxLines: 4,
                ),
                const SizedBox(height: 32),

                // أزرار الحفظ والإلغاء
                Row(
                  children: [
                    Expanded(
                      child: AppButton.secondary(
                        text: 'إلغاء',
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: AppButton.primary(
                        text: 'حفظ التعديلات',
                        icon: Icons.save,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _submitPurchase,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
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
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
