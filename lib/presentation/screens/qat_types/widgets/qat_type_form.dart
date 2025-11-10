import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/app_dropdown.dart';

/// نموذج إضافة أو تعديل نوع قات
/// 
/// يوفر واجهة موحدة لإدخال بيانات نوع القات
class QatTypeForm extends StatefulWidget {
  final dynamic qatType;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;

  const QatTypeForm({
    super.key,
    this.qatType,
    this.onSubmit,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  State<QatTypeForm> createState() => QatTypeFormState();
}

class QatTypeFormState extends State<QatTypeForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();

  String _selectedQuality = 'ممتاز';
  String _selectedIcon = '🌿';

  final List<String> _qualities = [
    'ممتاز',
    'جيد جداً',
    'جيد',
    'متوسط',
    'عادي',
  ];

  final List<String> _icons = [
    '🌿',
    '🍃',
    '🌱',
    '🌾',
    '🎋',
    '🌳',
    '🪴',
    '☘️',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.qatType != null) {
      _nameController.text = widget.qatType.name;
      _buyPriceController.text =
          widget.qatType.defaultBuyPrice?.toString() ?? '';
      _sellPriceController.text =
          widget.qatType.defaultSellPrice?.toString() ?? '';
      _selectedQuality = widget.qatType.qualityGrade ?? 'ممتاز';
      _selectedIcon = widget.qatType.icon ?? '🌿';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    super.dispose();
  }

  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  Map<String, dynamic> getFormData() {
    return {
      'name': _nameController.text,
      'qualityGrade': _selectedQuality,
      'defaultBuyPrice': _buyPriceController.text.isNotEmpty
          ? double.parse(_buyPriceController.text)
          : null,
      'defaultSellPrice': _sellPriceController.text.isNotEmpty
          ? double.parse(_sellPriceController.text)
          : null,
      'icon': _selectedIcon,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('معلومات نوع القات'),
          const SizedBox(height: 16),

          AppTextField(
            controller: _nameController,
            label: 'اسم النوع',
            hint: 'مثال: حرازي، مطري، ...',
            prefixIcon: Icons.label,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'يرجى إدخال اسم النوع';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          AppDropdownField<String>(
            label: 'درجة الجودة',
            hint: 'اختر درجة الجودة',
            value: _selectedQuality,
            items: _qualities.map((quality) {
              return DropdownMenuItem(
                value: quality,
                child: Row(
                  children: [
                    Icon(_getQualityIcon(quality), size: 20),
                    const SizedBox(width: 8),
                    Text(quality),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedQuality = value!;
              });
            },
            prefixIcon: Icons.grade,
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('اختر الرمز'),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _icons.map((icon) {
              final isSelected = _selectedIcon == icon;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('الأسعار الافتراضية'),
          const SizedBox(height: 16),

          AppTextField.currency(
            controller: _buyPriceController,
            label: 'سعر الشراء الافتراضي',
            hint: 'اختياري',
          ),
          const SizedBox(height: 16),

          AppTextField.currency(
            controller: _sellPriceController,
            label: 'سعر البيع الافتراضي',
            hint: 'اختياري',
            validator: (value) {
              if (value != null &&
                  value.isNotEmpty &&
                  _buyPriceController.text.isNotEmpty) {
                final buyPrice = double.tryParse(_buyPriceController.text);
                final sellPrice = double.tryParse(value);
                if (buyPrice != null &&
                    sellPrice != null &&
                    sellPrice < buyPrice) {
                  return 'سعر البيع يجب أن يكون أكبر من سعر الشراء';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          if (_buyPriceController.text.isNotEmpty &&
              _sellPriceController.text.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: AppColors.success, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'هامش الربح المتوقع',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_calculateProfit()} ريال',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (_buyPriceController.text.isNotEmpty &&
              _sellPriceController.text.isNotEmpty)
            const SizedBox(height: 24),

          if (widget.onSubmit != null && widget.onCancel != null)
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    text: 'إلغاء',
                    onPressed: widget.isLoading ? null : widget.onCancel,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: AppButton.primary(
                    text: widget.qatType == null ? 'إضافة' : 'تحديث',
                    icon: Icons.save,
                    isLoading: widget.isLoading,
                    onPressed: widget.isLoading ? null : widget.onSubmit,
                  ),
                ),
              ],
            ),
        ],
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

  IconData _getQualityIcon(String quality) {
    switch (quality) {
      case 'ممتاز':
        return Icons.star;
      case 'جيد جداً':
        return Icons.star_half;
      case 'جيد':
        return Icons.thumb_up;
      case 'متوسط':
        return Icons.thumbs_up_down;
      case 'عادي':
        return Icons.thumb_down;
      default:
        return Icons.star_border;
    }
  }

  String _calculateProfit() {
    try {
      final buyPrice = double.parse(_buyPriceController.text);
      final sellPrice = double.parse(_sellPriceController.text);
      return (sellPrice - buyPrice).toStringAsFixed(0);
    } catch (e) {
      return '0';
    }
  }
}
