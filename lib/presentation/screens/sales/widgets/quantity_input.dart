import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// مدخل الكمية - تصميم راقي هادئ
class QuantityInput extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final double step;
  final String unit;
  final String? label;

  const QuantityInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1000,
    this.step = 1,
    this.unit = 'كيس',
    this.label,
  });

  @override
  State<QuantityInput> createState() => _QuantityInputState();
}

class _QuantityInputState extends State<QuantityInput> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(1));
  }

  @override
  void didUpdateWidget(QuantityInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isEditing) {
      _controller.text = widget.value.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    HapticFeedback.selectionClick();
    final newValue = (widget.value + widget.step).clamp(widget.min, widget.max);
    widget.onChanged(newValue);
    _controller.text = newValue.toStringAsFixed(1);
  }

  void _decrement() {
    HapticFeedback.selectionClick();
    final newValue = (widget.value - widget.step).clamp(widget.min, widget.max);
    widget.onChanged(newValue);
    _controller.text = newValue.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              const Icon(Icons.shopping_bag_rounded, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                widget.label!,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isEditing
                  ? AppColors.primary.withOpacity(0.4)
                  : AppColors.border.withOpacity(0.2),
              width: _isEditing ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isEditing ? 0.05 : 0.02),
                blurRadius: _isEditing ? 10 : 8,
                offset: Offset(0, _isEditing ? 3 : 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildControlButton(
                icon: Icons.remove_rounded,
                onTap: _decrement,
                enabled: widget.value > widget.min,
              ),
              Expanded(
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: TextField(
                          controller: _controller,
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          style: AppTextStyles.h2.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            fontSize: 28,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onTap: () => setState(() => _isEditing = true),
                          onChanged: (value) {
                            final number = double.tryParse(value);
                            if (number != null) {
                              widget.onChanged(
                                number.clamp(widget.min, widget.max),
                              );
                            }
                          },
                          onEditingComplete: () {
                            setState(() => _isEditing = false);
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.15),
                              AppColors.primary.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.unit,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildControlButton(
                icon: Icons.add_rounded,
                onTap: _increment,
                enabled: widget.value < widget.max,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildQuickSelectionButtons(),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.primary : AppColors.disabled,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildQuickSelectionButtons() {
    final quickValues = [1.0, 5.0, 10.0, 20.0];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: quickValues.map((value) {
        final isSelected = widget.value == value;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onChanged(value);
              _controller.text = value.toStringAsFixed(1);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      )
                    : null,
                color: isSelected ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
