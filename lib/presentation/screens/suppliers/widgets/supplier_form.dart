import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/supplier_model.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';

/// نموذج بيانات المورد
class SupplierForm extends StatefulWidget {
  final SupplierModel? supplier;
  final void Function(SupplierModel supplier) onSubmit;
  final VoidCallback? onCancel;

  const SupplierForm({
    super.key,
    this.supplier,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<SupplierForm> createState() => _SupplierFormState();
}

class _SupplierFormState extends State<SupplierForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _areaController;
  late final TextEditingController _notesController;

  int _qualityRating = 3;
  String _trustLevel = 'جديد';

  final List<String> _trustLevels = [
    'جديد',
    'موثوق',
    'متوسط',
    'غير موثوق',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _phoneController = TextEditingController(text: widget.supplier?.phone ?? '');
    _areaController = TextEditingController(text: widget.supplier?.area ?? '');
    _notesController = TextEditingController(text: widget.supplier?.notes ?? '');

    if (widget.supplier != null) {
      _qualityRating = widget.supplier!.qualityRating;
      _trustLevel = widget.supplier!.trustLevel;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final supplier = SupplierModel(
        id: widget.supplier?.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        area: _areaController.text.trim().isEmpty ? null : _areaController.text.trim(),
        qualityRating: _qualityRating,
        trustLevel: _trustLevel,
        totalPurchases: widget.supplier?.totalPurchases ?? 0,
        totalDebtToHim: widget.supplier?.totalDebtToHim ?? 0,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: widget.supplier?.createdAt,
        updatedAt: DateTime.now(),
        firebaseId: widget.supplier?.firebaseId,
        syncStatus: widget.supplier?.syncStatus,
      );

      widget.onSubmit(supplier);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name Field
            AppTextField(
              controller: _nameController,
              label: 'اسم المورد *',
              hint: 'أدخل اسم المورد',
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'اسم المورد مطلوب';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Field
            AppTextField.phone(
              controller: _phoneController,
              label: 'رقم الهاتف',
              hint: 'أدخل رقم الهاتف',
            ),
            const SizedBox(height: 16),

            // Area Field
            AppTextField(
              controller: _areaController,
              label: 'المنطقة',
              hint: 'أدخل المنطقة',
              prefixIcon: Icons.location_on,
            ),
            const SizedBox(height: 16),

            // Quality Rating
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تقييم الجودة',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'التقييم: $_qualityRating',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: _getRatingColor(_qualityRating),
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < _qualityRating ? Icons.star : Icons.star_border,
                                color: _getRatingColor(_qualityRating),
                                size: 24,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _qualityRating.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        activeColor: _getRatingColor(_qualityRating),
                        onChanged: (value) {
                          setState(() {
                            _qualityRating = value.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Trust Level
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مستوى الثقة',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _trustLevel,
                    items: _trustLevels.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getTrustLevelColor(level),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              level,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _trustLevel = value;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: InputBorder.none,
                    ),
                    style: AppTextStyles.bodyMedium,
                    dropdownColor: AppColors.surface,
                    icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notes Field
            AppTextField.multiline(
              controller: _notesController,
              label: 'ملاحظات',
              hint: 'أدخل ملاحظات إضافية',
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                if (widget.onCancel != null)
                  Expanded(
                    child: AppButton.secondary(
                      text: 'إلغاء',
                      onPressed: widget.onCancel,
                    ),
                  ),
                if (widget.onCancel != null) const SizedBox(width: 12),
                Expanded(
                  flex: widget.onCancel != null ? 1 : 1,
                  child: AppButton.primary(
                    text: widget.supplier == null ? 'إضافة' : 'حفظ',
                    onPressed: _handleSubmit,
                    icon: widget.supplier == null ? Icons.add : Icons.save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return AppColors.success;
    if (rating >= 3) return AppColors.warning;
    return AppColors.danger;
  }

  Color _getTrustLevelColor(String trustLevel) {
    switch (trustLevel) {
      case 'موثوق':
        return AppColors.success;
      case 'متوسط':
        return AppColors.warning;
      case 'غير موثوق':
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }
}
