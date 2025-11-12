import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

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

class _CustomerRatingWidgetState extends State<CustomerRatingWidget>
    with TickerProviderStateMixin {
  late double _rating;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late List<AnimationController> _starControllers;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _starControllers = List.generate(
      5,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 50)),
        vsync: this,
      ),
    );

    _animateStars();
  }

  Future<void> _animateStars() async {
    for (var controller in _starControllers) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    for (var controller in _starControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateRating(double newRating) {
    if (!widget.readOnly) {
      HapticFeedback.selectionClick();
      setState(() {
        _rating = newRating;
      });
      _scaleController.forward().then((_) => _scaleController.reverse());
      _rotationController.forward().then((_) => _rotationController.reset());
      widget.onRatingChanged?.call(newRating);
    }
  }

  Color _getRatingColor() {
    if (_rating >= 4) return AppColors.success;
    if (_rating >= 3) return const Color(0xFFFFD700);
    if (_rating >= 2) return AppColors.warning;
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
    if (_rating >= 4) return Icons.sentiment_very_satisfied_rounded;
    if (_rating >= 3) return Icons.sentiment_satisfied_rounded;
    if (_rating >= 2) return Icons.sentiment_neutral_rounded;
    return Icons.sentiment_dissatisfied_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final ratingColor = _getRatingColor();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surface.withOpacity(0.98)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ratingColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ratingColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ratingColor,
                      ratingColor.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ratingColor.withOpacity(0.2),
                              ratingColor.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.star_rounded,
                          color: ratingColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'تقييم العميل',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _scaleAnimation,
                          _rotationController,
                        ]),
                        builder: (context, child) => Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Transform.rotate(
                            angle: _rotationController.value * 0.1,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    ratingColor.withOpacity(0.15),
                                    ratingColor.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: ratingColor.withOpacity(0.2),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getRatingIcon(),
                                color: ratingColor,
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: _rating),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) => Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    value.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: ratingColor,
                                      height: 1,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8, right: 4),
                                    child: Text(
                                      '/ 5',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: ratingColor.withOpacity(0.6),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.showLabel) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      ratingColor.withOpacity(0.2),
                                      ratingColor.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _getRatingLabel(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ratingColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return GestureDetector(
                        onTap: widget.readOnly
                            ? null
                            : () => _updateRating(starValue.toDouble()),
                        child: AnimatedBuilder(
                          animation: _starControllers[index],
                          builder: (context, child) {
                            final scale = Tween<double>(begin: 0, end: 1)
                                .animate(CurvedAnimation(
                                  parent: _starControllers[index],
                                  curve: Curves.elasticOut,
                                ))
                                .value;

                            return Transform.scale(
                              scale: scale,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  _rating >= starValue
                                      ? Icons.star_rounded
                                      : _rating >= starValue - 0.5
                                          ? Icons.star_half_rounded
                                          : Icons.star_outline_rounded,
                                  color: _rating >= starValue - 0.5
                                      ? ratingColor
                                      : AppColors.border.withOpacity(0.5),
                                  size: 36,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ),

                  if (!widget.readOnly) ...[
                    const SizedBox(height: 24),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: ratingColor,
                        inactiveTrackColor: AppColors.border.withOpacity(0.3),
                        thumbColor: ratingColor,
                        overlayColor: ratingColor.withOpacity(0.2),
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
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

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.03),
                          AppColors.info.withOpacity(0.02),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.readOnly
                                ? 'التقييم بناءً على سجل التعاملات والالتزام بالسداد'
                                : 'انقر على النجوم أو اسحب الشريط لتغيير التقييم',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    if (rating >= 3) return const Color(0xFFFFD700);
    if (rating >= 2) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRatingColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: color,
            size: 16,
          ),
          if (showValue) ...[
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

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
    if (rating >= 3) return const Color(0xFFFFD700);
    if (rating >= 2) return AppColors.warning;
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
              ? Icons.star_rounded
              : (showHalfStars && rating >= starValue - 0.5)
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          color: rating >= starValue - (showHalfStars ? 0.5 : 0)
              ? effectiveColor
              : AppColors.border.withOpacity(0.4),
          size: size,
        );
      }),
    );
  }
}
