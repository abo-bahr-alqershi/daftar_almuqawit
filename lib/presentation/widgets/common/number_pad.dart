import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// لوحة أرقام مخصصة
/// 
/// تستخدم لإدخال الأرقام بشكل سريع وسهل
class NumberPad extends StatelessWidget {
  /// دالة يتم استدعاؤها عند الضغط على رقم
  final ValueChanged<String> onNumberPressed;
  
  /// دالة يتم استدعاؤها عند الضغط على زر المسح
  final VoidCallback? onDeletePressed;
  
  /// دالة يتم استدعاؤها عند الضغط على زر التأكيد
  final VoidCallback? onConfirmPressed;
  
  /// هل يظهر زر النقطة العشرية
  final bool showDecimal;
  
  /// نص زر التأكيد
  final String? confirmButtonText;
  
  /// لون الأزرار
  final Color? buttonColor;
  
  /// لون النص
  final Color? textColor;

  const NumberPad({
    super.key,
    required this.onNumberPressed,
    this.onDeletePressed,
    this.onConfirmPressed,
    this.showDecimal = true,
    this.confirmButtonText,
    this.buttonColor,
    this.textColor,
  });

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
    IconData? icon,
    bool isWide = false,
  }) {
    return Expanded(
      flex: isWide ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? buttonColor ?? AppColors.surface,
            foregroundColor: foregroundColor ?? textColor ?? AppColors.textPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.border, width: 1),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: icon != null
              ? Icon(icon, size: 24)
              : Text(
                  text,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: foregroundColor ?? textColor ?? AppColors.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildButton(text: '1', onPressed: () => onNumberPressed('1')),
              _buildButton(text: '2', onPressed: () => onNumberPressed('2')),
              _buildButton(text: '3', onPressed: () => onNumberPressed('3')),
            ],
          ),
          Row(
            children: [
              _buildButton(text: '4', onPressed: () => onNumberPressed('4')),
              _buildButton(text: '5', onPressed: () => onNumberPressed('5')),
              _buildButton(text: '6', onPressed: () => onNumberPressed('6')),
            ],
          ),
          Row(
            children: [
              _buildButton(text: '7', onPressed: () => onNumberPressed('7')),
              _buildButton(text: '8', onPressed: () => onNumberPressed('8')),
              _buildButton(text: '9', onPressed: () => onNumberPressed('9')),
            ],
          ),
          Row(
            children: [
              if (showDecimal)
                _buildButton(text: '.', onPressed: () => onNumberPressed('.'))
              else
                const Spacer(),
              _buildButton(text: '0', onPressed: () => onNumberPressed('0')),
              if (onDeletePressed != null)
                _buildButton(
                  text: '',
                  icon: Icons.backspace_outlined,
                  onPressed: onDeletePressed!,
                )
              else
                const Spacer(),
            ],
          ),
          if (onConfirmPressed != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.all(4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onConfirmPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    confirmButtonText ?? 'تأكيد',
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// حقل إدخال مع لوحة أرقام
/// 
/// يجمع بين حقل الإدخال ولوحة الأرقام في واجهة واحدة
class NumberPadTextField extends StatefulWidget {
  /// التسمية
  final String? label;
  
  /// النص التلميحي
  final String? hint;
  
  /// القيمة الابتدائية
  final String? initialValue;
  
  /// دالة يتم استدعاؤها عند تغيير القيمة
  final ValueChanged<String>? onChanged;
  
  /// دالة يتم استدعاؤها عند التأكيد
  final ValueChanged<String>? onSubmitted;
  
  /// هل يظهر زر النقطة العشرية
  final bool showDecimal;
  
  /// الحد الأقصى لعدد الأحرف
  final int? maxLength;

  const NumberPadTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.showDecimal = true,
    this.maxLength,
  });

  @override
  State<NumberPadTextField> createState() => _NumberPadTextFieldState();
}

class _NumberPadTextFieldState extends State<NumberPadTextField> {
  late String _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue ?? '';
  }

  void _handleNumberPressed(String number) {
    if (widget.maxLength != null && _value.length >= widget.maxLength!) {
      return;
    }
    
    if (number == '.' && _value.contains('.')) {
      return;
    }

    setState(() {
      _value += number;
    });
    widget.onChanged?.call(_value);
  }

  void _handleDelete() {
    if (_value.isEmpty) return;

    setState(() {
      _value = _value.substring(0, _value.length - 1);
    });
    widget.onChanged?.call(_value);
  }

  void _handleConfirm() {
    widget.onSubmitted?.call(_value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Text(
            _value.isEmpty ? (widget.hint ?? '0') : _value,
            style: AppTextStyles.headlineLarge.copyWith(
              color: _value.isEmpty ? AppColors.textHint : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        NumberPad(
          onNumberPressed: _handleNumberPressed,
          onDeletePressed: _handleDelete,
          onConfirmPressed: widget.onSubmitted != null ? _handleConfirm : null,
          showDecimal: widget.showDecimal,
        ),
      ],
    );
  }
}
