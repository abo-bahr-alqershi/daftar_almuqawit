import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

/// ويدجت معلومات التخزين
/// يعرض معلومات حول استخدام التخزين المحلي والسحابي
class StorageInfo extends StatelessWidget {
  /// مساحة التخزين المستخدمة محلياً (بالميجابايت)
  final double localStorageUsed;
  
  /// مساحة التخزين المتاحة محلياً (بالميجابايت)
  final double localStorageTotal;
  
  /// مساحة التخزين المستخدمة سحابياً (بالميجابايت)
  final double? cloudStorageUsed;
  
  /// مساحة التخزين المتاحة سحابياً (بالميجابايت)
  final double? cloudStorageTotal;
  
  /// عدد قواعد البيانات
  final int databasesCount;
  
  /// حجم قاعدة البيانات الرئيسية (بالميجابايت)
  final double databaseSize;
  
  /// عدد الصور المحفوظة
  final int imagesCount;
  
  /// حجم الصور (بالميجابايت)
  final double imagesSize;
  
  /// عند الضغط على تنظيف ذاكرة التخزين المؤقت
  final VoidCallback? onClearCache;

  const StorageInfo({
    super.key,
    required this.localStorageUsed,
    required this.localStorageTotal,
    this.cloudStorageUsed,
    this.cloudStorageTotal,
    required this.databasesCount,
    required this.databaseSize,
    required this.imagesCount,
    required this.imagesSize,
    this.onClearCache,
  });

  /// تنسيق حجم الملف
  String _formatSize(double megabytes) {
    if (megabytes < 1) {
      return '${(megabytes * 1024).toStringAsFixed(0)} KB';
    } else if (megabytes < 1024) {
      return '${megabytes.toStringAsFixed(2)} MB';
    } else {
      return '${(megabytes / 1024).toStringAsFixed(2)} GB';
    }
  }

  /// حساب نسبة الاستخدام
  double _getUsagePercentage(double used, double total) {
    if (total == 0) return 0;
    return (used / total) * 100;
  }

  /// الحصول على لون شريط التقدم حسب النسبة
  Color _getProgressColor(double percentage) {
    if (percentage >= 90) return AppColors.danger;
    if (percentage >= 70) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final localUsagePercentage = _getUsagePercentage(
      localStorageUsed,
      localStorageTotal,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // التخزين المحلي
        _StorageSection(
          title: 'التخزين المحلي',
          icon: Icons.phone_android,
          iconColor: AppColors.primary,
          used: localStorageUsed,
          total: localStorageTotal,
          usagePercentage: localUsagePercentage,
        ),

        const SizedBox(height: AppDimensions.spaceL),

        // التخزين السحابي
        if (cloudStorageUsed != null && cloudStorageTotal != null) ...[
          _StorageSection(
            title: 'التخزين السحابي',
            icon: Icons.cloud,
            iconColor: AppColors.info,
            used: cloudStorageUsed!,
            total: cloudStorageTotal!,
            usagePercentage: _getUsagePercentage(
              cloudStorageUsed!,
              cloudStorageTotal!,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceL),
        ],

        // تفاصيل التخزين
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تفاصيل التخزين',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceL),

              // قواعد البيانات
              _DetailRow(
                icon: Icons.storage,
                label: 'قواعد البيانات',
                value: '$databasesCount ملف (${_formatSize(databaseSize)})',
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: AppDimensions.spaceM),

              // الصور
              _DetailRow(
                icon: Icons.image,
                label: 'الصور المحفوظة',
                value: '$imagesCount صورة (${_formatSize(imagesSize)})',
                iconColor: AppColors.info,
              ),
              const SizedBox(height: AppDimensions.spaceM),

              // ذاكرة التخزين المؤقت
              _DetailRow(
                icon: Icons.cached,
                label: 'ذاكرة التخزين المؤقت',
                value: _formatSize(localStorageUsed - databaseSize - imagesSize),
                iconColor: AppColors.warning,
              ),
            ],
          ),
        ),

        // زر تنظيف ذاكرة التخزين المؤقت
        if (onClearCache != null) ...[
          const SizedBox(height: AppDimensions.spaceL),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onClearCache,
              icon: const Icon(Icons.cleaning_services),
              label: const Text('تنظيف ذاكرة التخزين المؤقت'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: BorderSide(color: AppColors.warning),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                  vertical: AppDimensions.paddingM,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// قسم التخزين
class _StorageSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final double used;
  final double total;
  final double usagePercentage;

  const _StorageSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.used,
    required this.total,
    required this.usagePercentage,
  });

  String _formatSize(double megabytes) {
    if (megabytes < 1) {
      return '${(megabytes * 1024).toStringAsFixed(0)} KB';
    } else if (megabytes < 1024) {
      return '${megabytes.toStringAsFixed(2)} MB';
    } else {
      return '${(megabytes / 1024).toStringAsFixed(2)} GB';
    }
  }

  Color _getProgressColor() {
    if (usagePercentage >= 90) return AppColors.danger;
    if (usagePercentage >= 70) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceL),

          // شريط التقدم
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: usagePercentage / 100,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceM),

          // معلومات الاستخدام
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatSize(used)} / ${_formatSize(total)}',
                style: AppTextStyles.bodyMedium,
              ),
              Text(
                '${usagePercentage.toStringAsFixed(1)}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _getProgressColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// صف تفاصيل
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: AppDimensions.spaceM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
