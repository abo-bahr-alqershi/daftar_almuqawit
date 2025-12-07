import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/entities/qat_type.dart';

/// نموذج إضافة أو تعديل نوع قات - تصميم احترافي راقي
class QatTypeForm extends StatefulWidget {
  const QatTypeForm({
    super.key,
    this.qatType,
    this.onSubmit,
    this.onCancel,
    this.isLoading = false,
    this.nameFieldKey,
    this.qualityFieldKey,
    this.saveButtonKey,
  });

  final dynamic qatType;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;
  final GlobalKey? nameFieldKey;
  final GlobalKey? qualityFieldKey;
  final GlobalKey? saveButtonKey;

  @override
  State<QatTypeForm> createState() => QatTypeFormState();
}

class QatTypeFormState extends State<QatTypeForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();

  String _selectedQuality = 'ممتاز';

  final Set<String> _selectedUnits = {};
  final Map<String, TextEditingController> _unitBuyPriceControllers = {};
  final Map<String, TextEditingController> _unitSellPriceControllers = {};

  final List<String> _qualities = ['ممتاز', 'جيد جداً', 'جيد', 'متوسط', 'عادي'];
  final List<String> _availableUnits = ['ربطة', 'علاقية', 'كيلو'];

  @override
  void initState() {
    super.initState();
    _selectedUnits.addAll(_availableUnits);

    for (var unit in _availableUnits) {
      _unitBuyPriceControllers[unit] = TextEditingController();
      _unitSellPriceControllers[unit] = TextEditingController();
    }

    if (widget.qatType != null) {
      _nameController.text = widget.qatType.name;
      _selectedQuality = widget.qatType.qualityGrade ?? 'ممتاز';

      if (widget.qatType.unitPrices != null) {
        widget.qatType.unitPrices.forEach((unit, prices) {
          if (_unitBuyPriceControllers.containsKey(unit)) {
            _unitBuyPriceControllers[unit]!.text =
                prices.buyPrice?.toString() ?? '';
            _unitSellPriceControllers[unit]!.text =
                prices.sellPrice?.toString() ?? '';
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
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
        buyPrice: buyPrice != null && buyPrice.isNotEmpty
            ? double.parse(buyPrice)
            : null,
        sellPrice: sellPrice != null && sellPrice.isNotEmpty
            ? double.parse(sellPrice)
            : null,
      );
    }

    return {
      'name': _nameController.text,
      'qualityGrade': _selectedQuality,
      'defaultBuyPrice': null,
      'defaultSellPrice': null,
      'icon': '🌿',
      'availableUnits': _selectedUnits.toList(),
      'unitPrices': unitPrices,
    };
  }

  Color _getQualityColor(String quality) {
    switch (quality) {
      case 'ممتاز':
        return const Color(0xFF16A34A);
      case 'جيد جداً':
        return const Color(0xFF0EA5E9);
      case 'جيد':
        return const Color(0xFF6366F1);
      case 'متوسط':
      case 'عادي':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfoSection(),
          const SizedBox(height: 20),
          _buildQualitySection(),
          const SizedBox(height: 28),
          if (widget.onSubmit != null && widget.onCancel != null)
            _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'المعلومات الأساسية',
      icon: Icons.grass_outlined,
      color: const Color(0xFF6366F1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'اسم النوع *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: widget.nameFieldKey,
            controller: _nameController,
            focusNode: _nameFocusNode,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
            decoration: InputDecoration(
              hintText: 'مثال: قيفي رووس، عنسي عوارض',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.label_outline,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
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
                  color: Color(0xFF6366F1),
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
            validator: (value) {
              if (value?.isEmpty ?? true) return 'يرجى إدخال اسم النوع';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQualitySection() {
    return _buildSection(
      key: widget.qualityFieldKey,
      title: 'درجة الجودة',
      icon: Icons.grade_outlined,
      color: const Color(0xFFF59E0B),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _qualities.map((quality) {
          final isSelected = _selectedQuality == quality;
          final color = _getQualityColor(quality);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedQuality = quality);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : color.withOpacity(0.3),
                ),
              ),
              child: Text(
                quality,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSection({
    Key? key,
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      key: key,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onCancel,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                child: const Text(
                  'إلغاء',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Material(
            key: widget.saveButtonKey,
            color: widget.isLoading
                ? const Color(0xFFD1D5DB)
                : const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onSubmit,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                child: widget.isLoading
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
                          Icon(
                            widget.qatType == null
                                ? Icons.add_circle_outline
                                : Icons.check_circle_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.qatType == null
                                ? 'إضافة النوع'
                                : 'حفظ التعديلات',
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
          ),
        ),
      ],
    );
  }
}
