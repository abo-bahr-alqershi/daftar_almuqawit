import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// مدخل الكمية مع عناصر التحكم - تصميم Tesla/iOS متطور
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

class _QuantityInputState extends State<QuantityInput>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _incrementAnimationController;
  late AnimationController _decrementAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _incrementScaleAnimation;
  late Animation<double> _decrementScaleAnimation;
  late Animation<double> _pulseAnimation;

  bool _isIncrementPressed = false;
  bool _isDecrementPressed = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(1));
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _incrementAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _decrementAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _incrementScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _incrementAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _decrementScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _decrementAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
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
    _incrementAnimationController.dispose();
    _decrementAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _increment() {
    HapticFeedback.lightImpact();
    final newValue = (widget.value + widget.step).clamp(widget.min, widget.max);
    widget.onChanged(newValue);
    _controller.text = newValue.toStringAsFixed(1);
  }

  void _decrement() {
    HapticFeedback.lightImpact();
    final newValue = (widget.value - widget.step).clamp(widget.min, widget.max);
    widget.onChanged(newValue);
    _controller.text = newValue.toStringAsFixed(1);
  }

  void _handleLongPressStart(bool isIncrement) {
    HapticFeedback.mediumImpact();
    // Start continuous increment/decrement
    _continuousChange(isIncrement);
  }

  void _continuousChange(bool isIncrement) {
    if ((isIncrement && !_isIncrementPressed) ||
        (!isIncrement && !_isDecrementPressed))
      return;

    if (isIncrement) {
      _increment();
    } else {
      _decrement();
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      _continuousChange(isIncrement);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          _buildLabel(),
          const SizedBox(height: 12),
        ],

        _buildInputContainer(),

        const SizedBox(height: 12),

        _buildQuickSelectionButtons(),
      ],
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          widget.label!,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInputContainer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surface, AppColors.surface.withOpacity(0.95)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isEditing
              ? AppColors.primary
              : AppColors.border.withOpacity(0.2),
          width: _isEditing ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isEditing
                ? AppColors.primary.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: _isEditing ? 2 : 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Decrement Button
          _buildControlButton(
            icon: Icons.remove,
            onTap: _decrement,
            onLongPressStart: () {
              setState(() => _isDecrementPressed = true);
              _handleLongPressStart(false);
            },
            onLongPressEnd: () => setState(() => _isDecrementPressed = false),
            animationController: _decrementAnimationController,
            scaleAnimation: _decrementScaleAnimation,
            isPressed: _isDecrementPressed,
            enabled: widget.value > widget.min,
          ),

          // Input Field
          Expanded(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isEditing ? _pulseAnimation.value : 1.0,
                  child: Container(
                    height: 60,
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
                              fontSize: 32,
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
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.1),
                                AppColors.accent.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.unit,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Increment Button
          _buildControlButton(
            icon: Icons.add,
            onTap: _increment,
            onLongPressStart: () {
              setState(() => _isIncrementPressed = true);
              _handleLongPressStart(true);
            },
            onLongPressEnd: () => setState(() => _isIncrementPressed = false),
            animationController: _incrementAnimationController,
            scaleAnimation: _incrementScaleAnimation,
            isPressed: _isIncrementPressed,
            enabled: widget.value < widget.max,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required VoidCallback onLongPressStart,
    required VoidCallback onLongPressEnd,
    required AnimationController animationController,
    required Animation<double> scaleAnimation,
    required bool isPressed,
    required bool enabled,
  }) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: GestureDetector(
            onTap: enabled ? onTap : null,
            onTapDown: enabled ? (_) => animationController.forward() : null,
            onTapUp: enabled ? (_) => animationController.reverse() : null,
            onTapCancel: enabled ? () => animationController.reverse() : null,
            onLongPressStart: enabled ? (_) => onLongPressStart() : null,
            onLongPressEnd: enabled ? (_) => onLongPressEnd() : null,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: isPressed
                    ? LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      )
                    : null,
                color: !isPressed
                    ? enabled
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.disabled.withOpacity(0.1)
                    : null,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: isPressed
                    ? Colors.white
                    : enabled
                    ? AppColors.primary
                    : AppColors.disabled,
                size: 28,
              ),
            ),
          ),
        );
      },
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      )
                    : null,
                color: isSelected ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border.withOpacity(0.2),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
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
