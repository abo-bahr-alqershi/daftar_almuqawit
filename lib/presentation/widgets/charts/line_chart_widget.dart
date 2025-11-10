import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

/// ويدجت رسم بياني خطي
class LineChartWidget extends StatelessWidget {
  final List<LineChartDataSet> dataSets;
  final String? title;
  final bool showGrid;

  const LineChartWidget({
    super.key,
    required this.dataSets,
    this.title,
    this.showGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          lineBarsData: dataSets.map((ds) => LineChartBarData(spots: ds.data, color: ds.color)).toList(),
        ),
      ),
    );
  }
}

class LineChartDataSet {
  final String label;
  final List<FlSpot> data;
  final Color color;
  const LineChartDataSet({required this.label, required this.data, required this.color});
}
