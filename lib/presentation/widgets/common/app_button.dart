import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// زر تطبيق مخصص مع تصميم احترافي
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isDisabled;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDisabled = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 12,
    this.fullWidth = false,
  });

  /// زر رئيسي
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.fullWidth = false,
  })  : isOutlined = false,
        isDisabled = false,
        backgroundColor = null,
        textColor = null,
        padding = null,
        borderRadius = 12;

  /// زر ثانوي (محدد)
  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.fullWidth = false,
  })  : isOutlined = true,
        isDisabled = false,
        backgroundColor = null,
        textColor = null,
        padding = null,
        borderRadius = 12;

  /// زر خطر
  const AppButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.fullWidth = false,
  })  : isOutlined = false,
        isDisabled = false,
        backgroundColor = AppColors.danger,
        textColor = AppColors.textOnDark,
        padding = null,
        borderRadius = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? theme.primaryColor;
    final effectiveTextColor = textColor ?? AppColors.textOnDark;
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    Widget buttonContent = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? effectiveBackgroundColor : effectiveTextColor,
              ),
            ),
          )
        else if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: isOutlined ? effectiveBackgroundColor : effectiveTextColor,
          ),
          const SizedBox(width: 8),
        ],
        if (!isLoading || icon == null)
          Text(
            text,
            style: AppTextStyles.button.copyWith(
              color: isOutlined ? effectiveBackgroundColor : effectiveTextColor,
            ),
          ),
      ],
    );

    final button = isOutlined
        ? OutlinedButton(
            onPressed: isEnabled ? onPressed : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: effectiveBackgroundColor,
              side: BorderSide(
                color: isEnabled ? effectiveBackgroundColor : AppColors.disabled,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              minimumSize: Size(width ?? 0, height ?? 56),
            ),
            child: buttonContent,
          )
        : ElevatedButton(
            onPressed: isEnabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: effectiveBackgroundColor,
              foregroundColor: effectiveTextColor,
              disabledBackgroundColor: AppColors.disabled,
              elevation: 2,
              shadowColor: effectiveBackgroundColor.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              minimumSize: Size(width ?? 0, height ?? 56),
            ),
            child: buttonContent,
          );

    return fullWidth
        ? SizedBox(
            width: double.infinity,
            child: button,
          )
        : button;
  }
}

/// زر أيقونة دائري
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 48,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: color ?? AppColors.primary,
        iconSize: size * 0.5,
      ),
    );

    return tooltip != null
        ? Tooltip(
            message: tooltip!,
            child: button,
          )
        : button;
  }
}

/// زر عائم (FAB) مخصص
class AppFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;
  final Color? backgroundColor;

  const AppFloatingButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.label,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: backgroundColor ?? AppColors.primary,
        elevation: 4,
        icon: Icon(icon, color: AppColors.textOnDark),
        label: Text(
          label!,
          style: AppTextStyles.button.copyWith(color: AppColors.textOnDark),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppColors.primary,
      elevation: 4,
      child: Icon(icon, color: AppColors.textOnDark),
    );
  }
}
