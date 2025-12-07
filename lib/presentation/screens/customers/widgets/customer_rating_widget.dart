import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomerRatingWidget extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;
  final bool readOnly;
  final bool showLabel;

  const CustomerRatingWidget({
    super.key,
    required this.initialRating,
    required this.onRatingChanged,
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
    // ضمان أن التقييم يكون ضمن النطاق المسموح (1-5)
    _rating = widget.initialRating.clamp(1.0, 5.0);
  }

  @override
  void didUpdateWidget(covariant CustomerRatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRating != widget.initialRating) {
      setState(() {
        _rating = widget.initialRating.clamp(1.0, 5.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratingColor = _getRatingColor(_rating.toInt());

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.star_outline,
                  size: 18,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'تقييم العميل',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ratingColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ratingColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'التقييم الحالي',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_rating.toInt()} من 5',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: ratingColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: widget.readOnly
                              ? null
                              : () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _rating = index + 1.0);
                                  widget.onRatingChanged(_rating);
                                },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(
                              index < _rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: ratingColor,
                              size: 28,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                if (!widget.readOnly) ...[
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 6,
                      activeTrackColor: ratingColor,
                      inactiveTrackColor: ratingColor.withOpacity(0.2),
                      thumbColor: Colors.white,
                      overlayColor: ratingColor.withOpacity(0.1),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10,
                        elevation: 4,
                      ),
                    ),
                    child: Slider(
                      value: _rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        setState(() => _rating = value);
                        widget.onRatingChanged(_rating);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return const Color(0xFF16A34A);
    if (rating >= 3) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }
}
