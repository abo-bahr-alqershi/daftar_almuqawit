import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// حقل إدخال مخصص مع تصميم احترافي
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? initialValue;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final String? errorText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.initialValue,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.contentPadding,
  });

  /// حقل بحث
  const AppTextField.search({
    super.key,
    this.controller,
    this.hint = 'البحث...',
    this.onChanged,
    this.onSubmitted,
  })  : label = null,
        initialValue = null,
        prefixIcon = Icons.search,
        suffixIcon = null,
        onSuffixIconTap = null,
        keyboardType = TextInputType.text,
        obscureText = false,
        enabled = true,
        readOnly = false,
        maxLines = 1,
        maxLength = null,
        errorText = null,
        validator = null,
        onTap = null,
        inputFormatters = null,
        textInputAction = TextInputAction.search,
        focusNode = null,
        autofocus = false,
        contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  /// حقل رقمي
  const AppTextField.number({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.onChanged,
    this.validator,
    this.errorText,
  })  : initialValue = null,
        suffixIcon = null,
        onSuffixIconTap = null,
        keyboardType = TextInputType.number,
        obscureText = false,
        enabled = true,
        readOnly = false,
        maxLines = 1,
        maxLength = null,
        onSubmitted = null,
        onTap = null,
        inputFormatters = null,
        textInputAction = null,
        focusNode = null,
        autofocus = false,
        contentPadding = null;

  /// حقل مبلغ مالي
  const AppTextField.currency({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.onChanged,
    this.validator,
    this.errorText,
    this.readOnly = false,
  })  : initialValue = null,
        prefixIcon = Icons.attach_money,
        suffixIcon = null,
        onSuffixIconTap = null,
        keyboardType = const TextInputType.numberWithOptions(decimal: true),
        obscureText = false,
        enabled = true,
        maxLines = 1,
        maxLength = null,
        onSubmitted = null,
        onTap = null,
        inputFormatters = null,
        textInputAction = null,
        focusNode = null,
        autofocus = false,
        contentPadding = null;

  /// حقل هاتف
  const AppTextField.phone({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.onChanged,
    this.validator,
    this.errorText,
  })  : initialValue = null,
        prefixIcon = Icons.phone,
        suffixIcon = null,
        onSuffixIconTap = null,
        keyboardType = TextInputType.phone,
        obscureText = false,
        enabled = true,
        readOnly = false,
        maxLines = 1,
        maxLength = 15,
        onSubmitted = null,
        onTap = null,
        inputFormatters = null,
        textInputAction = null,
        focusNode = null,
        autofocus = false,
        contentPadding = null;

  /// حقل نص متعدد الأسطر
  const AppTextField.multiline({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.maxLines = 4,
    this.onChanged,
    this.validator,
    this.errorText,
  })  : initialValue = null,
        prefixIcon = null,
        suffixIcon = null,
        onSuffixIconTap = null,
        keyboardType = TextInputType.multiline,
        obscureText = false,
        enabled = true,
        readOnly = false,
        maxLength = null,
        onSubmitted = null,
        onTap = null,
        inputFormatters = null,
        textInputAction = TextInputAction.newline,
        focusNode = null,
        autofocus = false,
        contentPadding = null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          focusNode: focusNode,
          autofocus: autofocus,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
                : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon, color: AppColors.textSecondary, size: 20),
                    onPressed: onSuffixIconTap,
                  )
                : null,
            errorText: errorText,
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.disabled.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.danger, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.danger, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.disabled, width: 1.5),
            ),
            contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            counterText: '',
          ),
        ),
      ],
    );
  }
}

/// حقل اختيار من قائمة منسدلة
class AppDropdownField<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? errorText;
  final IconData? prefixIcon;
  final bool enabled;

  const AppDropdownField({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.errorText,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
                : null,
            errorText: errorText,
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.disabled.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: AppTextStyles.bodyMedium,
          dropdownColor: AppColors.surface,
          icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
