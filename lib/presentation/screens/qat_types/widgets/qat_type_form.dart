import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/qat_type.dart';

/// نموذج إضافة أو تعديل نوع قات - تصميم راقي هادئ
class QatTypeForm extends StatefulWidget {
  const QatTypeForm({
    super.key,
    this.qatType,
    this.onSubmit,
    this.onCancel,
    this.isLoading = false,
    this.nameFieldKey,
    this.priceFieldKey,
    this.saveButtonKey,
    this.nameFocusNode,
    this.buyPriceFocusNode,
    this.sellPriceFocusNode,
  });
  final dynamic qatType;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;
  final GlobalKey? nameFieldKey;
  final GlobalKey? priceFieldKey;
  final GlobalKey? saveButtonKey;
  final FocusNode? nameFocusNode;
  final FocusNode? buyPriceFocusNode;
  final FocusNode? sellPriceFocusNode;

  @override
  State<QatTypeForm> createState() => QatTypeFormState();
}

class QatTypeFormState extends State<QatTypeForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();

  // FocusNodes للحقول - استخدام الخارجية أو إنشاء داخلية
  late FocusNode _nameFocusNode;
  late FocusNode _buyPriceFocusNode;
  late FocusNode _sellPriceFocusNode;

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

    // استخدام FocusNodes الممررة أو إنشاء جديدة
    _nameFocusNode = widget.nameFocusNode ?? FocusNode();
    _buyPriceFocusNode = widget.buyPriceFocusNode ?? FocusNode();
    _sellPriceFocusNode = widget.sellPriceFocusNode ?? FocusNode();

    for (var unit in _availableUnits) {
      _unitBuyPriceControllers[unit] = TextEditingController();
      _unitSellPriceControllers[unit] = TextEditingController();
    }

    if (widget.qatType != null) {
      _nameController.text = widget.qatType.name;
      _buyPriceController.text = widget.qatType.defaultBuyPrice?.toString() ?? '';
      _sellPriceController.text = widget.qatType.defaultSellPrice?.toString() ?? '';
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
    
    // التخلص من FocusNodes فقط إذا تم إنشاؤها داخلياً
    if (widget.nameFocusNode == null) _nameFocusNode.dispose();
    if (widget.buyPriceFocusNode == null) _buyPriceFocusNode.dispose();
    if (widget.sellPriceFocusNode == null) _sellPriceFocusNode.dispose();
    
    for (var controller in _unitBuyPriceControllers.values) {
      controller.dispose();
    }
    for (var controller in _unitSellPriceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool validate() => _formKey.currentState?.validate() ?? false;

  // إضافة دوال للوصول إلى FocusNodes من الخارج
  FocusNode get nameFocusNode => _nameFocusNode;
  FocusNode get buyPriceFocusNode => _buyPriceFocusNode;
  FocusNode get sellPriceFocusNode => _sellPriceFocusNode;

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
        _buildFormCard(
          title: 'معلومات أساسية',
          icon: Icons.grass_rounded,
          color: AppColors.primary,
          child: Column(
            children: [
              _buildTextField(
                key: widget.nameFieldKey,
                controller: _nameController,
                focusNode: _nameFocusNode,
                label: 'اسم النوع',
                hint: 'مثال: قيفي رووس، عنسي عوارض',
                icon: Icons.label_rounded,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'يرجى إدخال اسم النوع';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildQualitySelector(),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _buildFormCard(
          title: 'اختر الرمز',
          icon: Icons.emoji_emotions_rounded,
          color: AppColors.success,
          child: _buildIconSelector(),
        ),

        const SizedBox(height: 20),

        _buildFormCard(
          title: 'الأسعار الافتراضية',
          icon: Icons.attach_money_rounded,
          color: AppColors.sales,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      key: widget.priceFieldKey,
                      controller: _buyPriceController,
                      focusNode: _buyPriceFocusNode,
                      label: 'سعر الشراء',
                      hint: '0',
                      icon: Icons.shopping_cart_rounded,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _sellPriceController,
                      focusNode: _sellPriceFocusNode,
                      label: 'سعر البيع',
                      hint: '0',
                      icon: Icons.sell_rounded,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ],
              ),
              if (_buyPriceController.text.isNotEmpty &&
                  _sellPriceController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildProfitIndicator(),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        _buildFormCard(
          title: 'الوحدات المتاحة',
          icon: Icons.inventory_2_rounded,
          color: AppColors.info,
          child: _buildUnitsSelector(),
        ),

        if (_selectedUnits.isNotEmpty) ...[
          const SizedBox(height: 20),
          ..._selectedUnits.map((unit) => Column(
            children: [
              _buildUnitPriceSection(unit),
              const SizedBox(height: 16),
            ],
          )),
        ],

        const SizedBox(height: 24),

        if (widget.onSubmit != null && widget.onCancel != null)
          _buildActionButtons(),
      ],
    ),
  );

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
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

  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    FocusNode? focusNode,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          hintStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        ),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildQualitySelector() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grade_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: 10),
              Text(
                'درجة الجودة',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _qualities.map((quality) {
              final isSelected = _selectedQuality == quality;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedQuality = quality);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              _getQualityColor(quality),
                              _getQualityColor(quality).withOpacity(0.8),
                            ],
                          )
                        : null,
                    color: isSelected ? null : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? _getQualityColor(quality)
                          : AppColors.border.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _getQualityColor(quality).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    quality,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
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

  Widget _buildIconSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _icons.map((icon) {
        final isSelected = _selectedIcon == icon;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedIcon = icon);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.success],
                    )
                  : null,
              color: isSelected ? null : AppColors.background.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.border.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 28)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUnitsSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _availableUnits.map((unit) {
        final isSelected = _selectedUnits.contains(unit);
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (isSelected) {
                _selectedUnits.remove(unit);
              } else {
                _selectedUnits.add(unit);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [AppColors.info, AppColors.primary],
                    )
                  : null,
              color: isSelected ? null : AppColors.background.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.info
                    : AppColors.border.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.info.withOpacity(0.3),
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
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUnitPriceSection(String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.primary.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
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
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.primary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getUnitIcon(unit),
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'أسعار $unit',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _unitBuyPriceControllers[unit]!,
                  label: 'سعر الشراء',
                  hint: '0',
                  icon: Icons.arrow_downward_rounded,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _unitSellPriceControllers[unit]!,
                  label: 'سعر البيع',
                  hint: '0',
                  icon: Icons.arrow_upward_rounded,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() {}),
                  validator: (value) {
                    if (value != null && value.isNotEmpty &&
                        _unitBuyPriceControllers[unit]!.text.isNotEmpty) {
                      final buyPrice = double.tryParse(_unitBuyPriceControllers[unit]!.text);
                      final sellPrice = double.tryParse(value);
                      if (buyPrice != null && sellPrice != null && sellPrice < buyPrice) {
                        return 'أقل من الشراء';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          if (_unitBuyPriceControllers[unit]!.text.isNotEmpty &&
              _unitSellPriceControllers[unit]!.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.success.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up_rounded,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'الربح',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_calculateUnitProfit(unit)} ر.ي',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfitIndicator() {
    final profit = _calculateProfit();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.1),
            AppColors.success.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.success,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'هامش الربح المتوقع',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            '$profit ر.ي',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onCancel,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Text(
                    'إلغاء',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            key: widget.saveButtonKey,
            height: 56,
            decoration: BoxDecoration(
              gradient: widget.isLoading
                  ? LinearGradient(
                      colors: [
                        AppColors.textHint.withOpacity(0.5),
                        AppColors.textHint.withOpacity(0.3),
                      ],
                    )
                  : const LinearGradient(
                      colors: [AppColors.primary, AppColors.success],
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: widget.isLoading
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onSubmit,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.qatType == null
                                  ? Icons.add_circle_rounded
                                  : Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.qatType == null ? 'إضافة النوع' : 'حفظ التعديلات',
                              style: AppTextStyles.button.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'ممتاز':
        return AppColors.success;
      case 'جيد جداً':
        return AppColors.info;
      case 'جيد':
        return AppColors.primary;
      case 'متوسط':
      case 'عادي':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
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
