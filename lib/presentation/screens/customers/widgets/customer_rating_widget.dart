import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

/// ويدجت تقييم العميل
class CustomerRatingWidget extends StatefulWidget {
  final double initialRating;
  final void Function(double rating)? onRatingChanged;
  final bool readOnly;
  final bool showLabel;

  const CustomerRatingWidget({
    super.key,
    this.initialRating = 0,
    this.onRatingChanged,
    this.readOnly = false,
    this.showLabel = true,
  });

  @override
  State<CustomerRatingWidget> createState() => _CustomerRatingWidgetState();
}

class _CustomerRatingWidgetState extends State<CustomerRatingWidget> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  void _updateRating(double newRating) {
    if (!widget.readOnly) {
      setState(() {
        _rating = newRating;
      });
      widget.onRatingChanged?.call(newRating);
    }
  }

  Color _getRatingColor() {
    if (_rating >= 4) return AppColors.success;
    if (_rating >= 3) return AppColors.warning;
    if (_rating >= 2) return AppColors.expense;
    return AppColors.danger;
  }

  String _getRatingLabel() {
    if (_rating >= 4.5) return 'ممتاز';
    if (_rating >= 4) return 'جيد جداً';
    if (_rating >= 3) return 'جيد';
    if (_rating >= 2) return 'مقبول';
    if (_rating >= 1) return 'ضعيف';
    return 'بدون تقييم';
  }

  IconData _getRatingIcon() {
    if (_rating >= 4) return Icons.sentiment_very_satisfied;
    if (_rating >= 3) return Icons.sentiment_satisfied;
    if (_rating >= 2) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }

  @override
  Widget build(BuildContext context) {
    final ratingColor = _getRatingColor();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: ratingColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              Icon(
                Icons.star,
                color: ratingColor,
                size: 24,
              ),
              const SizedBox(width: AppDimensions.spaceS),
              Text(
                'تقييم العميل',
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),
          
          // التقييم الرقمي مع الأيقونة
          Row(
            children: [
              // الأيقونة التعبيرية
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: ratingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(
                  _getRatingIcon(),
                  color: ratingColor,
                  size: 48,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              
              // التقييم الرقمي والتسمية
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _rating.toStringAsFixed(1),
                      style: AppTextStyles.numberLarge.copyWith(
                        color: ratingColor,
                        fontSize: 40,
                      ),
                    ),
                    if (widget.showLabel) ...[
                      const SizedBox(height: 4),
                      Text(
                        _getRatingLabel(),
                        style: AppTextStyles.titleSmall.copyWith(
                          color: ratingColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceL),
          
          // النجوم التفاعلية
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return GestureDetector(
                onTap: widget.readOnly ? null : () => _updateRating(starValue.toDouble()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    _rating >= starValue
                        ? Icons.star
                        : _rating >= starValue - 0.5
                            ? Icons.star_half
                            : Icons.star_border,
                    color: _rating >= starValue - 0.5 ? ratingColor : AppColors.border,
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          
          // شريط التقييم
          if (!widget.readOnly) ...[
            const SizedBox(height: AppDimensions.spaceM),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: ratingColor,
                inactiveTrackColor: AppColors.border,
                thumbColor: ratingColor,
                overlayColor: ratingColor.withOpacity(0.2),
                trackHeight: 4,
              ),
              child: Slider(
                value: _rating,
                min: 0,
                max: 5,
                divisions: 10,
                onChanged: _updateRating,
              ),
            ),
          ],
          
          // معلومات إضافية
          const SizedBox(height: AppDimensions.spaceM),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingS),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.readOnly
                        ? 'التقييم بناءً على سجل التعاملات والالتزام بالسداد'
                        : 'انقر على النجوم أو اسحب الشريط لتغيير التقييم',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // مؤشر التفاعل
          if (!widget.readOnly) ...[
            const SizedBox(height: AppDimensions.spaceS),
            Center(
              child: Text(
                'تم التحديث',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ويدجت عرض التقييم المبسط (للبطاقات)
class CustomerRatingBadge extends StatelessWidget {
  final double rating;
  final bool showValue;

  const CustomerRatingBadge({
    super.key,
    required this.rating,
    this.showValue = true,
  });

  Color _getRatingColor() {
    if (rating >= 4) return AppColors.success;
    if (rating >= 3) return AppColors.warning;
    if (rating >= 2) return AppColors.expense;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRatingColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: color,
            size: 14,
          ),
          if (showValue) ...[
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ويدجت عرض النجوم فقط
class CustomerRatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final bool showHalfStars;

  const CustomerRatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
    this.showHalfStars = true,
  });

  Color _getRatingColor() {
    if (rating >= 4) return AppColors.success;
    if (rating >= 3) return AppColors.warning;
    if (rating >= 2) return AppColors.expense;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? _getRatingColor();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return Icon(
          rating >= starValue
              ? Icons.star
              : (showHalfStars && rating >= starValue - 0.5)
                  ? Icons.star_half
                  : Icons.star_border,
          color: rating >= starValue - (showHalfStars ? 0.5 : 0) 
              ? effectiveColor 
              : AppColors.border,
          size: size,
        );
      }),
    );
  }
}
