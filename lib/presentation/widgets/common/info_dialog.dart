import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// نافذة معلومات مخصصة
/// 
/// تستخدم لعرض رسائل معلوماتية للمستخدم
class InfoDialog extends StatelessWidget {
  /// العنوان الرئيسي
  final String title;
  
  /// محتوى الرسالة
  final String message;
  
  /// نوع الرسالة (معلومات، نجاح، تحذير، خطأ)
  final InfoDialogType type;
  
  /// نص زر الإغلاق
  final String closeButtonText;
  
  /// دالة يتم استدعاؤها عند إغلاق الحوار
  final VoidCallback? onClose;

  const InfoDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = InfoDialogType.info,
    this.closeButtonText = 'حسناً',
    this.onClose,
  });

  /// عرض الحوار
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    InfoDialogType type = InfoDialogType.info,
    String closeButtonText = 'حسناً',
    VoidCallback? onClose,
  }) {
    return showDialog(
      context: context,
      builder: (context) => InfoDialog(
        title: title,
        message: message,
        type: type,
        closeButtonText: closeButtonText,
        onClose: onClose,
      ),
    );
  }

  /// عرض رسالة نجاح
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String closeButtonText = 'حسناً',
    VoidCallback? onClose,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: InfoDialogType.success,
      closeButtonText: closeButtonText,
      onClose: onClose,
    );
  }

  /// عرض رسالة خطأ
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String closeButtonText = 'حسناً',
    VoidCallback? onClose,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: InfoDialogType.error,
      closeButtonText: closeButtonText,
      onClose: onClose,
    );
  }

  /// عرض رسالة تحذير
  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    required String message,
    String closeButtonText = 'حسناً',
    VoidCallback? onClose,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: InfoDialogType.warning,
      closeButtonText: closeButtonText,
      onClose: onClose,
    );
  }

  Color _getIconColor() {
    switch (type) {
      case InfoDialogType.success:
        return AppColors.success;
      case InfoDialogType.error:
        return AppColors.danger;
      case InfoDialogType.warning:
        return AppColors.warning;
      case InfoDialogType.info:
        return AppColors.info;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case InfoDialogType.success:
        return Icons.check_circle;
      case InfoDialogType.error:
        return Icons.error;
      case InfoDialogType.warning:
        return Icons.warning;
      case InfoDialogType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _getIconColor().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(),
                size: 32,
                color: _getIconColor(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onClose?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getIconColor(),
                  foregroundColor: AppColors.textOnDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  closeButtonText,
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// أنواع حوارات المعلومات
enum InfoDialogType {
  info,
  success,
  warning,
  error,
}
