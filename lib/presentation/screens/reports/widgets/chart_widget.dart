import 'dart:math' as math;
import 'package:flutter/material.dart';

enum ChartType {
  line,
  bar,
  pie,
}

class ChartDataPoint {
  const ChartDataPoint({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final double value;
  final Color? color;
}

class ChartWidget extends StatelessWidget {
  const ChartWidget({
    required this.title,
    required this.chartType,
    required this.data,
    super.key,
    this.height = 280,
    this.primaryColor = const Color(0xFF6366F1),
  });

  final String title;
  final ChartType chartType;
  final List<ChartDataPoint> data;
  final double height;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIconForChartType(),
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: height,
            child: _buildChart(),
          ),
          if (data.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ],
      ),
    );
  }

  IconData _getIconForChartType() {
    switch (chartType) {
      case ChartType.line:
        return Icons.show_chart_rounded;
      case ChartType.bar:
        return Icons.bar_chart_rounded;
      case ChartType.pie:
        return Icons.pie_chart_rounded;
    }
  }

  Widget _buildChart() {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                color: const Color(0xFF9CA3AF),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد بيانات لعرضها',
              style: TextStyle(
                color: const Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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

  Widget _buildLineChart() {
    final colors = data
        .asMap()
        .entries
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

  Widget _buildBarChart() {
    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    if (maxValue <= 0 || !maxValue.isFinite) {
      return Center(
        child: Text(
          'بيانات غير صالحة',
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final availableHeight = height - 60;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final dataPoint = entry.value;
        final value = dataPoint.value.isFinite ? dataPoint.value : 0.0;
        final heightRatio = value / maxValue;
        final barColor = dataPoint.color ?? _getColorForIndex(index);
        final barHeight = (availableHeight * heightRatio).clamp(0.0, availableHeight);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (value > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: barColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      value.toStringAsFixed(0),
                      style: TextStyle(
                        color: barColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        barColor,
                        barColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: barColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dataPoint.label,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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

  Widget _buildPieChart() {
    final total = data.fold<double>(0, (sum, d) => sum + d.value);
    if (total <= 0 || !total.isFinite) {
      return Center(
        child: Text(
          'بيانات غير صالحة',
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final colors = data
        .asMap()
        .entries
        .map((entry) => entry.value.color ?? _getColorForIndex(entry.key))
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight) * 0.85;
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _PieChartPainter(
                  points: data,
                  colors: colors,
                ),
              ),
              Container(
                width: size * 0.5,
                height: size * 0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      total.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'إجمالي',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final dataPoint = entry.value;
        final color = dataPoint.color ?? _getColorForIndex(index);
        final total = data.fold<double>(0, (sum, d) => sum + d.value);
        final percentage = total > 0 ? (dataPoint.value / total * 100) : 0.0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dataPoint.label,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (chartType == ChartType.pie) ...[
                const SizedBox(width: 4),
                Text(
                  '(${percentage.toStringAsFixed(0)}%)',
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
    ];
    return colors[index % colors.length];
  }
}

class SimpleTrendChart extends StatelessWidget {
  const SimpleTrendChart({
    required this.title,
    required this.data,
    super.key,
    this.height = 220,
    this.primaryColor = const Color(0xFF6366F1),
  });

  final String title;
  final List<ChartDataPoint> data;
  final double height;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: const Color(0xFF9CA3AF),
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'لا توجد بيانات لعرضها',
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final total = data.fold<double>(0, (sum, p) => sum + p.value);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.show_chart_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  total.toStringAsFixed(0),
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final colors = data
                    .asMap()
                    .entries
                    .map((entry) => entry.value.color ?? primaryColor)
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

    final padding = 20.0;
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

    final fillPath = Path.from(path)
      ..lineTo(pointsOffset.last.dx, padding + chartHeight)
      ..lineTo(pointsOffset.first.dx, padding + chartHeight)
      ..close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.2),
          primaryColor.withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(padding, padding, chartWidth, chartHeight));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = primaryColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    for (var i = 0; i < pointsOffset.length; i++) {
      final point = pointsOffset[i];

      final shadowPaint = Paint()
        ..color = primaryColor.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(point, 6, shadowPaint);

      final outerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 5, outerPaint);

      final innerPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 3.5, innerPaint);
    }

    for (var i = 0; i < pointsOffset.length; i++) {
      final point = pointsOffset[i];
      final value = points[i].value;
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: points[i].label,
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          point.dx - textPainter.width / 2,
          size.height - 12,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.colors != colors ||
      oldDelegate.primaryColor != primaryColor;
}

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
    if (total <= 0 || !total.isFinite) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    final startAngleBase = -math.pi / 2;
    var startAngle = startAngleBase;

    for (var i = 0; i < points.length; i++) {
      final value = points[i].value;
      if (value <= 0) continue;

      final sweepAngle = (value / total) * 2 * math.pi;
      
      final shadowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i % colors.length].withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, startAngle, sweepAngle, true, shadowPaint);

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i % colors.length];

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white
        ..strokeWidth = 3;

      canvas.drawArc(rect, startAngle, sweepAngle, true, borderPaint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.colors != colors;
}
