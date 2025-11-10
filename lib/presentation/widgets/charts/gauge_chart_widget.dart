import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// ويدجت مقياس دائري
class GaugeChartWidget extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final String? title;
  final Color? color;

  const GaugeChartWidget({
    super.key,
    required this.value,
    this.minValue = 0,
    this.maxValue = 100,
    this.title,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    return Column(
      children: [
        if (title != null) Text(title!, style: AppTextStyles.headlineSmall),
        SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: _GaugePainter(percentage: percentage, color: color ?? AppColors.primary),
            child: Center(child: Text(value.toStringAsFixed(1), style: AppTextStyles.headlineLarge)),
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percentage;
  final Color color;
  _GaugePainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 15;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi * 0.75, math.pi * 1.5 * percentage, false, paint);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) => oldDelegate.percentage != percentage;
}
