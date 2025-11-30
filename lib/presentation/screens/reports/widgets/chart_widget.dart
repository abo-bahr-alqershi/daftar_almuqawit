/// ويدجت المخطط البياني
/// ويدجت لعرض المخططات البيانية في التقارير
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// نوع المخطط
enum ChartType {
  /// مخطط خطي
  line,

  /// مخطط شريطي
  bar,

  /// مخطط دائري
  pie,
}

/// بيانات نقطة في المخطط
class ChartDataPoint {
  const ChartDataPoint({required this.label, required this.value, this.color});

  /// التسمية
  final String label;

  /// القيمة
  final double value;

  /// اللون (اختياري)
  final Color? color;
}

/// ويدجت المخطط البياني
class ChartWidget extends StatelessWidget {
  const ChartWidget({
    required this.title,
    required this.chartType,
    required this.data,
    super.key,
    this.height = 250,
    this.primaryColor = AppColors.primary,
  });

  /// عنوان المخطط
  final String title;

  /// نوع المخطط
  final ChartType chartType;

  /// بيانات المخطط
  final List<ChartDataPoint> data;

  /// ارتفاع المخطط
  final double height;

  /// لون أساسي للمخطط
  final Color primaryColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان المخطط
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        // المخطط
        SizedBox(height: height, child: _buildChart()),

        const SizedBox(height: 16),

        // مفتاح المخطط
        _buildLegend(),
      ],
    ),
  );

  /// بناء المخطط حسب النوع
  Widget _buildChart() {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'لا توجد بيانات لعرضها',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    switch (chartType) {
      case ChartType.line:
        return _buildLineChart();
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.pie:
        return _buildPieChart();
    }
  }

  /// بناء مخطط خطي
  Widget _buildLineChart() {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    // تحضير الألوان لكل نقطة كما في المخطط الشريطي ومفتاح المخطط
    final colors = data.asMap().entries
        .map((entry) => entry.value.color ?? _getColorForIndex(entry.key))
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _LineChartPainter(
            points: data,
            colors: colors,
            primaryColor: primaryColor,
          ),
        );
      },
    );
  }

  /// بناء مخطط شريطي
  Widget _buildBarChart() {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    if (maxValue <= 0 || maxValue.isNaN || maxValue.isInfinite) {
      return Center(
        child: Text(
          'بيانات غير صالحة',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final availableHeight = height > 100 ? height - 60 : 40;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final dataPoint = entry.value;
        final value = dataPoint.value.isFinite ? dataPoint.value : 0.0;
        final heightRatio = value / maxValue;
        final barColor = dataPoint.color ?? _getColorForIndex(index);

        final barHeight = (availableHeight * heightRatio).clamp(
          0.0,
          availableHeight,
        );

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  value.toStringAsFixed(0),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Container(
                  height: barHeight.toDouble(),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [barColor, barColor.withOpacity(0.7)],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  dataPoint.label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// بناء مخطط دائري
  Widget _buildPieChart() {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = data.fold<double>(0, (sum, d) => sum + d.value);
    if (total <= 0 || total.isNaN || total.isInfinite) {
      return Center(
        child: Text(
          'بيانات غير صالحة',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final colors = data.asMap().entries
        .map((entry) => entry.value.color ?? _getColorForIndex(entry.key))
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: CustomPaint(
            size: Size(size, size),
            painter: _PieChartPainter(
              points: data,
              colors: colors,
            ),
          ),
        );
      },
    );
  }

  /// بناء مفتاح المخطط
  Widget _buildLegend() => Wrap(
    spacing: 16,
    runSpacing: 8,
    children: data.asMap().entries.map((entry) {
      final index = entry.key;
      final dataPoint = entry.value;
      final color = dataPoint.color ?? _getColorForIndex(index);

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),

          const SizedBox(width: 6),

          Text(
            dataPoint.label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    }).toList(),
  );
 }

/// الحصول على لون افتراضي لمؤشر معين
Color _getColorForIndex(int index) {
  final colors = [
    AppColors.primary,
    AppColors.sales,
    AppColors.purchases,
    AppColors.expense,
    AppColors.debt,
    AppColors.accent,
  ];

  return colors[index % colors.length];
}

class SimpleTrendChart extends StatelessWidget {
  const SimpleTrendChart({
    required this.title,
    required this.data,
    super.key,
    this.height = 200,
    this.primaryColor = AppColors.primary,
  });

  final String title;
  final List<ChartDataPoint> data;
  final double height;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withOpacity(0.08)),
        ),
        child: Center(
          child: Text(
            'لا توجد بيانات لعرضها',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final total = data.fold<double>(0, (sum, p) => sum + p.value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Text(
                total.toStringAsFixed(0),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final colors = data
                    .asMap()
                    .entries
                    .map((entry) =>
                        entry.value.color ?? AppColors.primary.withOpacity(0.9))
                    .toList();

                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _LineChartPainter(
                    points: data,
                    colors: colors,
                    primaryColor: primaryColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// رسام المخطط الخطي
class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.points,
    required this.colors,
    required this.primaryColor,
  });

  final List<ChartDataPoint> points;
  final List<Color> colors;
  final Color primaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxValue = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final minValue = points.map((p) => p.value).reduce((a, b) => a < b ? a : b);

    final valueRange = (maxValue - minValue).abs() < 1e-6
        ? (maxValue == 0 ? 1.0 : maxValue)
        : maxValue - minValue;

    final padding = 16.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    final dx = points.length > 1 ? chartWidth / (points.length - 1) : 0.0;

    final path = Path();
    final pointsOffset = <Offset>[];

    for (var i = 0; i < points.length; i++) {
      final normalized = (points[i].value - minValue) / valueRange;
      final x = padding + dx * i;
      final y = padding + chartHeight * (1 - normalized);
      final point = Offset(x, y);
      pointsOffset.add(point);

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    // تظليل أسفل الخط لزيادة وضوح المخطط
    final fillPath = Path.from(path)
      ..lineTo(pointsOffset.last.dx, padding + chartHeight)
      ..lineTo(pointsOffset.first.dx, padding + chartHeight)
      ..close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [primaryColor.withOpacity(0.25), primaryColor.withOpacity(0.02)],
      ).createShader(Rect.fromLTWH(padding, padding, chartWidth, chartHeight));

    canvas.drawPath(fillPath, fillPaint);

    // رسم الخط
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = primaryColor;

    canvas.drawPath(path, linePaint);

    // رسم النقاط
    for (var i = 0; i < pointsOffset.length; i++) {
      final point = pointsOffset[i];
      final color = colors[i % colors.length];

      final outerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final innerPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point, 4, outerPaint);
      canvas.drawCircle(point, 3, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.colors != colors ||
      oldDelegate.primaryColor != primaryColor;
}

/// رسام المخطط الدائري
class _PieChartPainter extends CustomPainter {
  _PieChartPainter({
    required this.points,
    required this.colors,
  });

  final List<ChartDataPoint> points;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final total = points.fold<double>(0, (sum, p) => sum + p.value);
    if (total <= 0 || total.isNaN || total.isInfinite) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final startAngleBase = -math.pi / 2; // نبدأ من الأعلى
    var startAngle = startAngleBase;

    for (var i = 0; i < points.length; i++) {
      final value = points[i].value;
      if (value <= 0) continue;

      final sweepAngle = (value / total) * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i % colors.length];

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.colors != colors;
}

