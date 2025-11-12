import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/damaged_item.dart';
import '../../blocs/inventory/inventory_bloc.dart';

/// شاشة إضافة بضاعة تالفة - تصميم راقي هادئ
class AddDamagedItemScreen extends StatefulWidget {
  const AddDamagedItemScreen({super.key});

  @override
  State<AddDamagedItemScreen> createState() => _AddDamagedItemScreenState();
}

class _AddDamagedItemScreenState extends State<AddDamagedItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qatTypeNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _damageReasonController = TextEditingController();
  final _responsiblePersonController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedDamageType = 'تلف_طبيعي';
  String _selectedSeverityLevel = 'متوسط';
  String _selectedUnit = 'ربطة';
  double _totalCost = 0;

  final List<String> _units = ['ربطة', 'كيس', 'كرتون', 'قطعة'];
  final List<String> _severityLevels = ['طفيف', 'متوسط', 'كبير', 'كارثي'];

  @override
  void dispose() {
    _qatTypeNameController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();
    _damageReasonController.dispose();
    _responsiblePersonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final cost = double.tryParse(_unitCostController.text) ?? 0;
    setState(() {
      _totalCost = quantity * cost;
    });
  }

  Color _getSeverityColor() {
    switch (_selectedSeverityLevel) {
      case 'طفيف':
        return AppColors.success;
      case 'متوسط':
        return AppColors.warning;
      case 'كبير':
        return AppColors.danger;
      case 'كارثي':
        return AppColors.purchases;
      default:
        return AppColors.danger;
    }
  }

  void _submitDamage() {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'تسجيل بضاعة تالفة',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),
                _buildSeveritySection(),
                const SizedBox(height: 24),
                _buildItemInfoSection(),
                const SizedBox(height: 24),
                _buildCostSection(),
                const SizedBox(height: 24),
                _buildDamageReasonSection(),
                const SizedBox(height: 24),
                _buildResponsibleSection(),
                const SizedBox(height: 24),
                _buildNotesSection(),
                const SizedBox(height: 24),
                _buildSummaryCard(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_getSeverityColor(), _getSeverityColor().withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getSeverityColor().withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.broken_image_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تسجيل بضاعة تالفة',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'موثق للخسائر والمحاسبة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeveritySection() {
    return _SectionCard(
      title: 'مستوى الخطورة',
      icon: Icons.warning_rounded,
      color: _getSeverityColor(),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _severityLevels.map((level) {
          final isSelected = _selectedSeverityLevel == level;
          Color color;
          switch (level) {
            case 'طفيف':
              color = AppColors.success;
              break;
            case 'متوسط':
              color = AppColors.warning;
              break;
            case 'كبير':
              color = AppColors.danger;
              break;
            case 'كارثي':
              color = AppColors.purchases;
              break;
            default:
              color = AppColors.danger;
          }

          return _SeverityChip(
            label: level,
            color: color,
            isSelected: isSelected,
            onTap: () {
              setState(() => _selectedSeverityLevel = level);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItemInfoSection() {
    return _SectionCard(
      title: 'معلومات الصنف',
      icon: Icons.inventory_2_rounded,
      color: AppColors.info,
      child: Column(
        children: [
          _buildTextField(
            controller: _qatTypeNameController,
            label: 'اسم الصنف',
            hint: 'مثال: قات بلدي',
            icon: Icons.grass_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال اسم الصنف';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _quantityController,
                  label: 'الكمية التالفة',
                  hint: '0',
                  icon: Icons.inventory_rounded,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _calculateTotal(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'مطلوب';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'قيمة غير صحيحة';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  value: _selectedUnit,
                  items: _units,
                  label: 'الوحدة',
                  onChanged: (value) {
                    setState(() => _selectedUnit = value!);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostSection() {
    return _SectionCard(
      title: 'التكلفة',
      icon: Icons.attach_money_rounded,
      color: AppColors.primary,
      child: _buildTextField(
        controller: _unitCostController,
        label: 'تكلفة الوحدة',
        hint: '0.00',
        icon: Icons.price_change_rounded,
        keyboardType: TextInputType.number,
        suffixText: 'ريال',
        onChanged: (_) => _calculateTotal(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال التكلفة';
          }
          if (double.tryParse(value) == null || double.parse(value) < 0) {
            return 'قيمة غير صحيحة';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDamageReasonSection() {
    return _SectionCard(
      title: 'سبب التلف',
      icon: Icons.comment_rounded,
      color: AppColors.danger,
      child: _buildTextField(
        controller: _damageReasonController,
        label: 'السبب',
        hint: 'مثال: تعفن، كسر، تخزين سيء...',
        icon: Icons.notes_rounded,
        maxLines: 3,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال سبب التلف';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildResponsibleSection() {
    return _SectionCard(
      title: 'المسؤول (اختياري)',
      icon: Icons.person_outline_rounded,
      color: AppColors.textSecondary,
      child: _buildTextField(
        controller: _responsiblePersonController,
        label: 'الشخص المسؤول',
        hint: 'إن وُجد مسؤول عن التلف',
        icon: Icons.badge_rounded,
      ),
    );
  }

  Widget _buildNotesSection() {
    return _SectionCard(
      title: 'ملاحظات إضافية',
      icon: Icons.note_add_rounded,
      color: AppColors.textSecondary,
      child: _buildTextField(
        controller: _notesController,
        label: 'ملاحظات',
        hint: 'أي ملاحظات إضافية (اختياري)',
        icon: Icons.edit_note_rounded,
        maxLines: 3,
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getSeverityColor().withOpacity(0.12),
            _getSeverityColor().withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getSeverityColor().withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getSeverityColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calculate_rounded,
                  color: _getSeverityColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ملخص الخسارة',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'مستوى الخطورة',
            value: _selectedSeverityLevel,
            color: _getSeverityColor(),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'الكمية',
            value: _quantityController.text.isEmpty
                ? '0'
                : '${_quantityController.text} $_selectedUnit',
            color: AppColors.info,
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'تكلفة الوحدة',
            value: _unitCostController.text.isEmpty
                ? '0.00'
                : '${_unitCostController.text} ريال',
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.border.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'إجمالي الخسارة',
            value: '${_totalCost.toStringAsFixed(2)} ريال',
            color: AppColors.danger,
            isBold: true,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_getSeverityColor(), _getSeverityColor().withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getSeverityColor().withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _submitDamage,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'تسجيل التلف',
                  style: AppTextStyles.button.copyWith(fontSize: 17),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? suffixText,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.inputHint.copyWith(fontSize: 14),
              prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
              suffixText: suffixText,
              suffixStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: onChanged,
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, right: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
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
          child: child,
        ),
      ],
    );
  }
}

class _SeverityChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SeverityChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(colors: [color, color.withOpacity(0.8)])
            : null,
        color: isSelected ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : AppColors.border.withOpacity(0.3),
          width: isSelected ? 0 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;
  final bool isLarge;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            fontSize: isLarge ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: isLarge ? 20 : 16,
          ),
        ),
      ],
    );
  }
}
