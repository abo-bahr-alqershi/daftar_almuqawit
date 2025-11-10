import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// محدد نوع القات
/// 
/// يعرض قائمة بأنواع القات المتاحة للاختيار
class QatTypeSelector extends StatelessWidget {
  final String? selectedQatTypeId;
  final ValueChanged<String?> onChanged;
  final List<QatTypeOption> qatTypes;
  final bool enabled;
  final String? errorText;

  const QatTypeSelector({
    super.key,
    this.selectedQatTypeId,
    required this.onChanged,
    required this.qatTypes,
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'نوع القات',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: qatTypes.map((qatType) {
            final isSelected = selectedQatTypeId == qatType.id;
            return InkWell(
              onTap: enabled ? () => onChanged(qatType.id) : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary 
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? AppColors.primary 
                        : errorText != null 
                            ? AppColors.danger 
                            : AppColors.border,
                    width: isSelected ? 2 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.grass,
                      color: isSelected 
                          ? AppColors.textOnDark 
                          : AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      qatType.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected 
                            ? AppColors.textOnDark 
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (qatType.price != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${qatType.price!.toStringAsFixed(0)} ريال',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected 
                              ? AppColors.textOnDark.withOpacity(0.9)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.danger,
            ),
          ),
        ],
      ],
    );
  }
}

/// خيار نوع القات
class QatTypeOption {
  final String id;
  final String name;
  final double? price;
  final String? description;

  const QatTypeOption({
    required this.id,
    required this.name,
    this.price,
    this.description,
  });
}
