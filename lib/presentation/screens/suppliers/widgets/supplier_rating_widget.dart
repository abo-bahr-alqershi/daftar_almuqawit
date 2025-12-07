import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SupplierRatingWidget extends StatefulWidget {
  final double initialRating;
  final void Function(double rating)? onRatingChanged;
  final bool readOnly;
  final bool showLabel;

  const SupplierRatingWidget({
    super.key,
    this.initialRating = 0,
    this.onRatingChanged,
    this.readOnly = false,
    this.showLabel = true,
  });

  @override
  State<SupplierRatingWidget> createState() => _SupplierRatingWidgetState();
}

class _SupplierRatingWidgetState extends State<SupplierRatingWidget> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  void _updateRating(double newRating) {
    if (!widget.readOnly) {
      HapticFeedback.selectionClick();
      setState(() => _rating = newRating);
      widget.onRatingChanged?.call(newRating);
    }
  }

  Color _getRatingColor() {
    if (_rating >= 4) return const Color(0xFF16A34A);
    if (_rating >= 3) return const Color(0xFFF59E0B);
    if (_rating >= 2) return const Color(0xFFEA580C);
    return const Color(0xFFDC2626);
  }

  String _getRatingLabel() {
    if (_rating >= 4.5) return 'ممتاز';
    if (_rating >= 4) return 'جيد جداً';
    if (_rating >= 3) return 'جيد';
    if (_rating >= 2) return 'مقبول';
    if (_rating >= 1) return 'ضعيف';
    return 'بدون تقييم';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRatingColor();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.star_rounded, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'تقييم المورد',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Rating display
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '/ 5',
                style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
              ),
              const Spacer(),
              if (widget.showLabel)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getRatingLabel(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final isFilled = _rating >= starValue;
              final isHalf = _rating >= starValue - 0.5 && _rating < starValue;

              return GestureDetector(
                onTap: widget.readOnly
                    ? null
                    : () => _updateRating(starValue.toDouble()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    isFilled
                        ? Icons.star_rounded
                        : isHalf
                        ? Icons.star_half_rounded
                        : Icons.star_outline_rounded,
                    color: (isFilled || isHalf)
                        ? color
                        : const Color(0xFFE5E7EB),
                    size: 32,
                  ),
                ),
              );
            }),
          ),

          // Slider (if not read only)
          if (!widget.readOnly) ...[
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                inactiveTrackColor: const Color(0xFFE5E7EB),
                thumbColor: color,
                overlayColor: color.withOpacity(0.1),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
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

          const SizedBox(height: 12),

          // Helper text
          Text(
            widget.readOnly
                ? 'التقييم يعبر عن جودة المنتجات والالتزام بالمواعيد.'
                : 'اضغط على النجوم أو استخدم الشريط لتعديل التقييم.',
            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

class SupplierRatingBadge extends StatelessWidget {
  final double rating;
  final bool showValue;

  const SupplierRatingBadge({
    super.key,
    required this.rating,
    this.showValue = true,
  });

  Color _getRatingColor() {
    if (rating >= 4) return const Color(0xFF16A34A);
    if (rating >= 3) return const Color(0xFFF59E0B);
    if (rating >= 2) return const Color(0xFFEA580C);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRatingColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: color, size: 14),
          if (showValue) ...[
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SupplierRatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final bool showHalfStars;

  const SupplierRatingStars({
    super.key,
    required this.rating,
    this.size = 14,
    this.color,
    this.showHalfStars = true,
  });

  Color _getRatingColor() {
    if (rating >= 4) return const Color(0xFF16A34A);
    if (rating >= 3) return const Color(0xFFF59E0B);
    if (rating >= 2) return const Color(0xFFEA580C);
    return const Color(0xFFDC2626);
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
              ? Icons.star_rounded
              : (showHalfStars && rating >= starValue - 0.5)
              ? Icons.star_half_rounded
              : Icons.star_outline_rounded,
          color: rating >= starValue - (showHalfStars ? 0.5 : 0)
              ? effectiveColor
              : const Color(0xFFE5E7EB),
          size: size,
        );
      }),
    );
  }
}
