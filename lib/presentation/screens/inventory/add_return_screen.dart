import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/return_item.dart';
import '../../blocs/inventory/inventory_bloc.dart';

/// شاشة إضافة مردود - تصميم راقي هادئ
class AddReturnScreen extends StatefulWidget {
  const AddReturnScreen({super.key});

  @override
  State<AddReturnScreen> createState() => _AddReturnScreenState();
}

class _AddReturnScreenState extends State<AddReturnScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qatTypeNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _returnReasonController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _supplierNameController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedReturnType = 'مردود_مبيعات';
  String _selectedUnit = 'ربطة';
  double _totalAmount = 0;

  final List<String> _units = ['ربطة', 'كيس', 'كرتون', 'قطعة'];
  final List<String> _returnTypes = ['مردود_مبيعات', 'مردود_مشتريات'];

  @override
  void dispose() {
    _qatTypeNameController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _returnReasonController.dispose();
    _customerNameController.dispose();
    _supplierNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_unitPriceController.text) ?? 0;
    setState(() {
      _totalAmount = quantity * price;
    });
  }

  void _submitReturn() {
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
            'إضافة مردود',
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
                _buildReturnTypeSection(),
                const SizedBox(height: 24),
                _buildItemInfoSection(),
                const SizedBox(height: 24),
                _buildPriceSection(),
                const SizedBox(height: 24),
                _buildReasonSection(),
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
        gradient: const LinearGradient(
          colors: [AppColors.warning, AppColors.warning],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withOpacity(0.3),
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
              Icons.keyboard_return_rounded,
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
                  'تسجيل مردود جديد',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أدخل معلومات المردود بدقة',
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

  Widget _buildReturnTypeSection() {
    return _SectionCard(
      title: 'نوع المردود',
      icon: Icons.category_rounded,
      color: AppColors.warning,
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              label: 'مردود مبيعات',
              icon: Icons.sell_rounded,
              isSelected: _selectedReturnType == 'مردود_مبيعات',
              color: AppColors.sales,
              onTap: () {
                setState(() => _selectedReturnType = 'مردود_مبيعات');
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TypeButton(
              label: 'مردود مشتريات',
              icon: Icons.shopping_cart_rounded,
              isSelected: _selectedReturnType == 'مردود_مشتريات',
              color: AppColors.purchases,
              onTap: () {
                setState(() => _selectedReturnType = 'مردود_مشتريات');
              },
            ),
          ),
        ],
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
                  label: 'الكمية',
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
          const SizedBox(height: 16),
          if (_selectedReturnType == 'مردود_مبيعات')
            _buildTextField(
              controller: _customerNameController,
              label: 'اسم العميل',
              hint: 'اسم العميل (اختياري)',
              icon: Icons.person_outline_rounded,
            )
          else
            _buildTextField(
              controller: _supplierNameController,
              label: 'اسم المورد',
              hint: 'اسم المورد (اختياري)',
              icon: Icons.business_rounded,
            ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return _SectionCard(
      title: 'السعر والمبلغ',
      icon: Icons.attach_money_rounded,
      color: AppColors.primary,
      child: _buildTextField(
        controller: _unitPriceController,
        label: 'سعر الوحدة',
        hint: '0.00',
        icon: Icons.price_change_rounded,
        keyboardType: TextInputType.number,
        suffixText: 'ريال',
        onChanged: (_) => _calculateTotal(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال السعر';
          }
          if (double.tryParse(value) == null || double.parse(value) < 0) {
            return 'قيمة غير صحيحة';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildReasonSection() {
    return _SectionCard(
      title: 'سبب المردود',
      icon: Icons.comment_rounded,
      color: AppColors.danger,
      child: _buildTextField(
        controller: _returnReasonController,
        label: 'السبب',
        hint: 'مثال: منتج تالف، عيب في الجودة...',
        icon: Icons.notes_rounded,
        maxLines: 3,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال سبب المردود';
          }
          return null;
        },
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
            AppColors.warning.withOpacity(0.12),
            AppColors.warning.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ملخص المردود',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'نوع المردود',
            value: _selectedReturnType == 'مردود_مبيعات'
                ? 'مردود مبيعات'
                : 'مردود مشتريات',
            color: _selectedReturnType == 'مردود_مبيعات'
                ? AppColors.sales
                : AppColors.purchases,
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
            label: 'سعر الوحدة',
            value: _unitPriceController.text.isEmpty
                ? '0.00'
                : '${_unitPriceController.text} ريال',
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
            label: 'المبلغ الإجمالي',
            value: '${_totalAmount.toStringAsFixed(2)} ريال',
            color: AppColors.warning,
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
        gradient: const LinearGradient(
          colors: [AppColors.warning, AppColors.warning],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _submitReturn,
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
                  'تسجيل المردود',
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

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : AppColors.border.withOpacity(0.3),
          width: isSelected ? 0 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
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
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: isSelected ? Colors.white : color, size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
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
