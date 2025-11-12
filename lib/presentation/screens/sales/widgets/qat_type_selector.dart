import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// محدد نوع القات - تصميم راقي هادئ
class QatTypeSelector extends StatefulWidget {
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
  State<QatTypeSelector> createState() => _QatTypeSelectorState();
}

class _QatTypeSelectorState extends State<QatTypeSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success.withOpacity(0.2),
                    AppColors.success.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.grass_rounded,
                color: AppColors.success,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'نوع القات',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${widget.qatTypes.length} نوع',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.danger.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_rounded, color: AppColors.danger, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: TextStyle(color: AppColors.danger, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: widget.qatTypes.length,
          itemBuilder: (context, index) {
            final qatType = widget.qatTypes[index];
            final isSelected = widget.selectedQatTypeId == qatType.id;

            return GestureDetector(
              onTap: widget.enabled
                  ? () {
                      HapticFeedback.selectionClick();
                      widget.onChanged(qatType.id);
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            AppColors.success.withOpacity(0.15),
                            AppColors.success.withOpacity(0.08),
                          ],
                        )
                      : null,
                  color: isSelected ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.success.withOpacity(0.4)
                        : AppColors.border.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isSelected ? 0.05 : 0.02),
                      blurRadius: isSelected ? 12 : 8,
                      offset: Offset(0, isSelected ? 4 : 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [AppColors.success, AppColors.info],
                              )
                            : null,
                        color: isSelected ? null : AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.grass_rounded,
                        color: isSelected ? Colors.white : AppColors.success,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      qatType.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.success : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (qatType.description != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        qatType.description!,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (qatType.price != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${qatType.price!.toStringAsFixed(0)} ر.س',
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
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
