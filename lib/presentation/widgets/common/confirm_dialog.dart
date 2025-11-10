import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Dialog تأكيد
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final IconData? icon;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.icon,
  });

  /// Dialog حذف
  const ConfirmDialog.delete({
    super.key,
    required this.title,
    required this.message,
    this.onConfirm,
    this.onCancel,
  })  : confirmText = 'حذف',
        cancelText = 'إلغاء',
        confirmColor = AppColors.danger,
        icon = Icons.delete_outline;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (confirmColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: confirmColor ?? AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: Text(
            cancelText ?? 'إلغاء',
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? AppColors.primary,
            foregroundColor: AppColors.textOnDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(confirmText ?? 'تأكيد'),
        ),
      ],
    );
  }

  /// إظهار Dialog التأكيد
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
    IconData? icon,
    bool isDangerous = false,
    bool isDestructive = false,
  }) {
    final effectiveColor = isDangerous || isDestructive 
        ? AppColors.danger 
        : (confirmColor ?? AppColors.primary);
    
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: effectiveColor,
        icon: icon ?? (isDangerous || isDestructive ? Icons.warning_outlined : null),
        onConfirm: () {},
      ),
    );
  }
}

/// دالة مساعدة لإظهار dialog التأكيد
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmText,
  String? cancelText,
  Color? confirmColor,
  IconData? icon,
  bool isDangerous = false,
  bool isDestructive = false,
}) {
  return ConfirmDialog.show(
    context,
    title: title,
    message: message,
    confirmText: confirmText,
    cancelText: cancelText,
    confirmColor: confirmColor,
    icon: icon,
    isDangerous: isDangerous,
    isDestructive: isDestructive,
  );
}
