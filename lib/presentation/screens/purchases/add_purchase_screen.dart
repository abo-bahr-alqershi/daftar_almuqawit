import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/purchase.dart';
import '../../blocs/purchases/purchases_bloc.dart';
import '../../blocs/purchases/purchases_event.dart';
import '../../blocs/purchases/purchases_state.dart';
import '../../blocs/suppliers/suppliers_bloc.dart';
import '../../blocs/suppliers/suppliers_event.dart';
import '../../blocs/suppliers/suppliers_state.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_date_picker.dart';
import '../../widgets/common/app_dropdown.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/snackbar_widget.dart';

/// شاشة إضافة عملية شراء
/// 
/// تسمح بإضافة عملية شراء جديدة مع كافة التفاصيل
class AddPurchaseScreen extends StatefulWidget {
  const AddPurchaseScreen({super.key});

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
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

  @override
  void initState() {
    super.initState();
    // تحميل الموردين وأنواع القات عند فتح الشاشة
    context.read<SuppliersBloc>().add(LoadSuppliers());
    context.read<QatTypesBloc>().add(LoadQatTypes());
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
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final total = quantity * price;
    setState(() {});
  }

  Future<void> _submitPurchase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSupplier == null) {
      SnackbarWidget.showError(
        context: context,
        message: 'يرجى اختيار المورد',
      );
      return;
    }

    if (_selectedQatType == null) {
      SnackbarWidget.showError(
        context: context,
        message: 'يرجى اختيار نوع القات',
      );
      return;
    }

    final quantity = double.parse(_quantityController.text);
    final price = double.parse(_priceController.text);

    context.read<PurchasesBloc>().add(
      AddPurchaseEvent(
        Purchase(
          date: (_selectedDate ?? DateTime.now()).toString().split(' ')[0],
          time: TimeOfDay.now().format(context),
          supplierId: int.tryParse(_selectedSupplier ?? '0'),
          qatTypeId: int.tryParse(_selectedQatType ?? '0'),
          quantity: quantity,
          unitPrice: price,
          totalAmount: quantity * price,
          paymentMethod: _paymentMethod,
          paymentStatus: _isPaid ? 'مدفوع' : 'غير مدفوع',
          paidAmount: _isPaid ? quantity * price : 0,
          remainingAmount: _isPaid ? 0 : quantity * price,
          invoiceNumber: _invoiceNumberController.text,
          notes: _notesController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final total = quantity * price;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عملية شراء'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: BlocConsumer<PurchasesBloc, PurchasesState>(
        listener: (context, state) {
          if (state is PurchaseAdded) {
            SnackbarWidget.showSuccess(
              context: context,
              message: 'تمت إضافة عملية الشراء بنجاح',
            );
            Navigator.of(context).pop(true);
          } else if (state is PurchasesError) {
            SnackbarWidget.showError(
              context: context,
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is PurchasesLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
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

                // اختيار المورد - جلب من قاعدة البيانات
                BlocBuilder<SuppliersBloc, SuppliersState>(
                  builder: (context, suppliersState) {
                    if (suppliersState is SuppliersLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    if (suppliersState is SuppliersLoaded) {
                      final suppliers = suppliersState.suppliers;
                      
                      if (suppliers.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.warning),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: AppColors.warning),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'لا يوجد موردين. يرجى إضافة مورد أولاً',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return AppDropdownField<String>(
                        label: 'المورد',
                        hint: 'اختر المورد',
                        value: _selectedSupplier,
                        items: suppliers.map((supplier) {
                          return DropdownMenuItem<String>(
                            value: supplier.id.toString(),
                            child: Text(supplier.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSupplier = value;
                          });
                        },
                        prefixIcon: Icons.person,
                      );
                    }
                    
                    return AppDropdownField<String>(
                      label: 'المورد',
                      hint: 'اختر المورد',
                      value: _selectedSupplier,
                      items: const [],
                      onChanged: null,
                      prefixIcon: Icons.person,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // قسم تفاصيل القات
                _buildSectionTitle('تفاصيل القات'),
                const SizedBox(height: 16),

                BlocBuilder<QatTypesBloc, QatTypesState>(
                  builder: (context, qatTypesState) {
                    if (qatTypesState is QatTypesLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    if (qatTypesState is QatTypesLoaded) {
                      final qatTypes = qatTypesState.qatTypes;
                      
                      if (qatTypes.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.warning),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: AppColors.warning),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'لا يوجد أنواع قات. يرجى إضافة نوع أولاً',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return AppDropdownField<String>(
                        label: 'نوع القات',
                        hint: 'اختر نوع القات',
                        value: _selectedQatType,
                        items: qatTypes.map((qatType) {
                          return DropdownMenuItem<String>(
                            value: qatType.id.toString(),
                            child: Text(qatType.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedQatType = value;
                          });
                        },
                        prefixIcon: Icons.grass,
                      );
                    }
                    
                    return AppDropdownField<String>(
                      label: 'نوع القات',
                      hint: 'اختر نوع القات',
                      value: _selectedQatType,
                      items: const [],
                      onChanged: null,
                      prefixIcon: Icons.grass,
                    );
                  },
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
                            : () async {
                                final confirm = await ConfirmDialog.show(
                                  context,
                                  title: 'إلغاء العملية',
                                  message: 'هل تريد إلغاء إضافة عملية الشراء؟',
                                  confirmText: 'نعم، إلغاء',
                                  cancelText: 'لا، متابعة',
                                );
                                if (confirm == true && context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: AppButton.primary(
                        text: 'حفظ عملية الشراء',
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
