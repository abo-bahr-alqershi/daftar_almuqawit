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

class _SupplierFilterChipsState extends State<SupplierFilterChips> {
  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        widget.selectedTrustLevel != null ||
        widget.selectedQualityRating != null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.tune_outlined,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                const Text(
                  'تصفية حسب:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
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
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close, size: 12, color: Color(0xFFDC2626)),
                          SizedBox(width: 4),
                          Text(
                            'مسح',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Trust level chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildTrustChip('ممتاز', const Color(0xFF16A34A)),
                const SizedBox(width: 8),
                _buildTrustChip('جيد', const Color(0xFF0EA5E9)),
                const SizedBox(width: 8),
                _buildTrustChip('متوسط', const Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                _buildTrustChip('ضعيف', const Color(0xFFDC2626)),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Rating chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: List.generate(5, (index) {
                final rating = 5 - index;
                return Padding(
                  padding: EdgeInsets.only(left: index < 4 ? 8 : 0),
                  child: _buildRatingChip(rating),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustChip(String label, Color color) {
    final isSelected = widget.selectedTrustLevel == label;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTrustLevelChanged(isSelected ? null : label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingChip(int rating) {
    final isSelected = widget.selectedQualityRating == rating;
    final color = _getRatingColor(rating);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onQualityRatingChanged(isSelected ? null : rating);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_rounded,
              size: 14,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 4),
            Text(
              rating.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return const Color(0xFF16A34A);
    if (rating >= 3) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }
}
