import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SupplierFilterChips extends StatefulWidget {
  final String? selectedTrustLevel;
  final int? selectedQualityRating;
  final void Function(String?) onTrustLevelChanged;
  final void Function(int?) onQualityRatingChanged;
  final VoidCallback? onClearFilters;

  const SupplierFilterChips({
    super.key,
    this.selectedTrustLevel,
    this.selectedQualityRating,
    required this.onTrustLevelChanged,
    required this.onQualityRatingChanged,
    this.onClearFilters,
  });

  @override
  State<SupplierFilterChips> createState() => _SupplierFilterChipsState();
}

class _SupplierFilterChipsState extends State<SupplierFilterChips>
    with TickerProviderStateMixin {
  late List<AnimationController> _chipControllers;

  @override
  void initState() {
    super.initState();
    _chipControllers = List.generate(
      9,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300 + (index * 50)),
        vsync: this,
      ),
    );

    _animateChips();
  }

  Future<void> _animateChips() async {
    for (var controller in _chipControllers) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (mounted) {
        controller.forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _chipControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        widget.selectedTrustLevel != null || widget.selectedQualityRating != null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.info.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'تصفية حسب:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (hasActiveFilters)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onClearFilters?.call();
                      widget.onTrustLevelChanged(null);
                      widget.onQualityRatingChanged(null);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.danger.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.clear_all_rounded,
                            size: 16,
                            color: AppColors.danger,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'مسح',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildAnimatedChip(
                  0,
                  label: 'ممتاز',
                  icon: Icons.verified_rounded,
                  color: AppColors.success,
                  isSelected: widget.selectedTrustLevel == 'ممتاز',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onTrustLevelChanged(
                      widget.selectedTrustLevel == 'ممتاز' ? null : 'ممتاز',
                    );
                  },
                ),
                const SizedBox(width: 10),
                _buildAnimatedChip(
                  1,
                  label: 'جيد',
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                  isSelected: widget.selectedTrustLevel == 'جيد',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onTrustLevelChanged(
                      widget.selectedTrustLevel == 'جيد' ? null : 'جيد',
                    );
                  },
                ),
                const SizedBox(width: 10),
                _buildAnimatedChip(
                  2,
                  label: 'متوسط',
                  icon: Icons.warning_rounded,
                  color: AppColors.warning,
                  isSelected: widget.selectedTrustLevel == 'متوسط',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onTrustLevelChanged(
                      widget.selectedTrustLevel == 'متوسط' ? null : 'متوسط',
                    );
                  },
                ),
                const SizedBox(width: 10),
                _buildAnimatedChip(
                  3,
                  label: 'ضعيف',
                  icon: Icons.error_rounded,
                  color: AppColors.danger,
                  isSelected: widget.selectedTrustLevel == 'ضعيف',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onTrustLevelChanged(
                      widget.selectedTrustLevel == 'ضعيف' ? null : 'ضعيف',
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              children: List.generate(5, (index) {
                final rating = 5 - index;
                return Padding(
                  padding: EdgeInsets.only(left: index < 4 ? 10 : 0),
                  child: _buildAnimatedChip(
                    4 + index,
                    rating: rating,
                    isSelected: widget.selectedQualityRating == rating,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onQualityRatingChanged(
                        widget.selectedQualityRating == rating ? null : rating,
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedChip(
    int index, {
    String? label,
    IconData? icon,
    Color? color,
    int? rating,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final effectiveColor = color ?? _getRatingColor(rating ?? 0);

    return AnimatedBuilder(
      animation: _chipControllers[index],
      builder: (context, child) {
        final scale = Tween<double>(begin: 0, end: 1)
            .animate(CurvedAnimation(
              parent: _chipControllers[index],
              curve: Curves.elasticOut,
            ))
            .value;

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [effectiveColor, effectiveColor.withOpacity(0.8)],
                      )
                    : null,
                color: isSelected ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : effectiveColor.withOpacity(0.3),
                  width: isSelected ? 0 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: effectiveColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null)
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected ? Colors.white : effectiveColor,
                    )
                  else
                    Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: isSelected ? Colors.white : effectiveColor,
                    ),
                  const SizedBox(width: 6),
                  Text(
                    label ?? rating.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white : effectiveColor,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return AppColors.success;
    if (rating >= 3) return const Color(0xFFFFD700);
    if (rating >= 2) return AppColors.warning;
    return AppColors.danger;
  }
}
