import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/supplier.dart';
import '../../blocs/suppliers/suppliers_bloc.dart';
import '../../blocs/suppliers/suppliers_event.dart';
import '../../blocs/suppliers/suppliers_state.dart';
import '../../navigation/route_names.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/loading_widget.dart';

/// شاشة تعديل مورد
class EditSupplierScreen extends StatefulWidget {
  final Supplier supplier;

  const EditSupplierScreen({
    super.key,
    required this.supplier,
  });

  @override
  State<EditSupplierScreen> createState() => _EditSupplierScreenState();
}

class _EditSupplierScreenState extends State<EditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _areaController;
  late TextEditingController _notesController;
  
  late int _qualityRating;
  late String _trustLevel;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier.name);
    _phoneController = TextEditingController(text: widget.supplier.phone ?? '');
    _areaController = TextEditingController(text: widget.supplier.area ?? '');
    _notesController = TextEditingController(text: widget.supplier.notes ?? '');
    _qualityRating = widget.supplier.qualityRating;
    _trustLevel = widget.supplier.trustLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال اسم المورد';
    }
    if (value.trim().length < 2) {
      return 'اسم المورد يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length < 9) {
        return 'رقم الهاتف غير صحيح';
      }
    }
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedSupplier = widget.supplier.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        area: _areaController.text.trim().isEmpty ? null : _areaController.text.trim(),
        qualityRating: _qualityRating,
        trustLevel: _trustLevel,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      context.read<SuppliersBloc>().add(UpdateSupplierEvent(updatedSupplier));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('تعديل بيانات المورد'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnDark,
          elevation: 0,
        ),
        body: BlocListener<SuppliersBloc, SuppliersState>(
          listener: (context, state) {
            if (state is SupplierOperationSuccess) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.of(context).pop();
            } else if (state is SuppliersError) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger,
                ),
              );
            } else if (state is SuppliersLoading) {
              setState(() => _isLoading = true);
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // معلومات المورد
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.info),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'قم بتعديل بيانات المورد ثم اضغط على حفظ',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // اسم المورد
                    AppTextField(
                      controller: _nameController,
                      label: 'اسم المورد',
                      hint: 'أدخل اسم المورد',
                      prefixIcon: Icons.person,
                      validator: _validateName,
                      textInputAction: TextInputAction.next,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // رقم الهاتف
                    AppTextField.phone(
                      controller: _phoneController,
                      label: 'رقم الهاتف',
                      hint: 'أدخل رقم الهاتف (اختياري)',
                      validator: _validatePhone,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // المنطقة
                    AppTextField(
                      controller: _areaController,
                      label: 'المنطقة',
                      hint: 'أدخل المنطقة (اختياري)',
                      prefixIcon: Icons.location_on,
                      textInputAction: TextInputAction.next,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // تقييم الجودة
                    Text(
                      'تقييم الجودة',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            onPressed: () {
                              setState(() {
                                _qualityRating = index + 1;
                              });
                            },
                            icon: Icon(
                              index < _qualityRating ? Icons.star : Icons.star_border,
                              color: AppColors.warning,
                              size: 32,
                            ),
                          );
                        }),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // مستوى الثقة
                    Text(
                      'مستوى الثقة',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _trustLevel,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                          style: AppTextStyles.bodyMedium,
                          items: const [
                            DropdownMenuItem(value: 'جديد', child: Text('جديد')),
                            DropdownMenuItem(value: 'جيد', child: Text('جيد')),
                            DropdownMenuItem(value: 'ممتاز', child: Text('ممتاز')),
                            DropdownMenuItem(value: 'متوسط', child: Text('متوسط')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _trustLevel = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // ملاحظات
                    AppTextField.multiline(
                      controller: _notesController,
                      label: 'ملاحظات',
                      hint: 'أدخل ملاحظات إضافية (اختياري)',
                      maxLines: 4,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // أزرار الحفظ والإلغاء
                    Row(
                      children: [
                        Expanded(
                          child: AppButton.primary(
                            text: 'حفظ التغييرات',
                            onPressed: _isLoading ? null : _handleSubmit,
                            isLoading: _isLoading,
                            icon: Icons.save,
                            fullWidth: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppButton.secondary(
                            text: 'إلغاء',
                            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                            icon: Icons.close,
                            fullWidth: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
