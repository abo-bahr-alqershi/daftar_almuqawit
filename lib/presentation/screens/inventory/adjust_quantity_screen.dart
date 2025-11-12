import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/inventory.dart';

/// شاشة تعديل كمية المخزون - تصميم راقي هادئ
class AdjustQuantityScreen extends StatefulWidget {
  final Inventory item;

  const AdjustQuantityScreen({
    super.key,
    required this.item,
  });

  @override
  State<AdjustQuantityScreen> createState() => _AdjustQuantityScreenState();
}

class _AdjustQuantityScreenState extends State<AdjustQuantityScreen> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String _adjustmentType = 'increase';
  double _newQuantity = 0;

  @override
  void initState() {
    super.initState();
    _newQuantity = widget.item.currentQuantity;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _updateQuantity(String value) {
    if (value.isEmpty) {
      setState(() => _newQuantity = widget.item.currentQuantity);
      return;
    }

    final amount = double.tryParse(value) ?? 0;
    setState(() {
      if (_adjustmentType == 'increase') {
        _newQuantity = widget.item.currentQuantity + amount;
      } else {
        _newQuantity = widget.item.currentQuantity - amount;
      }
      _newQuantity = _newQuantity.clamp(0, double.infinity);
    });
  }

  void _quickAdjust(double amount) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_adjustmentType == 'increase') {
        _newQuantity = widget.item.currentQuantity + amount;
      } else {
        _newQuantity = (widget.item.currentQuantity - amount).clamp(0, double.infinity);
      }
      _quantityController.text = amount.toStringAsFixed(1);
    });
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
              child: const Icon(Icons.close_rounded, color: AppColors.textPrimary, size: 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'تعديل الكمية',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemCard(),
              const SizedBox(height: 24),
              _buildAdjustmentTypeSelector(),
              const SizedBox(height: 24),
              _buildQuickButtons(),
              const SizedBox(height: 24),
              _buildQuantityInput(),
              const SizedBox(height: 24),
              _buildReasonInput(),
              const SizedBox(height: 24),
              _buildSummaryCard(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.info, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.qatTypeName ?? 'غير محدد',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'الكمية الحالية: ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      '${widget.item.currentQuantity.toStringAsFixed(1)} ${widget.item.unit}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع التعديل',
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TypeButton(
                icon: Icons.add_circle_rounded,
                label: 'زيادة',
                color: AppColors.success,
                isSelected: _adjustmentType == 'increase',
                onTap: () {
                  setState(() => _adjustmentType = 'increase');
                  _updateQuantity(_quantityController.text);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TypeButton(
                icon: Icons.remove_circle_rounded,
                label: 'نقص',
                color: AppColors.danger,
                isSelected: _adjustmentType == 'decrease',
                onTap: () {
                  setState(() => _adjustmentType = 'decrease');
                  _updateQuantity(_quantityController.text);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تعديل سريع',
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _QuickButton(value: 1, onTap: _quickAdjust),
            _QuickButton(value: 5, onTap: _quickAdjust),
            _QuickButton(value: 10, onTap: _quickAdjust),
            _QuickButton(value: 25, onTap: _quickAdjust),
            _QuickButton(value: 50, onTap: _quickAdjust),
            _QuickButton(value: 100, onTap: _quickAdjust),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الكمية',
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'أدخل الكمية...',
              hintStyle: AppTextStyles.inputHint,
              prefixIcon: Icon(
                _adjustmentType == 'increase' 
                    ? Icons.add_rounded 
                    : Icons.remove_rounded,
                color: _adjustmentType == 'increase' 
                    ? AppColors.success 
                    : AppColors.danger,
              ),
              suffixText: widget.item.unit,
              suffixStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
            onChanged: _updateQuantity,
          ),
        ),
      ],
    );
  }

  Widget _buildReasonInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'السبب',
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _reasonController,
            style: AppTextStyles.bodyMedium,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'اكتب سبب التعديل (اختياري)...',
              hintStyle: AppTextStyles.inputHint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final difference = _newQuantity - widget.item.currentQuantity;
    final isDifferent = difference != 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (isDifferent
                ? (difference > 0 ? AppColors.success : AppColors.danger)
                : AppColors.textSecondary).withOpacity(0.12),
            (isDifferent
                ? (difference > 0 ? AppColors.success : AppColors.danger)
                : AppColors.textSecondary).withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDifferent
              ? (difference > 0 ? AppColors.success : AppColors.danger)
              : AppColors.textSecondary).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isDifferent
                      ? (difference > 0 ? AppColors.success : AppColors.danger)
                      : AppColors.textSecondary).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calculate_rounded,
                  color: isDifferent
                      ? (difference > 0 ? AppColors.success : AppColors.danger)
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ملخص التعديل',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'الكمية الحالية',
            value: '${widget.item.currentQuantity.toStringAsFixed(1)} ${widget.item.unit}',
            color: AppColors.info,
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'التغيير',
            value: '${difference > 0 ? '+' : ''}${difference.toStringAsFixed(1)} ${widget.item.unit}',
            color: difference > 0 ? AppColors.success : AppColors.danger,
            isBold: true,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.border.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'الكمية الجديدة',
            value: '${_newQuantity.toStringAsFixed(1)} ${widget.item.unit}',
            color: AppColors.primary,
            isBold: true,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final canSave = _newQuantity != widget.item.currentQuantity;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Text(
              'إلغاء',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: canSave
                  ? const LinearGradient(
                      colors: [AppColors.info, AppColors.primary],
                    )
                  : null,
              color: canSave ? null : AppColors.disabled,
              borderRadius: BorderRadius.circular(16),
              boxShadow: canSave
                  ? [
                      BoxShadow(
                        color: AppColors.info.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canSave
                    ? () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                      }
                    : null,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'حفظ التعديل',
                      style: AppTextStyles.button.copyWith(
                        color: canSave ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.icon,
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
            ? LinearGradient(
                colors: [color, color.withOpacity(0.8)],
              )
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final double value;
  final Function(double) onTap;

  const _QuickButton({
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(value),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              value % 1 == 0 ? value.toInt().toString() : value.toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
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
