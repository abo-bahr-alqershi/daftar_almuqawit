import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/qat_type.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/app_dropdown.dart';

/// نموذج إضافة أو تعديل نوع قات
///
/// يوفر واجهة موحدة لإدخال بيانات نوع القات
class QatTypeForm extends StatefulWidget {
  const QatTypeForm({
    super.key,
    this.qatType,
    this.onSubmit,
    this.onCancel,
    this.isLoading = false,
  });
  final dynamic qatType;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;

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
  
  final Set<String> _selectedUnits = {};
  final Map<String, TextEditingController> _unitBuyPriceControllers = {};
  final Map<String, TextEditingController> _unitSellPriceControllers = {};

  final List<String> _qualities = ['ممتاز', 'جيد جداً', 'جيد', 'متوسط', 'عادي'];
  final List<String> _icons = ['🌿', '🍃', '🌱', '🌾', '🎋', '🌳', '🪴', '☘️'];
  final List<String> _availableUnits = ['ربطة', 'كيس', 'كيلو'];

  @override
  void initState() {
    super.initState();
    
    for (var unit in _availableUnits) {
      _unitBuyPriceControllers[unit] = TextEditingController();
      _unitSellPriceControllers[unit] = TextEditingController();
    }
    
    if (widget.qatType != null) {
      _nameController.text = widget.qatType.name;
      _buyPriceController.text =
          widget.qatType.defaultBuyPrice?.toString() ?? '';
      _sellPriceController.text =
          widget.qatType.defaultSellPrice?.toString() ?? '';
      _selectedQuality = widget.qatType.qualityGrade ?? 'ممتاز';
      _selectedIcon = widget.qatType.icon ?? '🌿';
      
      if (widget.qatType.availableUnits != null) {
        _selectedUnits.addAll(widget.qatType.availableUnits);
      }
      
      if (widget.qatType.unitPrices != null) {
        widget.qatType.unitPrices.forEach((unit, prices) {
          if (_unitBuyPriceControllers.containsKey(unit)) {
            _unitBuyPriceControllers[unit]!.text = prices.buyPrice?.toString() ?? '';
            _unitSellPriceControllers[unit]!.text = prices.sellPrice?.toString() ?? '';
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    for (var controller in _unitBuyPriceControllers.values) {
      controller.dispose();
    }
    for (var controller in _unitSellPriceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool validate() => _formKey.currentState?.validate() ?? false;

  Map<String, dynamic> getFormData() {
    final Map<String, UnitPrice> unitPrices = {};
    
    for (var unit in _selectedUnits) {
      final buyPrice = _unitBuyPriceControllers[unit]?.text;
      final sellPrice = _unitSellPriceControllers[unit]?.text;
      
      unitPrices[unit] = UnitPrice(
        buyPrice: buyPrice != null && buyPrice.isNotEmpty ? double.parse(buyPrice) : null,
        sellPrice: sellPrice != null && sellPrice.isNotEmpty ? double.parse(sellPrice) : null,
      );
    }
    
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
      'availableUnits': _selectedUnits.toList(),
      'unitPrices': unitPrices,
    };
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('معلومات نوع القات'),
        const SizedBox(height: 16),

        AppTextField(
          controller: _nameController,
          label: 'اسم النوع',
          hint: 'مثال: قيفي رووس، عنسي عوارض ...',
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
          items: _qualities
              .map(
                (quality) => DropdownMenuItem(
                  value: quality,
                  child: Row(
                    children: [
                      Icon(_getQualityIcon(quality), size: 20),
                      const SizedBox(width: 8),
                      Text(quality),
                    ],
                  ),
                ),
              )
              .toList(),
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
                  child: Text(icon, style: const TextStyle(fontSize: 32)),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        _buildSectionTitle('الوحدات المتاحة'),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اختر الوحدات المتاحة لهذا النوع',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableUnits.map((unit) {
                  final isSelected = _selectedUnits.contains(unit);
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getUnitIcon(unit),
                          size: 18,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(unit),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedUnits.add(unit);
                        } else {
                          _selectedUnits.remove(unit);
                        }
                      });
                    },
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        if (_selectedUnits.isNotEmpty) ...[
          _buildSectionTitle('الأسعار الافتراضية للوحدات'),
          const SizedBox(height: 16),
          
          ..._selectedUnits.map((unit) => _buildUnitPriceSection(unit)),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withOpacity(0.3), width: 1.5),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'الأسعار الافتراضية لا تدخل بالحساب وإنما لتسهيل ظهور السعر مباشرة عند الشراء أو البيع',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.info,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

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
                const Icon(
                  Icons.trending_up,
                  color: AppColors.success,
                  size: 28,
                ),
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

  Widget _buildUnitPriceSection(String unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.primary.withOpacity(0.02),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getUnitIcon(unit),
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                unit,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: AppTextField.currency(
                  controller: _unitBuyPriceControllers[unit]!,
                  label: 'سعر الشراء',
                  hint: 'اختياري',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField.currency(
                  controller: _unitSellPriceControllers[unit]!,
                  label: 'سعر البيع',
                  hint: 'اختياري',
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        _unitBuyPriceControllers[unit]!.text.isNotEmpty) {
                      final buyPrice = double.tryParse(_unitBuyPriceControllers[unit]!.text);
                      final sellPrice = double.tryParse(value);
                      if (buyPrice != null &&
                          sellPrice != null &&
                          sellPrice < buyPrice) {
                        return 'سعر البيع أقل من الشراء';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          if (_unitBuyPriceControllers[unit]!.text.isNotEmpty &&
              _unitSellPriceControllers[unit]!.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'هامش الربح',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_calculateUnitProfit(unit)} ريال',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Row(
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

  IconData _getUnitIcon(String unit) {
    switch (unit) {
      case 'ربطة':
        return Icons.shopping_bag;
      case 'كيس':
        return Icons.inventory_2;
      case 'كيلو':
        return Icons.scale;
      default:
        return Icons.category;
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

  String _calculateUnitProfit(String unit) {
    try {
      final buyPrice = double.parse(_unitBuyPriceControllers[unit]!.text);
      final sellPrice = double.parse(_unitSellPriceControllers[unit]!.text);
      return (sellPrice - buyPrice).toStringAsFixed(0);
    } catch (e) {
      return '0';
    }
  }
}
