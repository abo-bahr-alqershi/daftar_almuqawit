import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// بطاقة ملخص الإحصائيات - تصميم راقي ونظيف
class SummaryCard extends StatefulWidget {
  const SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
    this.subtitle,
    this.onTap,
    this.percentage,
    this.showChart = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;
  final double? percentage;
  final bool showChart;

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.onTap != null) {
          HapticFeedback.lightImpact();
          widget.onTap!();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isPressed
                ? widget.color.withOpacity(0.3)
                : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: _isPressed
                  ? widget.color.withOpacity(0.1)
                  : Colors.black.withOpacity(0.04),
              blurRadius: _isPressed ? 16 : 12,
              offset: Offset(0, _isPressed ? 6 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 22),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Value
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final numericValue =
                    double.tryParse(
                      widget.value.replaceAll(RegExp(r'[^\d.]'), ''),
                    ) ??
                    0;
                final animatedValue = (numericValue * _controller.value)
                    .toStringAsFixed(0);
                final suffix = widget.value
                    .replaceAll(RegExp(r'[\d.]'), '')
                    .trim();

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      animatedValue,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: widget.color,
                        letterSpacing: -0.5,
                        height: 1,
                      ),
                    ),
                    if (suffix.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          suffix,
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.color.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),

            // Progress Chart
            if (widget.showChart && widget.percentage != null) ...[
              const SizedBox(height: 18),
              _buildProgressBar(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'معدل الإنجاز',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Text(
                  '${((widget.percentage ?? 0) * _controller.value * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: widget.color,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FractionallySizedBox(
                widthFactor: (widget.percentage ?? 0) * _controller.value,
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.color, widget.color.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
